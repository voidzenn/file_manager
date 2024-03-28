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
          meta = options.fetch :meta, {}
          data = if object.is_a?(Hash)
                   object.merge(options.except!(:status, :meta))
                 else
                   object
                 end

          response_data = {
            success: success,
            data: data,
            meta: meta
          }

          render json: response_data, status: status
        end
      end
    end
  end
end
