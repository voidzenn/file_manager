# frozen_string_literal: true

module Api
  module Error
    class Error < StandardError
      attr_reader :message

      def initialize message
        @message = message
      end
    end

    class UnprocessableEntity < Error
    end

    class UnauthorizedError < Error
    end

    class InternalServerError < Error
    end
  end
end
