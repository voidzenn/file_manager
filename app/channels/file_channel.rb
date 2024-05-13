class FileChannel < BaseChannel
  def subscribed
    stream_from FILE_CHANNEL
  end

  def receive data
  end

  def unsubscribed
  end

  class << self
    def broadcast_file_created data
      broadcast FILE_CHANNEL, "file_created", data
    end
  end
end
