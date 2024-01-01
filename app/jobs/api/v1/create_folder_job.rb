# frozen_string_literal: true

class Api::V1::CreateFolderJob < ApplicationJob
  queue_as :default

  def perform args = {}
    ActiveRecord::Base.transaction do
      Api::V1::CreateFolderService.new(params).perform

      full_path = Api::V1::CreateFolderTraversalService.new(
        args[:user_id],
        args[:parent_folder],
        args[:params][:path]
      ).perform

      Api::V1::CreateFolderMinioService.new(
        args[:user_token],
        full_path
      ).perform
    end
  end
end
