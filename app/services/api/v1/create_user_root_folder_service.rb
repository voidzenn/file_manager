# frozen_string_literal: true

class Api::V1::CreateUserRootFolderService
  def initialize user_id
    @user_id = user_id
    @bucket_name = ENV.fetch("AWS_BUCKET_NAME", "users")
  end

  def perform
    initialize_bucket
    create_folder
  end

  private

  attr_reader :user_id, :bucket_name

  def create_folder
    folder_key = "#{user_id}/"

    @bucket.object(folder_key).put(body: "")
  end

  def initialize_bucket
    s3 = Aws::S3::Resource.new
    @bucket = s3.bucket(bucket_name)
  end
end
