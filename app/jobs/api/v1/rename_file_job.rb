class Api::V1::RenameFileJob < ApplicationJob
  queue_as :default

  def perform bucket_token, old_full_path, new_full_path
    Api::V1::RenameFileMinioService.new(
      bucket_token,
      old_full_path,
      new_full_path
    ).perform
  end
end
