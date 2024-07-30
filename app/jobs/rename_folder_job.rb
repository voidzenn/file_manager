# frozen_string_literal: true

class RenameFolderJob < ApplicationJob
  queue_as :default

  def perform bucket_token, full_paths
    Api::V1::RenameFolderMinioService.new(
      bucket_token,
      full_paths[:old_full_path],
      full_paths[:new_full_path]
    ).perform
  end
end
