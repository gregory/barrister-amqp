# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'barrister/amqp/version'

Gem::Specification.new do |spec|
  spec.name          = "barrister-amqp"
  spec.version       = Barrister::Amqp::VERSION
  spec.authors       = ["gregory"]
  spec.email         = ["greg2502@gmail.com"]
  spec.summary       = %q{AMQP transport and server-container for Barrister}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bunny", "~> 2.2.2"
  spec.add_dependency 'barrister', '~> 0'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "> 0"
end
