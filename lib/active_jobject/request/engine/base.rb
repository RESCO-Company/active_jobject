# frozen_string_literal: true

module ActiveJobject
  module Request
    module Engine
      class Base
        class << self
          def get
            raise NotImplementedError
          end

          def post
            raise NotImplementedError
          end

          def put
            raise NotImplementedError
          end

          def patch
            raise NotImplementedError
          end

          def delete
            raise NotImplementedError
          end

          def error_class(status)
            case status
            when 401
              ActiveJobject::Request::Unauthorized
            when 403
              ActiveJobject::Request::Forbidden
            when 404
              ActiveJobject::Request::NotFound
            when 500
              ActiveJobject::Request::ServerError
            else
              ActiveJobject::Request::Error
            end
          end

          def authorization_strategy
            @authorization_strategy ||= ->(site:) { raise NotImplementedError, 'Set `authorization_strategy` prior to running requests.' } # rubocop:disable Lint/UnusedBlockArgument
          end
          attr_writer :authorization_strategy

          def before_request; end

          def after_request; end
        end
      end
    end
  end
end
