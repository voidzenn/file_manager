class Api::V1::FolderSerializer < ActiveModel::Serializer
  attributes :id, :unique_token, :path, :parent_folder_id, :created_at

  attribute :path do
    object&.path&.chop
  end
end
