# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "databasedotcom/rails/version"

Gem::Specification.new do |s|
  s.name        = "databasedotcom-rails"
  s.version     = Databasedotcom::Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Danny Burkes"]
  s.email       = ["dburkes@netable.com"]
  s.homepage    = "http://github.com/dburkes/databasedotcom-rails"
  s.summary     = %q{Convenience classes to make using the databasedotcom gem with Rails apps even easier}
  s.description = %q{Convenience classes to make using the databasedotcom gem with Rails apps even easier}

  s.files         = Dir['README.md', 'MIT-LICENSE', 'lib/**/*']
  s.require_paths = ["lib"]
  s.add_dependency('databasedotcom')
  s.add_development_dependency('rspec', '2.6.0')
  s.add_development_dependency('rake', '0.8.6')
end
