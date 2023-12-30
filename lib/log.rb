# frozen_string_literal: true

module Log
  class Log
    attr_reader :message

    def initialize message
      @message = message
    end
  end

  class Error < Log
    class << self
      def log_now message
        Rails.logger.error "ERROR:: #{message}"
      end
    end
  end
end
