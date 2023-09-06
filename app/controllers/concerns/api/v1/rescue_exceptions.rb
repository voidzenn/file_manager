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
        rescue_from ActiveRecord::RecordNotFound, with: :rescue_not_found
        rescue_from Api::Error::UnauthorizedError, with: :rescue_unauthorized
        rescue_from(
          Aws::S3::Errors::BucketAlreadyExists,
          Aws::S3::Errors::BucketAlreadyOwnedByYou,
          with: :rescue_bucket_exists
        )
        rescue_from Aws::S3::Errors::InvalidBucketName, with: :rescue_bucket_invalid
      end

      private

      def rescue_parameter_missing error
        render json: I18n.t("errors.params.missing"), status: :unprocessable_entity
      end

      def rescue_bad_request error
        response_body = ActiveRecordValidation::Error.new(error.record).to_hash
        render json: response_body, status: :bad_request
      end

      def rescue_not_found
        render json: {}, status: :not_found
      end

      def rescue_unauthorized error
        render json: I18n.t("errors.unauthorized.#{error.message.to_s}"), status: :unauthorized
      end

      def rescue_bucket_exists
        # No action is taken, error is silently handled
      end

      def rescue_bucket_invalid
        # No action is taken, error is silently handled
      end
    end
  end
end
