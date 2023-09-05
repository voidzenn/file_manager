# frozen_string_literal: true

module Api
  module Error
    class UnauthorizedError < StandardError
      attr_reader :message

      def initialize message
        @message = message
      end
    end
  end
end
