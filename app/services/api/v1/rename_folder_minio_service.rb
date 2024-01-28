# frozen_string_literal: true

class Api::V1::RenameFolderMinioService
  def initialize user_token, old_prefix, new_prefix
    @user_token = user_token
    @old_prefix = old_prefix
    @new_prefix = new_prefix
  end

  def perform
    initialize_s3_objects
    rename_folder
  end

  private

  attr_reader :user_token, :old_prefix, :new_prefix

  def initialize_s3_objects
    bucket = Api::V1::GetCurrentBucketService.new.perform

    format_prefix_keys

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

  def format_prefix_keys
    # Add the user_token to the prefix.
    @old_prefix = "#{user_token}/#{old_prefix}"
    @new_prefix = "#{user_token}/#{new_prefix}"
  end
end
