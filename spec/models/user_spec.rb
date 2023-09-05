# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create :user }

  describe "validations" do
    describe "#email" do
      it do
        is_expected.to validate_presence_of(:email)
        is_expected.to validate_uniqueness_of(:email).case_insensitive

        is_expected.to allow_value("user@example.com").for(:email)
        is_expected.to allow_value("user+label@example.com").for(:email)
        is_expected.to allow_value("user.lastname@example.co.us").for(:email)
        is_expected.to_not allow_value("invalid_email").for(:email)
        is_expected.to_not allow_value("user@").for(:email)
        is_expected.to_not allow_value("@example.com").for(:email)
        is_expected.to_not allow_value("user@example..com").for(:email)
      end
    end

    describe "#password" do
      it do
        is_expected.to validate_presence_of(:email)
      end
    end

    describe "#fname" do
      it do
        is_expected.to validate_presence_of(:fname)
      end
    end

    describe "#lname" do
      it do
        is_expected.to validate_presence_of(:lname)
      end
    end
  end
end
