# frozen_string_literal: true

class Log
  class << self
    def error message
      Rails.logger.error "ERROR:: #{message}"
    end
  end
end
