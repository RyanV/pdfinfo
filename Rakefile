require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

load File.expand_path('../lib/tasks/generate_fixtures.rake', __FILE__)