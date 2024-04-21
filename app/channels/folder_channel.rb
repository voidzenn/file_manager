class FolderChannel < BaseChannel
  def subscribed
    stream_from FOLDER_CHANNEL
  end

  def receive data
  end

  def unsubscribed
  end

  class << self
    def broadcast_folder_created data
      broadcast FOLDER_CHANNEL, "folder_created", data
    end
  end
end
