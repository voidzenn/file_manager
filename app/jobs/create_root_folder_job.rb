# frozen_string_literal: true

class CreateRootFolderJob < ApplicationJob
  queue_as :default

  def perform bucket_token, path_name
    Api::V1::CreateFolderMinioService.new(
      bucket_token,
      path_name
    ).perform
  end
end
