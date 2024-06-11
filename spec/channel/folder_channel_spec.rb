# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FolderChannel, type: :channel do
  let!(:user) { create :user }

  before do
    stub_connection(current_user: user)
  end

  describe '#subscribed' do
    it do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(user)
    end
  end

  describe '#unsubscribed' do
    it 'stop all streams' do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_for(user)

      subscription.unsubscribe_from_channel

      expect(subscription).not_to have_stream_for(user)
    end
  end

  describe '#broadcast_folder_created' do
    let(:data) { {data: "test"} }

    it 'broadcasts folder created to user' do
      expect {
        described_class.broadcast(user, FOLDER_CREATED, data)
      }.to have_broadcasted_to(user).with(action: 'folder_created', data: data)
    end
  end
end
