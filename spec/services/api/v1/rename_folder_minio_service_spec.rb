# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::RenameFolderMinioService do
  include_context :initialize_aws_s3

  describe "#perform" do
    let(:user) { create :user }
    let(:old_prefix) { "old_path/" }
    let(:old_prefix_with_user_id) { "#{user.id}/#{old_prefix}" }
    let(:new_prefix) { "new_path/" }
    let(:new_prefix_with_user_id) { "#{user.id}/#{new_prefix}" }
    let(:service) { described_class.new(user.id, old_prefix, new_prefix) }
    let(:object_bucket_name) { double('ObjectBucket', bucket_name: '') }
    let(:object_double) do
      double('Object', bucket_name: object_bucket_name, key: old_prefix, sub: new_prefix)
    end
    let(:objects_double) do
      double('Objects').tap do |objects|
        allow(objects).to receive(:each).and_yield(object_double)
      end
    end

    context 'when renaming root folder' do
      before do
        allow_any_instance_of(Api::V1::GetCurrentBucketService).to receive(:perform).and_return(double(objects: objects_double))
      end

      it 'should rename and delete successfully' do
        allow(object_double).to receive(:copy_to)
        allow(object_double).to receive(:delete)

        expect(service.perform).to eq true
      end

      it 'should raise error' do
        allow(object_double).to receive(:copy_to).and_raise(StandardError, 'Error deleting folder')

        expect{ service.perform }.to raise_error(StandardError)
      end
    end
  end
end
