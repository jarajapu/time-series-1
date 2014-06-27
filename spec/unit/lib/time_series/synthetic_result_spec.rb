# -*- encoding: utf-8 -*-

require 'time_series'
require 'spec_helper'

describe Opower::TimeSeries::SyntheticResult do
  it 'should calculate valid results for aligned time-series' do
    formula = 'x + y'
    data = { x: { '123' => 1, '124' => 2 }, y: { '123' => 1, '124' => 2, '125' => 3 } }

    synthetic_results = Opower::TimeSeries::SyntheticResult.new('test', formula, data)
    calculated_dps = synthetic_results.results
    calculated_dps['123'].should eq(2)
    calculated_dps['124'].should eq(4)
    calculated_dps['125'].should be_nil
  end

  it 'should calculate valid results for aligned time-series using Ruby math functions' do
    formula = 'cos((x + y))'
    data = { x: { '123' => 1, '124' => 2 }, y: { '123' => 1, '124' => 2, '125' => 3 } }

    synthetic_results = Opower::TimeSeries::SyntheticResult.new('test', formula, data)
    calculated_dps = synthetic_results.results
    calculated_dps['123'].should eq(-0.4161468365471424)
    calculated_dps['124'].should eq(-0.6536436208636119)
    calculated_dps['125'].should be_nil
  end

  it 'should stop calculating when exceptions are thrown' do
    formula = 'x / y'
    data = { x: { '123' => 10, '124' => 20, '125' => 30 }, y: { '123' => 1, '124' => 0, '125' => 3 } }

    expect { Opower::TimeSeries::SyntheticResult.new('test', formula, data) }.to raise_error(ZeroDivisionError)
  end
end
