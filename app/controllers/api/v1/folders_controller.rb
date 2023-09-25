# frozen_string_literal: true

class Api::V1::FoldersController < Api::V1::BaseController
  before_action :find_folder, only: :rename

  def create
    @folder = Folder.new(folder_params.merge(user_id: current_user_id))

    raise ActiveRecord::RecordInvalid, @folder unless @folder.valid?

    create_folder

    @folder.save
    render_jsonapi success_response
  end

  # Update :new_path instead of :path to preserve the old path in the database.
  # Renaming bucket folders can be resource-intensive and less scalable.
  # We use :new_path to locate :path to get the files.
  def rename
    if @folder.update(new_path: folder_update_params[:new_path])
      render_jsonapi success_update_response
    else
      raise ActiveRecord::RecordInvalid, @folder
    end
  end

  private

  def folder_params
    params.require(:folder).permit(:path)
  end

  def folder_update_params
    params.require(:folder).permit(:old_path, :new_path)
  end

  def find_folder
    # If can't find :new_path then find :path.
    @folder = find_new_path || find_path

    raise ActiveRecord::RecordNotFound if @folder.nil?
  end

  def find_new_path
    folder ||=
      Folder.find_by(user_id: current_user_id,
                     new_path: folder_update_params[:old_path])
  end

  def find_path
    folder ||=
      Folder.find_by(user_id: current_user_id,
                     path: folder_update_params[:old_path])
    # If :new_path has value or renamed, then return.
    return if folder.new_path.present?
  end

  def success_response
    {
      path: @folder.path
    }
  end

  def success_update_response
    {
      new_path: @folder.new_path
    }
  end

  def create_folder
    create = Api::V1::CreateFolderService.new(current_user_id, @folder.path)

    raise Api::Error::InternalServerError, nil unless create.perform
  end
end
