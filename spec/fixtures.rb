require 'yaml'

def fixture(filename)
  File.expand_path("../fixtures/#{filename}", __FILE__)
end

module Opower::TimeSeries::Test
  # Test fixtures
  module Fixtures
    METRICS_CFG = YAML.load(fixture('config/metrics.yaml'))
  end
end
