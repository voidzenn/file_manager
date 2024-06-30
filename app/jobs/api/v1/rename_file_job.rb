class Api::V1::RenameFileJob < ApplicationJob
  queue_as :default

  def perform bucket_token, full_paths
    Api::V1::RenameFileMinioService.new(
      bucket_token,
      full_paths[:old_full_path],
      full_paths[:new_full_path]
    ).perform
  end
end
