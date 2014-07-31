# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beaver/version'

Gem::Specification.new do |spec|
  spec.name          = "beaver"
  spec.version       = Beaver::VERSION
  spec.authors       = ["Simon Morley"]
  spec.email         = ["simon@polkaspots.com"]
  spec.summary       = "First Commit, We Love Beavers"
  spec.description   = "A wrapper to process our many jobs. I' a consumer baby."
  spec.homepage      = "https://github.com/PolkaSpots/beaver/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  # spec.add_dependency "foreman"
  # spec.add_dependency "statsd-ruby"

end
