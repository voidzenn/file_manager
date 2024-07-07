# frozen_string_literal: true

class Api::RouteErrorController < ApplicationController
  skip_before_action :verify_authenticity_token

  def not_found
    render json: { error: 'Route not found' }, status: :not_found
  end
end
