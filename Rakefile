require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
end


load File.expand_path('../lib/tasks/generate_fixtures.rake', __FILE__)