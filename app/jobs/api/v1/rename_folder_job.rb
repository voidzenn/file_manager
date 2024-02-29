# frozen_string_literal: true

class Api::V1::RenameFolderJob < ApplicationJob
  queue_as :default

  def perform args = {}
    ActiveRecord::Base.transaction do
      full_paths = Api::V1::FolderTraversalService.new(
        user_id: args[:user_id],
        parent_folder_object: args[:parent_folder_object],
        new_prefix: args[:new_path],
        old_prefix: args[:path]
      ).perform

      args[:folder_object].update!(
        path: args[:new_path],
        full_path: full_paths[:new_full_path]
      )

      result = Api::V1::RenameFolderMinioService.new(
        args[:bucket_token],
        full_paths[:old_full_path],
        full_paths[:new_full_path]
      ).perform

      result
    end
  end
end
