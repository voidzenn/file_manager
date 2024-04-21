class BaseChannel < ApplicationCable::Channel
  def self.broadcast channel_name, action, data
    ActionCable.server.broadcast(
      channel_name,
      data.merge({"action": action})
    )
  end
end
