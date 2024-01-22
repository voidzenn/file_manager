# frozen_string_literal: true

class Api::V1::CreateFolderJob < ApplicationJob
  queue_as :default

  def perform args = {}
    ActiveRecord::Base.transaction do
      Api::V1::CreateFolderService.new(args[:params]).perform

      full_path = Api::V1::FolderTraversalService.new(
        user_id: args[:user_id],
        parent_folder_object: args[:parent_folder_object],
        new_prefix: args[:params][:path]
      ).perform

      Api::V1::CreateFolderMinioService.new(
        args[:user_token],
        full_path[:new_path]
      ).perform
    end
  end
end
