# frozen_string_literal: true

class Api::V1::CreateUserRootFolderService
  def initialize user_token
    @user_token = user_token
  end

  def perform
    create_folder
  end

  private

  attr_reader :user_token

  def create_folder
    return false unless user_token.is_a? String

    bucket = Api::V1::GetCurrentBucketService.new.perform

    folder_key = "#{user_token}/"

    return true if bucket.object(folder_key).put(body: '')
    false
  end
end
