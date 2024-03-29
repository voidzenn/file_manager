# frozen_string_literal: true

class Api::V1::CreateRootFolderJob < ApplicationJob
  queue_as :default

  def perform params, bucket_token, path_name
    ActiveRecord::Base.transaction do
      Api::V1::CreateFolderService.new(params).perform

      Api::V1::CreateFolderMinioService.new(
        bucket_token,
        path_name
      ).perform
    end
  end
end
