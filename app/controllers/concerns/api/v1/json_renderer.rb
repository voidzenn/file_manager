# frozen_string_literal: true

module Api
  module V1
    module JsonRenderer
      extend ActiveSupport::Concern

      protected

      included do
        def render_jsonapi object, options = {}
          success = options.fetch :success, true
          status = options.fetch :status, :ok
          data = object.merge options.except!(:status)

          response_data = {
            success: success,
            data: data,
          }
          render json: response_data, status: status
        end
      end
    end
  end
end
