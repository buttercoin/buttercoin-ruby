# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buttercoin/version'

Gem::Specification.new do |gem|
  gem.name          = "buttercoin"
  gem.version       = Buttercoin::VERSION
  gem.authors       = ["Kevin Adams"]
  gem.email         = ["kevin@buttercoin.com"]
  gem.description   = ["Ruby Gem to connect to the Buttercoin API"]
  gem.summary       = ["Buttercoin API Ruby SDK"]
  gem.homepage      = "https://developer.buttercoin.com/"
  gem.license 	    = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "simplecov", "~> 0.9.0", ">= 0.9.0"
  gem.add_development_dependency "fakeweb", "~> 1.3", ">= 1.3"

  gem.add_dependency "httparty", "~> 0.13.1", ">= 0.13.1"
  gem.add_dependency "hashie", "~> 3.2.0", ">= 3.2.0"
end
