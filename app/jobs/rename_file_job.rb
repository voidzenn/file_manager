# frozen_string_literal: true

class RenameFileJob < ApplicationJob
  queue_as :default

  def perform bucket_token, old_full_path, new_full_path
    Api::V1::RenameFileMinioService.new(
      bucket_token,
      old_full_path,
      new_full_path
    ).perform
  end
end
