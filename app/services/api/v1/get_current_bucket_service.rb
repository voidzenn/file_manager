# frozen_string_literal: true

class Api::V1::GetCurrentBucketService
  def perform
    load_bucket
  end

  private

  def load_bucket
    bucket_name = ENV.fetch("AWS_BUCKET_NAME", "users")

    s3 = Aws::S3::Resource.new
    s3.bucket(bucket_name)
  end
end
