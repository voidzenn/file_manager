class FileChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  class << self
    def broadcast_file_created user, payload
      self.broadcast_to user, action: 'file_created', data: payload
    end
  end
end
