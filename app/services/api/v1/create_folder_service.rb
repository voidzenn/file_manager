# frozen_string_literal: true

class Api::V1::CreateFolderService
  def initialize user_id, path
    @user_id = user_id
    @path = path
  end

  def perform
    load_bucket
    create_folder
  end

  private

  attr_reader :user_id, :path

  def load_bucket
    @bucket = Api::V1::GetCurrentBucketService.new.perform
  end

  def create_folder
    return if path.starts_with? "/"
    return unless path.ends_with? "/"

    @bucket.object(folder_key!).put(body: "")
  end

  def folder_key!
    # Should start with / to locate folder
    "/#{user_id}/#{path}"
  end
end
