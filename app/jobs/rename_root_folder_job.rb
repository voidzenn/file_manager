# frozen_string_literal: true

class RenameRootFolderJob < ApplicationJob
  queue_as :default

  def perform args = {}
    Api::V1::RenameFolderMinioService.new(
      args[:bucket_token],
      args[:path],
      args[:new_path]
    ).perform
  end
end
