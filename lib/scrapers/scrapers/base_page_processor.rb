module Scrapers
  class BasePageProcessor
    def initialize(scrap_request, &add_to_queue)
      @scrap_request = scrap_request
      @response      = scrap_request.response
      @request       = scrap_request.request
      @root_url      = scrap_request.root_url
      @input         = scrap_request.input
      @url           = scrap_request.url
      @base_url      = @url.sub(/[^\/]+$/, '')

      @doc = Nokogiri::HTML(@response.body)
      @add_to_queue = add_to_queue
    end

    attr_accessor :data

    def process_page
      raise NotImplementedError.new('#process_page is an abstract method')
    end

    def add_to_queue(url)
      url = @base_url + url if not url =~ /^http/
      @add_to_queue.call(url)
    end

    def css(matcher)
      @doc.search(matcher)
    end

    def self.inject(all_data, data)
      data
    end

    def self.regexp(value = nil)
      (@regexp = value if value) || @regexp || /./
    end
  end
end
