# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CreateUserRootFolderService do
  describe "#perform" do
    context "when create user root folder successfully" do
      let(:user_id) { 1 }
      let(:service) { described_class.new(user_id) }

      before do
        allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: double(put: true)))
        allow(service).to receive(:initialize_bucket).and_call_original
        allow(service).to receive(:create_folder).and_call_original
      end

      it do
        expect(service.perform).to eq true
        expect(service).to have_received(:initialize_bucket)
        expect(service).to have_received(:create_folder)
      end
    end

    context "when create user root folder fails" do
      context "when user_id is not numeric value" do
        let(:user_id) { "invalid" }
        let(:service) { described_class.new(user_id) }

        before do
          allow_any_instance_of(Aws::S3::Resource).to receive(:bucket).and_return(double(object: (double(put: true))))
        end

        it do
          expect(service.perform).to be_nil
        end
      end
    end
  end
end
