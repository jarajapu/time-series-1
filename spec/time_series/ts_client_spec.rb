require 'spec_helper'
require 'time_series'

describe Opower::TimeSeries::TSClient do
  it 'should create object with default options' do
    client = Opower::TimeSeries::TSClient.new
    client.host.should eq '127.0.0.1'
    client.port.should eq 4242
  end

  it 'should create client with specified options' do
    client = Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4343)
    client.configure({:dry_run => true})
    client.host.should eq 'opentsdb.va.opower.it'
    client.port.should eq 4343
    client.config[:dry_run].should be_true
  end

  describe 'should support generating a suggest query' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242) }

    it 'and should return the proper URL in dry run mode' do
      subject.configure({:dry_run => true})
      url = subject.suggest('mtest')
      url.should eq ('http://opentsdb.va.opower.it:4242/suggest?type=metrics&q=mtest')
    end

    it 'and should return an empty array for a query with no expected results' do
      subject.configure({:dry_run => false})
      url = subject.suggest('mtest')
      url.should eq([])
    end

    it 'and should return an empty array for a query with no expected results' do
      url = subject.suggest('sys')
      url.length.should > 1
    end
  end

  describe 'should support inserting metrics' do
    subject { Opower::TimeSeries::TSClient.new }

    before :each do
      config = {:name => 'test1.test2', :timestamp => 12132342, :value => 1, :no_duplicates? => false}
      @metric = Opower::TimeSeries::Metric.new(config)
    end

    it 'and should return the insert string in dry run mode' do
      subject.configure({:dry_run => true})
      call = subject.write(@metric)
      call.should eq ("echo \"put test1.test2 12132342 1 \" | nc -w 30 127.0.0.1 4242")
    end

    it 'and should error on failing to insert data' do
      expect { subject.write(@metric) }.to raise_error(IOError, "Failed to insert metric #{@metric.name} with value of #{@metric.value} into OpenTSDB.")
    end

    it 'and should stop inserting duplicate metrics when specified' do
      client = Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242)
      config = {:name => 'sys.numa.allocation', :timestamp => 12132342, :value => 1, :no_duplicates? => true}
      metric = Opower::TimeSeries::Metric.new(config)
      expect { client.write(metric) }.to raise_error(ArgumentError, 'Duplicate metrics found with no_duplicates flag set.')
    end
  end

  describe 'should support running queries' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242) }

    it 'should raise an error for a bad metric name' do
      m = [{ :aggregator => 'sum', :name => 'mtest'}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      expect { subject.run_query(@query) }.to raise_error(ArgumentError, 'Metric mtest is not registered, check again.')
    end

    it 'should raise an error for a bad tagk name ' do
      metrics = subject.suggest('sys')
      m = [{ :aggregator => 'sum', :name => metrics[0], :tags => {:bad_tagk => 'apsc001.va.opower.it'}}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      expect { subject.run_query(@query) }.to raise_error(ArgumentError, 'Tag Key bad_tagk is not registered, check again.')
    end

    it 'should return a blank string for a query with no expected results' do
      metrics = subject.suggest('sys')
      metrics.should_not be_nil
      m = [{ :aggregator => 'sum', :name => metrics[0]}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should be_nil
    end

    it 'should return data for a query in ASCII format' do
      metrics = subject.suggest('sys')
      m = [{ :aggregator => 'sum', :name => metrics[0], :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :ascii, :start => '2014/01/06-12:15:26', :end => '2014/01/06-12:18:26', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.should match /#{metrics[0]}/
      results.should_not include('Internal Server Error')
    end

    it 'should return data for a query in JSON format' do
      metrics = subject.suggest('sys')
      m = [{ :aggregator => 'sum', :name => metrics[0], :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :json, :start => '2014/01/06-12:15:26', :end => '2014/01/06-12:15:36', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.length.should > 0
      results[0]['metric'].should eq(metrics[0])
      results.should_not include('Internal Server Error')
    end

    it 'should return a URL for a query in PNG format' do
      metrics = subject.suggest('sys')
      m = [{ :aggregator => 'sum', :name => metrics[0], :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :png, :start => '2014/01/06-12:15:26', :end => '2014/01/06-12:15:36', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.should_not include('Internal Server Error')
    end
  end

end