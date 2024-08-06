# frozen_string_literal: true

require "aws-sdk-s3"

Aws.config.update(
  credentials: Aws::Credentials.new(
    ENV["MINIO_ACCESS_KEY_ID"],
    ENV["MINIO_SECRET_ACCESS_KEY"]
  ),
  region: ENV["MINIO_REGION"],
  endpoint: ENV["MINIO_ENDPOINT"],
  force_path_style: true
)
