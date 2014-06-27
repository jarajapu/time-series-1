# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'time_series'

describe Opower::TimeSeries::TSClient do
  describe 'should create object with default options' do
    subject { Opower::TimeSeries::TSClient.new }

    its(:host) { should eq '127.0.0.1' }
    its(:port) { should eq 4242 }
  end

  describe 'should create client with specified options' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4343) }

    its(:host) { should eq 'opentsdb.va.opower.it' }
    its(:port) { should eq 4343 }
  end

  describe 'should have default configuration settings' do
    subject { Opower::TimeSeries::TSClient.new.config }

    its ([:dry_run]) { should eq(false) }
    its ([:version]) { should eq('2.0') }
  end

  describe 'should have allow the user to override default configuration settings' do
    subject do
      client = Opower::TimeSeries::TSClient.new
      client.configure({ dry_run: true, validation: true, version: '2.1' })
      client.config
    end

    its ([:dry_run]) { should eq(true) }
    its ([:version]) { should eq('2.1') }
  end
end
