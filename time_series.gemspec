# -*- encoding: utf-8 -*-
# vim: ft=ruby

require File.expand_path('../lib/time_series/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Uday Jarajapu', 'Ravikumar Gudipati', 'Jan Mangs']
  gem.email         = %w(uday.jarajapu@opower.com ravikumar.gudipati@opower.com jan.mangs@opower.com)
  gem.description = %q(Provides a set of tools for working with time series data in OpenTSDB data store)
  gem.summary = %q(OpenTSDB Gem)

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'time_series'
  gem.require_paths = %w(lib)
  gem.version       = Opower::TimeSeries::VERSION

  # dependencies.
  gem.add_dependency('sysexits', '1.0.2')
  gem.add_dependency('awesome_print', '~> 1.1.0')
  gem.add_dependency 'excon', '~> 0.38.0'
  gem.add_dependency 'dentaku', '~> 1.1.1'

  # development dependencies.
  gem.add_development_dependency('rspec', '~> 2.13.0')
  gem.add_development_dependency('simplecov', '~> 0.7.0')
  gem.add_development_dependency('guard', '~> 1.8.0')
  gem.add_development_dependency('guard-rspec', '~> 3.0.1')
  gem.add_development_dependency('rubocop', '~> 0.11.1')
  gem.add_development_dependency('rainbow', '1.1.4')
  gem.add_development_dependency('guard-rubocop', '~> 0.2.1')
  gem.add_development_dependency('metric_fu', '~> 4.2.0')
  gem.add_development_dependency('guard-reek', '~> 0.0.4')
  gem.add_development_dependency('rake', '~> 10.0.1')
  gem.add_development_dependency('yard', '~> 0.8.7')
  gem.add_development_dependency('redcarpet', '~> 2.3.0')
end
