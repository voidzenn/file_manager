# frozen_string_litera: true

require "rails_helper"

RSpec.describe Api::V1::RenameFolderService do
  include_context :initialize_aws_s3

  describe "#perform" do
    let(:user) { create :user }
    let(:old_prefix) { "old_path/" }
    let(:old_prefix_with_user_id) { "#{user.id}/#{old_prefix}" }
    let(:new_prefix) { "new_path/" }
    let(:new_prefix_with_user_id) { "#{user.id}/#{new_prefix}" }
    let(:service) { Api::V1::RenameFolderService.new(user.id, old_prefix, new_prefix) }
    let(:bucket_double) { double('bucket') }
    let(:objects_double) { double('objects', key: new_prefix_with_user_id) }

    it 'should rename and delete successfully' do
      allow(Api::V1::GetCurrentBucketService).to receive(:new).and_return(double(perform: bucket_double))
      allow(bucket_double).to receive(:objects).with(prefix: old_prefix_with_user_id).and_return([objects_double])
      allow(objects_double).to receive(:bucket_name).and_return('users')
      allow(objects_double).to receive(:copy_to)
      allow(objects_double).to receive(:delete)

      expect(service.perform).to eq [objects_double]
      expect(bucket_double).to have_received(:objects).with(prefix: old_prefix_with_user_id)
      expect(objects_double).to have_received(:copy_to).with(bucket: objects_double.bucket_name, key: new_prefix_with_user_id)
      expect(objects_double).to have_received(:delete).with(bucket: objects_double.bucket_name, key: old_prefix_with_user_id)
    end

    it 'should raise error' do
      allow(Api::V1::GetCurrentBucketService).to receive(:new).and_raise(Aws::S3::Errors::ServiceError.new({}, 'S3 error'))

      expect{ service.perform }.to raise_error(Aws::S3::Errors::ServiceError)
    end
  end
end
