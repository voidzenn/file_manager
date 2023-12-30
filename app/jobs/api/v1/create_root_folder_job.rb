# frozen_string_literal: true

class Api::V1::CreateRootFolderJob < ApplicationJob
  queue_as :default

  def perform user_token, path_name
    @result = Api::V1::CreateFolderMinioService.new(
      user_token,
      path_name
    ).perform
  end

  after_perform do |job|
    puts "Processed data: #{@result}"
  end
end
