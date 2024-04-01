class Api::V1::FolderSerializer < ActiveModel::Serializer
  attributes :id, :path, :parent_folder_id

  attribute :path do
    object&.path&.chop
  end
end
