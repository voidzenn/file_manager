class Api::V1::FolderSerializer < ActiveModel::Serializer
  attributes :id, :parent_folder_id, :path
end
