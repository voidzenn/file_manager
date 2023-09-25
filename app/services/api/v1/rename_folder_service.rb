# frozen_string_literal: true

class Api::V1::RenameFolderService
  def initialize old_prefix, new_prefix
    @old_prefix = old_prefix
    @new_prefix = new_prefix
  end

  def perform
    initialize_s3_objects
    rename_folder
  end

  private

  attr_reader :old_prefix

  def initialize_s3_objects
    s3 = Aws::S3::Resource.new
    @objects = s3.list_objects_v2(bucket: "", prefix: old_prefix).contents
  end

  def rename_folder
    @objects.each do |obj|
      new_key = obj.key.sub(old_prefix, new_prefix)
      obj.copy_to(bucket: new_prefix, key: new_key)
    end
  end
end
