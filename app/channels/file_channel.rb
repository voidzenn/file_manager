class FileChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end

  class << self
    def broadcast user, action, payload
      self.broadcast_to user, action: action, data: payload
    end
  end
end
