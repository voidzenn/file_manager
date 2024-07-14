# frozen_string_literal: true

class Api::V1::RemoveFileMinioService
  def initialize bucket_token, file_path
    @bucket_token = bucket_token
    @file_path = file_path
  end

  def perform
    remove_file
  end

  private

  attr_reader :bucket_token, :file_path

  def remove_file
    bucket = Api::V1::GetCurrentBucketService.new(bucket_token).perform

    return if bucket.try(:objects).nil?

    objects = bucket.objects(prefix: file_path)

    objects.each do |obj|
      obj.delete(
        bucket: obj.bucket_name,
        key: file_path
      )
    end
  end
end
