class Api::V1::FileUploadSerializer < ActiveModel::Serializer
  attributes :id, :unique_token, :full_path, :filename, :file_extension, :created_at

  attribute :filename do
    object.name&.split('.')&.first
  end

  attribute :file_extension do
    object.name&.split('.')&.last
  end
end
