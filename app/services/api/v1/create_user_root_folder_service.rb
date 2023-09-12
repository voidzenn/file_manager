# frozen_string_literal: true

class Api::V1::CreateUserRootFolderService
  def initialize user_id
    @user_id = user_id
  end

  def perform
    initialize_bucket
    create_folder
  end

  private

  attr_reader :user_id, :bucket_name

  def initialize_bucket
    @bucket = Api::V1::GetCurrentBucketService.new.perform
  end

  def create_folder
    return unless user_id.is_a? Numeric

    folder_key = "#{user_id}/"

    @bucket.object(folder_key).put(body: "")
  end
end
