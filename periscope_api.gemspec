# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'periscope_api/version'

Gem::Specification.new do |spec|
  spec.name          = "periscope_api"
  spec.version       = PeriscopeApi::VERSION
  spec.authors       = ["Gabriel Gironda"]
  spec.email         = ["gabriel@gironda.org"]
  spec.summary       = %q{Rudimentary Periscope API client.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "oauth"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "faraday_middleware"
  spec.add_runtime_dependency "pubnub"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "httplog"
  spec.add_development_dependency "pry"
end
