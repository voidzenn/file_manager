# frozen_string_literal: true

class Api::V1::CreateFolderService
  def initialize user_token, path
    @user_token = user_token
    @path = path
  end

  def perform
    load_bucket
    create_folder
  end

  private

  attr_reader :user_token, :path

  def load_bucket
    @bucket = Api::V1::GetCurrentBucketService.new.perform
  end

  def create_folder
    return if path.starts_with? "/"
    return unless path.ends_with? "/"

    @bucket.object(folder_key).put(body: "")

    true
  end

  def folder_key
    # Should start with / to locate folder
    "/#{user_token}/#{path}"
  end
end
