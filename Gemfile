source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.4"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"
gem "sprockets-rails"
gem "pg", "~> 1.5.4"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "redis", "~> 4.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "bootsnap", require: false
gem "figaro"
gem "jwt"
gem "bcrypt"
gem "sidekiq"
gem "aws-sdk-s3", require: false
gem "rack-cors"
gem "active_model_serializers"
gem "pagy"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "faker"
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "simplecov"
  gem "rails-controller-testing"
  gem "brakeman"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
