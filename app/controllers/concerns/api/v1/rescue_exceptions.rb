# frozen_string_literal: true

module Api
  module V1
    module RescueExceptions
      extend ActiveSupport::Concern

      included do
        rescue_from ActionController::ParameterMissing, JSON::ParserError, with: :rescue_parameter_missing
        rescue_from(
          ActionController::BadRequest,
          ActiveRecord::RecordInvalid,
          with: :rescue_bad_request
        )
      end

      private

      def rescue_parameter_missing error
        render json: I18n.t("errors.params.missing"), status: :unprocessable_entity
      end

      def rescue_bad_request error
        response_body = ActiveRecordValidation::Error.new(error.record).to_hash
        render json: response_body, status: :bad_request
      end
    end
  end
end
