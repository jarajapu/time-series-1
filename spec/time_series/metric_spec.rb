# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'time_series'

describe Opower::TimeSeries::Metric do

  it 'should be to initialize itself correctly' do
    config = { name: 'test1.test2', timestamp: 12_132_342, value: 1, tags: { 'x' => 1, 'y' => 2 } }

    metric = Opower::TimeSeries::Metric.new(config)
    metric.name.should eq('test1.test2')
    metric.timestamp.should eq(12_132_342)
    metric.value.should eq(1)
    metric.tags.should eq('x' => 1, 'y' => 2)
  end

  it 'should throw an error if no data is specified' do
    msg = 'No data is available to write into TSDB.'
    expect { Opower::TimeSeries::Metric.new }.to raise_error(ArgumentError, msg)
  end

  it 'should throw an error if no metric name is specified' do
    msg = 'name is required to write into TSDB.'
    expect { Opower::TimeSeries::Metric.new(value: 1) }.to raise_error(ArgumentError, msg)
  end

  it 'should throw an error if no metric value is specified' do
    msg = 'value is required to write into TSDB.'
    expect { Opower::TimeSeries::Metric.new(name: '123') }.to raise_error(ArgumentError, msg)
  end
end
