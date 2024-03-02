# frozen_string_literal: true

class Api::V1::CreateFolderMinioService
  def initialize bucket_token, path
    @bucket_token = bucket_token
    @path = path
  end

  def perform
    load_bucket
    create_folder
  end

  private

  attr_reader :bucket_token, :path

  def load_bucket
    @bucket = Api::V1::GetCurrentBucketService.new(bucket_token).perform
  end

  def create_folder
    return if path.starts_with? "/"
    return unless path.ends_with? "/"

    @bucket.object(path).put(body: "")

    true
  end
end
