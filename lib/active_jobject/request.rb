# frozen_string_literal: true

module ActiveJobject
  module Request
    include ActiveJobject::Parser

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def engine=(engine)
        @engine = engine
      end

      def engine
        @engine ||= ActiveJobject::Request::Engine::NetHttp
      end

      def default_headers=(headers)
        @default_headers = headers
      end

      def default_headers
        @default_headers ||= {}
      end
    end

    def get(headers: {}, params: {})
      merged_headers = self.class.default_headers.merge(headers)
      response = self.class.engine.get(site: uri, headers: merged_headers, params:)

      parse(self, **JSON.parse(response.body))
    end

    def post(headers: {}, params: {}, body: nil)
      merged_headers = self.class.default_headers.merge(headers)
      response = self.class.engine.post(site: uri, headers: merged_headers, params:, body:)

      parse(self, **JSON.parse(response.body))
    end

    def put; end

    def delete; end

    private

    def error_class(status)
      case status
      when 404
        ActiveJobject::Request::NotFound
      when 500
        ActiveJobject::Request::ServerError
      else
        ActiveJobject::Request::Error
      end
    end
  end
end
