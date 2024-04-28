class BaseChannel < ApplicationCable::Channel
  def self.broadcast channel_name, action, data
    return unless data.is_a? Hash

    body_data = {
      action: action,
      data: [data]
    }

    ActionCable.server.broadcast(
      channel_name,
      body_data
    )
  end
end
