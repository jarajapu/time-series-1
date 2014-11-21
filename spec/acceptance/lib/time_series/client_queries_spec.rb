# -*- encoding: utf-8 -*-

require 'spec_helper'
require 'time_series'

describe Opower::TimeSeries::TSClient do
  describe 'should support generating a suggest query' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242) }

    it 'and should return the proper URL in dry run mode' do
      subject.configure(dry_run: true)
      url = subject.suggest('mtest')
      url.should eq('http://opentsdb.va.opower.it:4242/api/suggest?type=metrics&q=mtest')
    end

    it 'and should return an empty array for a query with no expected results' do
      subject.configure(dry_run: false)
      suggestions = subject.suggest('mtest')
      suggestions.should eq([])
    end

    it 'and should return an empty array for a query with expected results' do
      subject.configure(dry_run: false)
      suggestions = subject.suggest('sys')
      suggestions.should_not eq([])
    end
  end

  describe 'should support inserting metrics' do
    subject { Opower::TimeSeries::TSClient.new }

    before :each do
      config = { name: 'test1.test2', timestamp: 12_132_342, value: 1 }
      @metric = Opower::TimeSeries::Metric.new(config)
    end

    it 'and should return the insert string in dry run mode' do
      subject.configure(dry_run: true)
      call = subject.write(@metric)
      call.should eq("echo \"put test1.test2 12132342 1 \" | nc -w 30 127.0.0.1 4242")
    end

    it 'and should error on failing to insert data' do
      message = "Failed to insert metric #{@metric.name} with value of #{@metric.value} into OpenTSDB."
      expect { subject.write(@metric) }.to raise_error(IOError, message)
    end
  end

  describe 'should support running queries in OpenTSDB 2.0' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242) }

    before :each do
      @metric_name = subject.suggest('sys')[0]
    end

    it 'should raise an error for a bad metric name' do
      m = [{ metric: 'mtest' }]
      config = { format: :json, start: '2009/01/04-12:15:26', end: '2009/01/05-12:15:26', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query).results

      results['error'].should_not be_nil
      results['error']['message'].should eq("No such name for 'metrics': 'mtest'")
    end

    it 'should raise an error for a bad tagk name ' do
      m = [{ metric: @metric_name, tags: { bad_tagk: 'apsc001.va.opower.it' } }]
      config = { format: :json, start: '2009/01/04-12:15:26', end: '2009/01/05-12:15:26', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query).results
      results['error']['message'].should eq("No such name for 'tagk': 'bad_tagk'")
    end

    it 'should return an empty JSON array for a query with no expected results' do
      m = [{ metric: @metric_name }]
      config = { format: :json, start: '2009/01/04-12:15:26', end: '2009/01/05-12:15:26', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query).results
      results.should eq([])
    end

    it 'should return data for a query in JSON format' do
      m = [{ metric: @metric_name, tags: { host: 'apsc002.va.opower.it' } }]
      config = { format: :json, start: '1h-ago', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query).results
      results.should_not eq([])
      results[0]['metric'].should eq(@metric_name)
    end

    it 'should return an error for invalid queries in JSON format' do
      m = [{ metric: @metric_name, tags: { host: 'apsc002.va.opower.it' } },
           { metric: @metric_name, tags: { bad_tagk: 'apsc001.va.opower.it' } }]
      config = { format: :json, start: '1h-ago', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      response = subject.run_query(@query)
      response.errors?.should be_true
      response.error_message.should eq("No such name for 'tagk': 'bad_tagk'")
    end

    it 'should return data for a rate query in JSON format' do
      metrics = subject.suggest('sys')
      m = [{ metric: metrics[0], rate: true, tags: { host: 'apsc002.va.opower.it' } }]
      config = { format: :json, start: '1h-ago', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query).results
      results.should_not eq([])
      results[0]['metric'].should eq(metrics[0])
    end

    it 'should return a URL for a query in PNG format' do
      m = [{ metric: @metric_name, tags: { host: 'apsc001.va.opower.it' } }]
      config = { format: :png, start: '1h-ago', m: m }
      @query = Opower::TimeSeries::Query.new(config)
      results = subject.run_query(@query)
      results.should_not eq('')
      results.should_not include('Internal Server Error')
    end

    it 'should return data for multiple queries' do
      queries = []
      3.times do
        m = [{ metric: @metric_name, tags: { host: 'apsc001.va.opower.it' } }]
        config = { format: :json, start: '1h-ago', m: m }
        queries << Opower::TimeSeries::Query.new(config)
      end

      results = subject.run_queries(queries)
      results.length.should eq(3)
      results.each do |r|
        r.results.should_not eq('')
      end
    end
  end

  describe 'should support running synthetic queries' do
    subject { Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242) }

    before :each do
      suggestions = subject.suggest('sys')
      @metric_name_one = suggestions[0]
      @metric_name_two = suggestions[1]
    end

    it 'should compute a simple formula correctly' do
      m = [{ metric: @metric_name_one, tags: { host: 'apsc002.va.opower.it' } }]
      config = { format: :json, start: '1h-ago', m: m }
      @query_one = Opower::TimeSeries::Query.new(config)

      m = [{ metric: @metric_name_two, tags: { host: 'apsc002.va.opower.it' } }]
      config = { format: :json, start: '1h-ago', m: m }
      @query_two = Opower::TimeSeries::Query.new(config)

      synthetic_results = subject.run_synthetic_query('test', 'x / y', x: @query_one, y: @query_two)
      synthetic_results.length.should_not eq(0)
    end
  end
end
