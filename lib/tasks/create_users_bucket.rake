# frozen_string_literal: true

desc "Create Users Bucket"
namespace :init do
  task create_users_bucket: :environment do
    bucket_name = ENV.fetch("AWS_BUCKET_NAME", "users")

    puts "Creating bucket"
    Api::V1::CreateBucketService.new("bucket_name").perform
  end
end