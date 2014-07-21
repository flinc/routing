# -*- encoding: utf-8 -*-
require File.expand_path('../lib/routing/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Christian Bäuerlein", "Benedikt Deicke"]
  gem.email         = ["christian@ffwdme.com", "benedikt@synatic.net"]
  gem.summary       = %q{A ruby interface for route calculation services}
  gem.description   = %q{
    Provides a generic interface for routing services that can by used to calculate directions between geolocations.
    Makes parsing and use-case specific data handling easy trough an extendable middleware stack.
  }
  gem.homepage      = "https://github.com/flinc/routing"

  gem.add_dependency "faraday", ">= 0.7.0"
  gem.add_dependency "json"
  gem.add_development_dependency "rspec", ">= 2.9.0"
  gem.add_development_dependency "rake"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "routing"
  gem.require_paths = ["lib"]
  gem.version       = Routing::VERSION
end
