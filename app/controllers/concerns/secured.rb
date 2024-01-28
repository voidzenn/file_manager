# frozen_string_literal: true

module Secured
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request!
  end

  private

  def authenticate_request!
    @current_user = load_user
  end

  def load_user
    User.find_by!(unique_token: jwt_token.id)
  rescue ActiveRecord::RecordNotFound
    raise Api::Error::UnauthorizedError, nil
  end

  def jwt_token
    token = request.headers["Authorization"].split(" ").last

    JsonWebToken.decode token
  end
end
