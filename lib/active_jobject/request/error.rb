# frozen_string_literal: true

module ActiveJobject
  module Request
    class Error < ActiveJobject::Error
      def initialize(response:, status:)
        @response = response
        @status = status

        super("Request Failed: Status #{status}.")
      end

      def to_h
        { message:, status: @status, backtrace: backtrace }
      end
    end

    # Errors related to HTTP Status 401
    class Unauthorized < Error; end

    # Errors related to HTTP Status 403
    class Forbidden < Error; end

    # Errors related to HTTP Status 404
    class NotFound < Error; end

    # Errors related to HTTP Status 500
    class ServerError < Error; end
  end
end
