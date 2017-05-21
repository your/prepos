# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task :spec do
  RSpec::Core::RakeTask.new(:spec)
end

task :rubocop do
  require 'rubocop'

  cli = RuboCop::CLI.new
  cli.run
end

task spec: [:rubocop]
task default: [:rubocop, :spec]
