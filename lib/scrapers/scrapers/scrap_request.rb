module Scrapers
  class ScrapRequest
    attr_reader :root_url, :url, :input, :resource, :root, :output, :response, :request

    def initialize(root_url, url = nil, input = nil, resource = nil, root = nil)
      @root_url = root_url
      @url = url || root_url
      @input = input
      @resource = resource
      @root = root

      @response = nil
      @output = nil
      @finished = false
      @error = false
    end

    def set_output(value)
      @output = value
    end

    def set_response(value)
      @request = value.request
      @response = value
    end

    def clear_response
      @request = nil
      @response = nil
    end

    def destroy
      @root = nil
      @requests = []
      @subrequests = []
    end

    def root?
      @is_root ||= @root == self
    end

    def finished!
      @finished = true
    end

    def error!
      @error = true
    end

    def error?
      @error
    end

    def finished?
      @finished
    end

    def subrequest!(url)
      return nil if @root.was_url_requested? url
      @root.add_subrequest ScrapRequest.new(@group_url, url, @input, @resource, @root)
    end
  end

  class RootScrapRequest < ScrapRequest
    attr_reader :requests, :subrequests

    def initialize(url, input, resource, injector)
      super(url, url, input, resource, self)

      @injector = injector
      @consolidated_output = nil
      @requests = [self]
      @subrequests = []
    end

    def all_finished?
      @requests.all?(&:finished?)
    end

    def any_error?
      @requests.any?(&:error?)
    end

    def was_url_requested?(url)
      @requests.any?{ |r| r.url == url }
    end

    def consolidated_output
      @requests.reject(&:error?).map(&:output).inject(nil, &@injector)
    end

    def add_subrequest(scrap_request)
      @requests.push(scrap_request)
      @subrequests.push(scrap_request)
      scrap_request
    end
  end
end
