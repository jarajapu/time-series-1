require 'spec_helper'
require 'time_series'

describe Opower::TimeSeries::Metric do

  it 'should be to initialize itself correctly' do
    config = {:name => 'test1.test2', :timestamp => 12132342, :value => 1, :tags => {'x' => 1, 'y' => 2}}

    metric = Opower::TimeSeries::Metric.new(config)
    metric.name.should eq('test1.test2')
    metric.timestamp.should eq(12132342)
    metric.value.should eq(1)
    metric.tags.should eq({'x' => 1, 'y' => 2})
  end

  it 'should throw an error if no data is specified' do
    expect { Opower::TimeSeries::Metric.new }.to raise_error(ArgumentError, 'No data is available to write into TSDB.')
  end

  it 'should throw an error if no metric name is specified' do
    expect { Opower::TimeSeries::Metric.new({:value => 1}) }.to raise_error(ArgumentError, 'name is required to write into TSDB.')
  end

  it 'should throw an error if no metric value is specified' do
    expect { Opower::TimeSeries::Metric.new({:name => '123'}) }.to raise_error(ArgumentError, 'value is required to write into TSDB.')
  end

end

