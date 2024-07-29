# frozen_string_literal: true

class CreateFolderJob < ApplicationJob
  queue_as :default

  def perform bucket_token, full_path
    Api::V1::CreateFolderMinioService.new(
      bucket_token,
      full_path
    ).perform
  end
end
