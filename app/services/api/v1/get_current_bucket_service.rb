# frozen_string_literal: true

class Api::V1::GetCurrentBucketService
  def initialize token
    @token = token
  end

  def perform
    load_bucket
  end

  private

  attr_reader :token

  def load_bucket
    s3 = Aws::S3::Resource.new
    s3.bucket(token)
  end
end
