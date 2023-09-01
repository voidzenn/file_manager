# frozen_string_literal: true

module ActiveRecordValidation
  class Error
    def initialize record
      @record = record
    end

    def to_hash
      {
        success: false,
        errors: serialize_errors
      }
    end

    private

    def serialize_errors
      errors = []
      full_message = @record.errors.to_hash

      @record.errors.to_hash.map do |field, message|
        errors << message.first
      end

      errors
    end
  end
end