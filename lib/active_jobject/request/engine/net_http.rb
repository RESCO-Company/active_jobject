class ActiveJobject::Request::Engine::NetHttp < ActiveJobject::Request::Engine
  class << self
    # Make a HTTP GET request.
    #
    # @raise [ActiveJobject::Request::Error] error class related with the request.
    #
    # @return [Net::HTTPResponse]
    def get(site:, headers: {}, params: {})
      req = Net::HTTP::Get.new(site)

      headers.each do |key, value|
        req[key] = value
      end

      response = Net::HTTP.start(site.hostname, site.port) do |http|
        http.request(req)
      end

      raise error_class(response.code.to_i).new(response:, status: response.code.to_i) unless Net::HTTPSuccess > response.class

      response
    end

    # Make a HTTP POST request.
    #
    # @raise [ActiveJobject::Request::Error] error class related with the request.
    #
    # @return [Net::HTTPResponse]
    def post(site:, headers: {}, params: {}, body: nil)
      req = Net::HTTP::Post.new(site)

      headers.each do |key, value|
        req[key] = value
      end

      req.body = body.is_a?(Hash) ? JSON.generate(body) : body

      response = Net::HTTP.start(site.hostname, site.port) do |http|
        http.request(req)
      end

      raise error_class(response.code.to_i).new(response:, status: response.code.to_i) unless Net::HTTPSuccess > response.class

      response
    end

    # Make a HTTP PUT request.
    #
    # @raise [ActiveJobject::Request::Error] error class related with the request.
    #
    # @return [Net::HTTPResponse]
    def put(site:, headers: {}, params: {}, body: nil)
      req = Net::HTTP::Put.new(site)

      headers.each do |key, value|
        req[key] = value
      end

      req.body = body.is_a?(Hash) ? JSON.generate(body) : body

      response = Net::HTTP.start(site.hostname, site.port) do |http|
        http.request(req)
      end

      raise error_class(response.code.to_i).new(response:, status: response.code.to_i) unless Net::HTTPSuccess > response.class

      response
    end

    # Make a HTTP PATCH request.
    #
    # @raise [ActiveJobject::Request::Error] error class related with the request.
    #
    # @return [Net::HTTPResponse]
    def put(site:, headers: {}, params: {}, body: nil)
      req = Net::HTTP::Patch.new(site)

      headers.each do |key, value|
        req[key] = value
      end

      req.body = body.is_a?(Hash) ? JSON.generate(body) : body

      response = Net::HTTP.start(site.hostname, site.port) do |http|
        http.request(req)
      end

      raise error_class(response.code.to_i).new(response:, status: response.code.to_i) unless Net::HTTPSuccess > response.class

      response
    end

    # Make a HTTP DELETE request.
    #
    # @raise [ActiveJobject::Request::Error] error class related with the request.
    #
    # @return [Net::HTTPResponse]
    def delete(site:, headers: {}, params: {})
      req = Net::HTTP::Delete.new(site)

      headers.each do |key, value|
        req[key] = value
      end

      response = Net::HTTP.start(site.hostname, site.port) do |http|
        http.request(req)
      end

      raise error_class(response.code.to_i).new(response:, status: response.code.to_i) unless Net::HTTPSuccess > response.class

      response
    end
  end
end
