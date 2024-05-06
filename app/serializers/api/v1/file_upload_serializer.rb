class Api::V1::FileUploadSerializer < ActiveModel::Serializer
  attributes :unique_token, :full_path, :name, :created_at
end
