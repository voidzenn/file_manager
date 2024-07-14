# frozen_string_literal: true

class Api::V1::RemoveFolderMinioService
  def initialize bucket_token, folder_path
    @bucket_token = bucket_token
    @folder_path = folder_path
  end

  def perform
    remove_folder
  end

  private

  attr_reader :bucket_token, :folder_path

  def remove_folder
    bucket = Api::V1::GetCurrentBucketService.new(bucket_token).perform

    return if bucket.try(:objects).nil?

    objects = bucket.objects(prefix: folder_path)

    objects.each do |obj|
      obj.delete(
        bucket: obj.bucket_name,
        key: folder_path
      )
    end
  end
end
