# frozen_string_litera: true

class Api::V1::RouteErrorController < Api::V1::BaseController
  def not_found
    render json: {}, status: :not_found
  end
end
