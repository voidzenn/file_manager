# frozen_string_literal: true

class Api::V1::RenameRootFolderJob < ApplicationJob
  queue_as :default

  def perform args = {}
    ActiveRecord::Base.transaction do
      args[:folder_object].update!(path: args[:new_path])

      result = Api::V1::RenameFolderMinioService.new(
        args[:bucket_token],
        args[:path],
        args[:new_path]
      ).perform

      result
    end
  end
end
