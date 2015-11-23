module Scrapers
  class Loader
    attr_reader :data

    def initialize(processor, urls = [], inputs = nil, resources = nil, options = {})
      @processor = processor

      @multi_urls = urls.kind_of? Array
      urls_array      = @multi_urls ? urls : [urls]
      inputs_array    = inputs    ? (@multi_urls ? inputs : [inputs])       : []
      resources_array = resources ? (@multi_urls ? resources : [resources]) : []

      raise ArgumentError.new('urls.size != inputs.size')     if inputs && urls_array.size != inputs_array.size
      raise  ArgumentError.new('urls.size != resources.size') if resources && urls_array.size != resources_array.size

      injector = @processor.method(:inject)
      @scrap_requests = urls_array.each_with_index.map do |url, i|
        RootScrapRequest.new(url, inputs_array[i], resources_array[i], injector)
      end

      @options = {
        headers: {},
        continue_with_errors: false
      }.merge(options)

      @hydra = Typhoeus::Hydra.hydra
    end

    def scrap(yield_type: :request, yield_with_errors: false, collect: nil, &block)
      raise 'Unknown yield type' unless [:group, :request]

      @data = {}
      @yield_block = block
      @yield_type = yield_type
      @yield_with_errors = yield_with_errors
      @yield_collect = collect.nil? ? !block_given? : collect
      @scrap_requests.each do |scrap_request|
        add_to_queue scrap_request
      end
      @hydra.run

      @data = consolidated_output_hash

      if @yield_collect
        @multi_urls ? @data : @data.values.first
      end
    end

    private

    def consolidated_output_hash
      outputs = {}
      inject = @processor.method(:inject)
      @scrap_requests.map do |scrap_request|
        outputs[scrap_request.url] = scrap_request.consolidated_output(&inject)
      end
      outputs
    end

    def process_response(scrap_request)
      if scrap_request.error?
        Scrapers.logger.error "Error loading page #{scrap_request.url} Error code: #{scrap_request.response.code}"
      else
        processor = create_processor(scrap_request)

        load_time = scrap_request.response.total_time
        Scrapers.logger.info "Parsing #{scrap_request.url} | Load time: #{load_time}".light_black

        begin
          output = processor.process_page
        rescue StandardError => e
          scrap_request.error!
          Scrapers.logger.error "Error parsing #{scrap_request.url}"
          # Scrapers.logger.store_error_page scrap_request, e
          raise e unless @options[:continue_with_errors]
        else
          scrap_request.set_output output
        end
      end

      if yield_scrap_request(scrap_request)
        destroy_scrap_request(scrap_request) unless @yield_collect
      end
    end

    def create_processor(scrap_request)
      @processor.new(scrap_request) do |url|
        add_to_queue scrap_request.subrequest!(url), front: true
      end
    end

    def yield_scrap_request(scrap_request)
      if @yield_block
        if @yield_type == :group
          if scrap_request.root.all_finished?
            if @yield_with_errors or not scrap_request.root.any_error?
              @yield_block.call(scrap_request.root)
              return true
            end
          end
        else
          if @yield_with_errors or not scrap_request.error?
            @yield_block.call(scrap_request)
            return true
          end
        end
      end
      false
    end

    # This allows less memory usage
    def destroy_scrap_request(scrap_request)
      scrap_request.destroy
      @scrap_requests.delete(scrap_request)
    end

    def add_to_queue(scrap_request, front: false)
      if scrap_request
        match_processor!(scrap_request.url)
        request = Typhoeus::Request.new(scrap_request.url, headers: @options[:headers], followlocation: true)
        request.on_complete do |response|
          scrap_request.set_response response
          scrap_request.finished!
          scrap_request.error! if not response.success?
          process_response scrap_request
          scrap_request.clear_response
        end
        front ? @hydra.queue_front(request) : @hydra.queue(request)
      end
    end

    def match_processor!(url)
      no_processor_error(url) unless @processor.regexp.match url
    end

    def no_processor_error(url)
      raise NoPageProcessorFoundError.new("Couldn't find processor for #{url} \n Active processor: #{@processor.class}")
    end
  end
end
