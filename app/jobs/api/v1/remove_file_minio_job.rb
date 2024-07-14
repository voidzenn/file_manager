class Api::V1::RemoveFileMinioJob < ApplicationJob
  queue_as :default

  def perform bucket_token, file_path
    Api::V1::RemoveFileMinioService.new(bucket_token, file_path).perform
  end
end
