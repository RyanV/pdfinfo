require 'pathname'

module FixturePath
  def fixture_path(path)
    Pathname.new(File.expand_path(File.join('../../fixtures', path.to_s), __FILE__))
  end
  alias_method :fixture, :fixture_path
end