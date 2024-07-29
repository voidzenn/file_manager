# frozen_string_literal: true

class RemoveFolderMinioJob < ApplicationJob
  queue_as :default

  def perform bucket_token, folder_path
    Api::V1::RemoveFolderMinioService.new(
      bucket_token,
      folder_path
    ).perform
  end
end
