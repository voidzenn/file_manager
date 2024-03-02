# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CreateUserRootFolderMinioService do
  describe "#perform" do
    context "when create user root folder successfully" do
      let!(:user) { create :user }
      let(:user_unique_token) { user.unique_token }
      let(:service) { described_class.new(user_unique_token) }

      before do
        allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: true)))
      end

      it do
        expect(service.perform).to eq true
      end
    end

    context "when create user root folder fails" do
      let!(:user) { create :user }

      context "when user_unique_token is not a string value" do
        let(:user_unique_token) { 1 }
        let(:service) { described_class.new(user_unique_token) }

        it do
          expect(service.perform).to eq false
        end
      end

      context "when user_unique_token is not a string value" do
        let!(:user) { create :user }
        let(:user_unique_token) { 1 }
        let(:service) { described_class.new(user_unique_token) }
        let(:bucket_object) { double(object: double(put: true)) }

        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: false)))
        end

        it do
          expect(service.perform).to eq false
        end
      end
    end
  end
end
