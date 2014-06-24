# -*- encoding: utf-8 -*-

require 'time_series'
require 'spec_helper'

describe Opower::TimeSeries::Query do
  @aggregator_msg = 'Aggregator and metric label must be present for query to run.'

  it 'should throw an error on trying to create an query without a start parameter' do
    m = [{ aggregator: 'sum', metric: 'mtest' }]
    config = { format: :ascii, end: 134_567, m: m }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, 'start is a required parameter.')
  end

  it 'should throw an error on trying to create an query without a m parameter' do
    config = { format: :ascii, start: 123_456, end: 134_567 }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, 'm is a required parameter.')
  end

  it 'should throw an error on trying to create an query when passing a non-array m parameter' do
    config = { format: :ascii, start: 123_456, end: 134_567, m: '123' }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, 'm parameter must be an array.')
  end

  it 'should throw an error on trying to create an query when passing an empty array m parameter' do
    config = { format: :ascii, start: 123_456, end: 134_567, m: [] }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, 'm parameter must not be empty.')
  end

  it 'should throw an error on trying to create an query when missing aggregator and metric label' do
    config = { format: :ascii, start: 123_456, end: 134_567, m: [{}] }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, @aggregator_msg)
  end

  it 'should throw an error on trying to create an query when missing aggregator label' do
    config = { format: :ascii, start: 123_456, end: 134_567, m: [{ metric: 'sum' }] }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, @aggregator_msg)
  end

  it 'should throw an error on trying to create an query when missing metric label' do
    config = { format: :ascii, start: 123_456, end: 134_567, m: [{ aggregator: 'sum' }] }
    expect { Opower::TimeSeries::Query.new(config) }.to raise_error(ArgumentError, @aggregator_msg)
  end

  it 'should be able to query for a metric from a host in ASCII format' do
    m = [{ aggregator: 'sum', metric: 'mtest' }]
    config = { format: :ascii, start: 123_456, end: 134_567, m: m }
    query = Opower::TimeSeries::Query.new(config)
    query.config.should eq(config)
    query.format.should eq('ascii')
  end
end
