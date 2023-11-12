# frozen_string_litera: true

class Api::V1::RouteErrorController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    render json: { error: 'Route not found' }, status: :not_found
  end
end
