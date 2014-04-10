$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "connect/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "connect"
  s.version     = Connect::VERSION
  s.authors     = ["John Laxson"]
  s.email       = ["john.laxson@redcross.org"]
  s.homepage    = "http://github.com/jlaxson/openid-connect-engine"
  s.summary     = "Rails Engine providing complete framework for OpenID Connect"
  s.description = "Rails Engine providing complete framework for OpenID Connect"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency 'squeel', "~> 1.1"
  s.add_dependency 'openid_connect'
  s.add_dependency 'rack-oauth2'
  #s.add_dependency 'validate_url'
  #s.add_dependency 'validate_email'
  s.add_dependency 'html5_validators'
end
