# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'time_series/version'

Gem::Specification.new do |s|
  s.name = 'time_series'
  s.version = Opower::TimeSeries::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Uday Jarajapu', 'Ravikumar Gudipati', 'Jan Mangs']
  s.email = ['uday.jarajapu@opower.com', 'ravikumar.gudipati@opower.com', 'jan.mangs@opower.com']
  s.homepage = 'https://github.va.opower.it/opower/time-series'
  s.summary = %q{OPower OpenTSDB tools}
  s.description = %q{Provides a set of tools for working with time series data in OpenTSDB data store}

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.14.1'
  s.add_development_dependency 'mocha', '= 0.10.4'
  s.add_development_dependency 'httparty', '= 0.11.0'
  s.add_development_dependency 'simplecov', '= 0.8.2'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'redcarpet'
  s.add_dependency 'rake'
end
