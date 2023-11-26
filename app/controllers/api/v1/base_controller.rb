class Api::V1::BaseController < ApplicationController
  include Secured
  include Api::V1::BaseConcern

  skip_before_action :verify_authenticity_token

  def current_user_id
    @current_user_id = @current_user.id
  end
end
