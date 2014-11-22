require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
end


# TODO - re-add generate_fixtures task
# load File.expand_path('../tasks/generate_fixtures.rake', __FILE__)