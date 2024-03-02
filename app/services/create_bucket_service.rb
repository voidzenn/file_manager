# frozen_string_literal: true

class CreateBucketService
  def initialize bucket_name
    @bucket_name = bucket_name
  end

  def perform
    create_bucket
  end

  private

  attr_reader :bucket_name

  def create_bucket
    s3 = Aws::S3::Resource.new
    s3.create_bucket(bucket: bucket_name)
  end
end
