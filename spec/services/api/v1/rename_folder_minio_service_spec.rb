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
    let(:bucket_double) { double('bucket') }

    it 'should rename and delete successfully' do
      allow(Api::V1::GetCurrentBucketService).to receive(:new).and_return(double(perform: bucket_double))
      allow_any_instance_of(described_class).to receive(:perform).and_return(true)

      expect(service.perform).to eq true
    end

    it 'should raise error' do
      allow(Api::V1::GetCurrentBucketService).to receive(:new).and_raise(Aws::S3::Errors::ServiceError.new({}, 'S3 error'))

      expect{ service.perform }.to raise_error(Aws::S3::Errors::ServiceError)
    end
  end
end
