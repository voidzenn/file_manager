# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  def create
    @folder = Folder.new(folder_params.merge(user_id: current_user_id))

    raise ActiveRecord::RecordInvalid, @folder unless @folder.valid?

    create_folder

    @folder.save
    render_jsonapi success_response
  end

  private

  def folder_params
    params.require(:folder).permit(:path)
  end

  def success_response
    {
      path: @folder.path
    }
  end

  def create_folder
    create = Api::V1::CreateFolderService.new(current_user_id, @folder.path)

    raise Api::Error::InternalServerError, nil unless create.perform
  end
end
