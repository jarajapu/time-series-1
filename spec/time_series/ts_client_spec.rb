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
      subject.configure({:dry_run => false, :version => 1.1})
      url = subject.suggest('mtest')
      url.should eq([])
    end

    it 'and should return an empty array for a query with no expected results' do
      url = subject.suggest('sys')
      url.length.should >= 1
    end
  end

  describe 'should support inserting metrics' do
    subject { Opower::TimeSeries::TSClient.new }

    before :each do
      config = {:name => 'test1.test2', :timestamp => 12132342, :value => 1}
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
  end

  describe 'should support running queries in OpenTSDB 1.0' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242) }

    before :each do
      subject.configure({ :version => 1.1 })
      @metric_name = subject.suggest('sys')[0]
    end

    it 'should raise an error for a bad metric name' do
      m = [{ :aggregator => 'sum', :metric => 'mtest'}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      expect { subject.run_query(@query) }.to raise_error(ArgumentError, 'Metric mtest is not registered, check again.')
    end

    it 'should raise an error for a bad tagk name ' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:bad_tagk => 'apsc001.va.opower.it'}}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      expect { subject.run_query(@query) }.to raise_error(ArgumentError, 'Tag Key bad_tagk is not registered, check again.')
    end

    it 'should return a blank string for a query with no expected results' do
      m = [{ :aggregator => 'sum', :metric => @metric_name}]
      config = { :format => :ascii, :start => '2010/01/06-12:15:26', :end => '2010/01/06-12:16:26', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should be_nil
    end

    it 'should return data for a query in ASCII format' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :ascii, :start => 1389031881, :end => 1389031882, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should match /#{@metric_name}/
      results.should_not include('Internal Server Error')
    end

    it 'should return data for a query in JSON format' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :json, :start => 1389031881, :end => 1389031882, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.length.should > 0
      results[0]['metric'].should eq(@metric_name)
      results.should_not include('Internal Server Error')
    end

    it 'should return a URL for a query in PNG format' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :png, :start => '2014/01/06-12:15:26', :end => '2014/01/06-12:15:36', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.should_not include('Internal Server Error')
    end
  end

  describe 'should support running queries in OpenTSDB 2.0' do
    subject { Opower::TimeSeries::TSClient.new('prod-tsd-ingester-1001.va.opower.it', 4242) }

    before :each do
      @metric_name = subject.suggest('sys')[0]
    end

    it 'should raise an error for a bad metric name' do
      m = [{ :aggregator => 'sum', :metric => 'mtest'}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      expect { subject.run_query(@query) }.to raise_error(ArgumentError, 'Metric mtest is not registered, check again.')
    end

    it 'should raise an error for a bad tagk name ' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:bad_tagk => 'apsc001.va.opower.it'}}]
      config = { :format => :ascii, :start => 123456, :end => 134567, :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      expect { subject.run_query(@query) }.to raise_error(ArgumentError, 'Tag Key bad_tagk is not registered, check again.')
    end

    it 'should return an empty JSON array for a query with no expected results' do
      m = [{ :aggregator => 'sum', :metric => @metric_name}]
      config = { :format => :json, :start => '2009/01/04-12:15:26', :end => '2009/01/05-12:15:26', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should eq([])
    end

    it 'should return data for a query in ASCII format' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :ascii, :start => '1h-ago', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.should match /#{@metric_name}/
      results.should_not include('Internal Server Error')
    end


    it 'should return data for a query in JSON format' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :json, :start => '1h-ago', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq([])
      results.length.should > 0
      results[0]['metric'].should eq(@metric_name)
    end

    it 'should return data for a rate query in JSON format' do
      metrics = subject.suggest('sys')
      m = [{ :aggregator => 'sum', :metric => metrics[0], :rate => true, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :json, :start => '1h-ago', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq([])
      results.length.should > 0
      results[0]['metric'].should eq(metrics[0])
    end

    it 'should return a URL for a query in PNG format' do
      m = [{ :aggregator => 'sum', :metric => @metric_name, :tags => {:host => 'apsc001.va.opower.it'}}]
      config = { :format => :png, :start => '1h-ago', :m => m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.should_not include('Internal Server Error')
    end
  end

end