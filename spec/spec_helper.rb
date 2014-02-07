require 'rspec'
require 'simplecov'

SimpleCov.start 'rails' do
  coverage_dir 'metrics/coverage'
end

RSpec.configure do |config|
  config.mock_with :mocha
end
