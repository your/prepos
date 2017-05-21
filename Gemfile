# frozen_string_literal: true
source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

gem 'octokit', '~> 4.0'

group :development do
  gem 'pry', require: false
  gem 'rubocop', require: false
end

group :test do
  gem 'rake', '~> 11.2'
  gem 'rspec', '~> 3.6'
  gem 'vcr', '~> 3.0', require: false
  gem 'webmock', '~> 3.0', require: false
end
