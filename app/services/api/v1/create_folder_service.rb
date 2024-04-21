# frozen_string_literal: true

class Api::V1::CreateFolderService
  def initialize params
    @params = params
  end

  def perform
    create_folder
    broadcast_folder_created
  end

  private

  attr_reader :params

  def create_folder
    @folder = Folder.new(params)
    @folder.save!
  end

  def broadcast_folder_created
    FolderChannel.broadcast_folder_created Api::V1::FolderSerializer.new(@folder).serializable_hash
  end
end
