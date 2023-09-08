# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :authenticate_request!

  def create
    p "hey"
  end
end
