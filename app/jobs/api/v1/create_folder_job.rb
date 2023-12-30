# frozen_string_literal: true

class Api::V1::CreateFolderJob < ApplicationJob
  queue_as :default

  def perform params = {}
    full_path = Api::V1::CreateFolderTraversalService.new(
      params[:user_id],
      params[:parent_folder],
      params[:path_name]
    ).perform

    @result = Api::V1::CreateFolderMinioService.new(
      params[:user_token],
      full_path
    ).perform
  end

  after_perform do |job|
    puts "Processed data: #{@result}"
  end
end
