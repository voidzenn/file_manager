# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create :user }

  describe "associations" do
    it{ is_expected.to have_many(:folders) }
  end

  describe "validations" do
    describe "attribute email" do
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

    describe "attribute password" do
      it do
        is_expected.to validate_presence_of(:password)

        is_expected.to allow_value("Password12!").for(:password)
        is_expected.to_not allow_value("pass").for(:password)
        is_expected.to_not allow_value("password").for(:password)
        is_expected.to_not allow_value("passwordddddddddddd").for(:password)
      end
    end

    describe "attribute fname" do
      it do
        is_expected.to validate_presence_of(:fname)
      end
    end

    describe "attribute lname" do
      it do
        is_expected.to validate_presence_of(:lname)
      end
    end
  end
end
