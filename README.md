## Time Series

TimeSeries is a ruby Gem for OpenTSDB that provides a set of core tools for working with an OpenTSDB data store in ruby.

### Installation

Download the gem from our gem server and install it:

    gem install time_series

Alternatively, build it from source and install it:

    git clone git@github.va.opower.it:opower/time-series.git
    cd time-series
    gem build time_series.gemspec
    gem install time_series-0.1.0.gem

### Usage

#### Search for a registered metric/tagk/tagv

First, initialize a connection to an OpenTSDB instance:

```ruby
client = OPOWER::TimeSeries::TSDBClient.new('opentsdb.va.opower.it', 4242)
```

To find suggestions for a metric, tag key, or tag value:

```ruby
client.suggest('proc.stat.cpu') # suggest a metric
client.suggest('proc.stat.cpu', 'tagk') # suggest a tagk
client.suggest('proc.stat.cpu', 'tagv') # suggest a tagv
```

#### Writing to OpenTSDB

First, initialize a connection to an OpenTSDB instance:

```ruby
client = OPOWER::TimeSeries::TSDBClient.new('opentsdb.va.opower.it', 4242)
```

If no hostname and port are specified, this gem defaults to 127.0.0.1:4242

To insert a metric into OpenTSDB, create a new `Metric` object:

```ruby
cfg = {
        :metric => 'proc.stat.cpu',
        :timestamp => Time.now.to_i,
        :value => 10,
        :tags => {:host => 'something.va.opower.it', :type => 'iowait'},
        :no_duplicates? => true
}

metric = OPOWER::TimeSeries::Metric(cfg)
client.write(metric)
```


#### Reading from OpenTSDB

First, initialize a connection to an OpenTSDB instance:

```ruby
client = OPOWER::TimeSeries::TSDBClient.new('opentsdb.va.opower.it', 4242)
```

Then, you can create a query object to run against the specified client:

```ruby
cfg = {
        :format => :png,
        :start => '2013-01-01 01:00:00'
        :end => '2013-02-01 01:00:00',
        :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }],
        :nocache => true
}

query = Opower::TimeSeries::Query.new(cfg)
client.run_query(query)
```
#### Query Configuration

The `Query` object accepts the following parameters:

##### format
Type: `String`
Default value: `json`

Specifies the output format: `ascii`, `json`, `png`.

##### start
Type: `String` / `Integer` / `DateTime`

The query's start date. This is a required field.

#### end
Type: `String` / `Integer` / `DateTime`

The query's end date.

#### m
Type: `Array`

Array of JSON objects with the `aggregator`, `metrics`, and `tags` as fields:

```ruby
:m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }]
```

Other options available to the REST API can be used here as well:

```

 # * o       Rendering options.
 # * wxh     The dimensions of the graph.
 # * yrange  The range of the left Y axis.
 # * y2range The range of the right Y axis.
 # * ylabel  Label for the left Y axis.
 # * y2label Label for the right Y axis.
 # * yformat Format string for the left Y axis.
 # * y2formatFormat string for the right Y axis.
 # * ylog    Enables log scale for the left Y axis.
 # * y2log   Enables log scale for the right Y axis.
 # * key     Options for the key (legend) of the graph.
 # * nokey   Removes the key (legend) from the graph.
 # * nocache Forces TSD to ignore cache and fetch results from HBase.

```

See the [OpenTSDB documentation](http://opentsdb.net/http-api.html#/q_Parameters) for more information.


#### Example Queries

```ruby
cfg = {
        :format => :ascii,
        :start => 14535353
        :end => 16786786,
        :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }]
}

query = Opower::TimeSeries::Query.new(cfg)
client.run_query(query)
```

```ruby
cfg = {
        :format => :json,
        :start => '3m-ago'
        :m => [{ :aggregator => 'max', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }],
        :nocache => true
}

query = Opower::TimeSeries::Query.new(cfg)
client.run_query(query)
```

#### Testing time_series ( ruby gem for reading and writing OpenTSDB )

Test cases should be added for any new code added to this project.

Run tests locally:

```
rake spec
```

#### Generating Documentation

To generate the documentation for this gem, run the following:

```
yard doc
```