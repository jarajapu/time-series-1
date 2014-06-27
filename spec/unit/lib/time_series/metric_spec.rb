# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'time_series'

describe Opower::TimeSeries::Metric do
  subject(:config) { { name: 'test1.test2', timestamp: 12_132_342, value: 1, tags: { 'x' => 1, 'y' => 2 } } }

  describe 'should be to initialize itself correctly' do
    subject { Opower::TimeSeries::Metric.new(config) }

    its(:name) { should eq('test1.test2') }
    its(:timestamp) { should eq(12_132_342) }
    its(:value) { should eq(1) }
    its(:tags) { should eq('x' => 1, 'y' => 2) }
  end

  it 'should throw an error if no data is specified' do
    expect { Opower::TimeSeries::Metric.new }.to raise_error(ArgumentError)
  end

  it 'should throw an error if no metric name is specified' do
    expect { Opower::TimeSeries::Metric.new(value: 1) }.to raise_error(ArgumentError)
  end

  it 'should throw an error if no metric value is specified' do
    expect { Opower::TimeSeries::Metric.new(name: '123') }.to raise_error(ArgumentError)
  end
end
