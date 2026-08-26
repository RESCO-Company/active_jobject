# frozen_string_literal: true

# Optional Dependency since the default engine is Net/HTTP
require 'oauth2' if Gem::Specification.find_all_by_name('oauth2').any?

module ActiveJobject
  module Request
    module Engine
      class OAuth2 < ActiveJobject::Request::Engine::Base
        class << self
          # Make a HTTP GET request.
          #
          # @raise [ActiveJobject::Request::Error] error class related with the request.
          #
          # @return [OAuth2::Response] the response from the request
          #
          # @see OAuth2::Client#request
          def get(site:, headers: {}, params: {})
            host, path = deconstruct_uri(site)

            authorization_strategy.call(site: host).get(path, params:, headers:)
          rescue ::OAuth2::Error => e
            raise handle_error(e, caller)
          end

          # Make a HTTP POST request.
          #
          # @raise [ActiveJobject::Request::Error] error class related with the request.
          #
          # @return [OAuth2::Response] the response from the request
          #
          # @see OAuth2::Client#request
          def post(site:, headers: {}, params: {}, body: nil)
            host, path = deconstruct_uri(site)

            authorization_strategy.call(site: host).post(path, params:, headers:, body:)
          rescue ::OAuth2::Error => e
            raise handle_error(e, caller)
          end

          # Make a HTTP PUT request.
          #
          # @raise [ActiveJobject::Request::Error] error class related with the request.
          #
          # @return [OAuth2::Response] the response from the request
          #
          # @see OAuth2::Client#request
          def put(site:, headers: {}, params: {}, body: nil)
            host, path = deconstruct_uri(site)

            authorization_strategy.call(site: host).put(path, params:, headers:, body:)
          rescue ::OAuth2::Error => e
            raise handle_error(e, caller)
          end

          # Make a HTTP PATCH request.
          #
          # @raise [ActiveJobject::Request::Error] error class related with the request.
          #
          # @return [OAuth2::Response] the response from the request
          #
          # @see OAuth2::Client#request
          def patch(site:, headers: {}, params: {}, body: nil)
            host, path = deconstruct_uri(site)

            authorization_strategy.call(site: host).patch(path, params:, headers:, body:)
          rescue ::OAuth2::Error => e
            raise handle_error(e, caller)
          end

          # Make a HTTP DELETE request.
          #
          # @raise [ActiveJobject::Request::Error] error class related with the request.
          #
          # @return [OAuth2::Response] the response from the request
          #
          # @see OAuth2::Client#request
          def delete(site:, headers: {}, params: {})
            host, path = deconstruct_uri(site)

            authorization_strategy.call(site: host).delete(path, params:, headers:)
          rescue ::OAuth2::Error => e
            raise handle_error(e, caller)
          end

          private

          def handle_error(error, original_caller)
            raise error if error.class != ::OAuth2::Error

            response_status = error.response&.status
            http_error_class = error_class(response_status).new(response: error.response, status: response_status)

            http_error_class.set_backtrace(original_caller)
            raise http_error_class
          end

          def deconstruct_uri(uri)
            host_with_scheme = [80, 443].include?(uri.port) ? "#{uri.scheme}://#{uri.host}/" : "#{uri.scheme}://#{uri.host}:#{uri.port}/"
            path = uri.path

            [host_with_scheme, path]
          end
        end
      end
    end
  end
end
