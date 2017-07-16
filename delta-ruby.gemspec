# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mee/delta/version'

Gem::Specification.new do |spec|
  spec.name          = "delta-ruby"
  spec.version       = MEE::Delta::VERSION
  spec.authors       = ["Mark Eschbach"]
  spec.email         = ["meschbach@gmail.com"]

  spec.summary       = %q{Ruby Client for the Delta dev proxy}
  spec.description   = %q{Provides a Ruby API for the Delta dev proxy}
  spec.homepage      = "https://github.com/meschbach/delta-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
