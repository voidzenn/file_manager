# frozen_string_literal: true

class Api::V1::RenameFolderMinioService
  def initialize bucket_token, old_prefix, new_prefix
    @bucket_token = bucket_token
    @old_prefix = old_prefix
    @new_prefix = new_prefix
  end

  def perform
    initialize_s3_objects
    rename_folder
  end

  private

  attr_reader :bucket_token, :old_prefix, :new_prefix

  def initialize_s3_objects
    bucket = Api::V1::GetCurrentBucketService.new(bucket_token).perform

    @objects = bucket.objects(prefix: old_prefix)
  end

  def rename_folder
    @objects.each do |obj|
      new_key = obj.key.sub(old_prefix, new_prefix)
      obj.copy_to(bucket: obj.bucket_name, key: new_key)

      # Delete the folder with old prefix.
      obj.delete(bucket: obj.bucket_name, key: old_prefix)
    end

    true
  rescue => e
    raise e
  end
end
