# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdfinfo/version'

Gem::Specification.new do |spec|
  spec.name          = "pdfinfo"
  spec.version       = Pdfinfo::VERSION
  spec.authors       = ["Ryan Venegas"]
  spec.email         = ["RVenegas2@Gmail.com"]
  spec.summary       = %q{Simple ruby wrapper around the pdfinfo executable}
  spec.description   = %q{Simple ruby wrapper around the pdfinfo executable}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "prawn"
  spec.add_development_dependency "rspec", '~> 3.1.0'
  spec.add_development_dependency "rake"
end
