# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::FoldersController, type: :controller do
  describe "POST #create" do
    context "when created folder successfully" do
      include_context :authentication_grant

      subject{ post :create, params: {} }

      it do
      end
    end
  end
end
