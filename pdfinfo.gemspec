# coding: utf-8
require File.expand_path('../lib/pdfinfo/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'pdfinfo'
  spec.version       = Pdfinfo::VERSION
  spec.summary       = %q{Simple ruby wrapper around the pdfinfo executable}
  spec.description   = %q{Simple ruby wrapper around the pdfinfo executable}

  spec.required_ruby_version     = '>= 1.9.3'

  spec.license       = 'MIT'

  spec.author        = 'Ryan Venegas'
  spec.email         = 'rvenegas2@gmail.com'
  spec.homepage      = 'https://github.com/RyanV/pdfinfo'

  spec.files         = %w(lib/pdfinfo.rb)

  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'prawn'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'coveralls'
end
