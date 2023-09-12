# frozen_string_literal: true

module Api
  module V1
    module RescueExceptions
      extend ActiveSupport::Concern

      included do
        rescue_from(
          ActionController::ParameterMissing,
          JSON::ParserError,
          with: :rescue_parameter_missing
        )
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
        rescue_from(
          Aws::S3::Errors::InvalidBucketName,
          with: :rescue_bucket_invalid
        )
        rescue_from Aws::S3::Errors::NoSuchBucket, with: :rescue_no_such_bucket
        rescue_from NameError, with: :rescue_name_error
        rescue_from(
          Api::Error::InternalServerError,
          with: :rescue_internal_server_error
        )
      end

      private

      def rescue_parameter_missing error
        render json: I18n.t("errors.params.missing"),
               status: :unprocessable_entity
      end

      def rescue_bad_request error
        response_body = ActiveRecordValidation::Error.new(error.record).to_hash
        render json: response_body, status: :bad_request
      end

      def rescue_not_found
        render json: {}, status: :not_found
      end

      def rescue_unauthorized error
        response_body = if error.message.nil?
                          I18n.t("errors.unauthorized.default")
                        else
                          I18n.t("errors.unauthorized.#{error.message.to_s}")
                        end
        render json: response_body, status: :unauthorized
      end

      def rescue_bucket_exists
        # No action is taken, error is silently handled
      end

      def rescue_bucket_invalid
        # No action is taken, error is silently handled
      end

      def rescue_no_such_bucket
        # No action is taken, error is silently handled
      end

      def rescue_name_error
        # No action is taken, error is silently handled
      end

      def rescue_internal_server_error error
        response_body = if error.message.nil?
                          I18n.t("errors.internal_server_error.default")
                        else
                          I18n.t("errors.internal_server_error.#{error.message.to_s}")
                        end
        render json: response_body, status: :internal_server_error
      end
    end
  end
end
