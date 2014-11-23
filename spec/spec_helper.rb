if ENV['CI'] && Gem.ruby_version >= Gem::Version.create('1.9.3')
  require 'coveralls'
  Coveralls.wear! { add_filter "/spec/" }
end

require File.expand_path('../../lib/pdfinfo', __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec
  config.mock_with :rspec
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = false

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  config.before(:each) do
    Pdfinfo.instance_variable_set(:@pdfinfo_command, nil)
  end

  config.alias_example_to :precondition

  require 'support/fixture_path'
  config.include FixturePath

  require 'support/response_modifier'
  require 'support/rspec_example_group'
  config.extend Pdfinfo::RSpec::ExampleGroup::ClassMethods

  config.before(:each) do |ex|
    allow(Open3).to receive(:capture2).and_wrap_original do |m, command|
      response, status = m.call(command)
      modifier = Pdfinfo::ResponseModifier.new(response)
      response_modification_handler.call(modifier)
      [modifier.to_s, status]
    end
  end
end