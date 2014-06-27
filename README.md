## Time Series

TimeSeries is a ruby Gem for OpenTSDB that provides a set of core tools for working with an OpenTSDB data store in ruby.

### Installation

Download the gem from our gem server and install it:

    gem install time_series

Alternatively, build it from source and install it:

    git clone git@github.va.opower.it:opower/time-series.git
    cd time-series
    gem build time_series.gemspec
    gem install time_series-2.0.0.gem

### Usage

#### Configuration

```ruby
client = Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242)
client.configure({ :version => 2.0, :dry_run => false, :validation => true })
```

The following options are supported:

##### version
Default value: `2.0`
Type: `String`
Values: `2.0`, `2.1`

The version of TSBD to run against. If you wish to use the new 2.0 endpoints, set version to 2.0 or higher.

##### dry_run
Default value: `false`
Type: `Boolean`

If set to true, this gem will not run any commands, only output the generated URLs or calls to OpenTSDB.

#### Search for a registered metric/tagk/tagv

First, initialize a connection to an OpenTSDB instance:

```ruby
client = Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242)
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
client = Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242)
```

If no hostname and port are specified, this gem defaults to 127.0.0.1:4242

To insert a metric into OpenTSDB, create a new `Metric` object:

```ruby
metric_config = {
        :name => 'proc.stat.cpu',
        :timestamp => Time.now.to_i,
        :value => 10,
        :tags => {:host => 'something.va.opower.it', :type => 'iowait'}
}

metric = Opower::TimeSeries::Metric.new(metric_config)
client.write(metric)
```


#### Reading from OpenTSDB

First, initialize a connection to an OpenTSDB instance:

```ruby
client = Opower::TimeSeries::TSClient.new('opentsdb.va.opower.it', 4242)
```

Then, you can create a query object to run against the specified client:

```ruby
query_config = {
        :format => :png,
        :start => '2013/01/01-01:00:00',
        :end => '2013/02/01-01:00:00',
        :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait'} }],
        :nocache => true
}

query = Opower::TimeSeries::Query.new(query_config)
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
query_config = {
        :format => :ascii,
        :start => 14535353,
        :end => 16786786,
        :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :rate => true, :tags => {:type => 'iowait'} }]
}

query = Opower::TimeSeries::Query.new(query_config)
client.run_query(query)
```

```ruby
query_config = {
        :format => :json,
        :start => '3m-ago',
        :m => [{ :aggregator => 'max', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait'} }],
        :nocache => true
}

query = Opower::TimeSeries::Query.new(query_config)
client.run_query(query)
```

#### Running Multiple Queries Simultaneously

If you need to query multiple metrics at the same time, time-series provides support for that as well:

```ruby
queries = []
3.times do
    query_config = {
            :format => :ascii,
            :start => 14535353,
            :end => 16786786,
            :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :rate => true, :tags => {:type => 'iowait'} }]
    }

    queries << Opower::TimeSeries::Query.new(query_config)
end

client.run_queries(queries)
```

#### Running Synthetic Metric Queries

time_series also provides the capability to create synthetic metrics through the use of a formula and any number of queries against OpenTSDB.

```ruby
metric_x = [{ metric: 'sys.numa.allocation', tags: { host: 'apsc001.va.opower.it' } }]
query_config_x = { format: :json, start: '1h-ago', m: metric_x }
@query_metric_x = Opower::TimeSeries::Query.new(query_config_x)

metric_y = [{ metric: 'sys.numa.foreign_allocs', tags: { host: 'apsc001.va.opower.it' } }]
query_config_y = { format: :json, start: '1h-ago', m: metric_y }
@query_metric_y = Opower::TimeSeries::Query.new(query_config_y)

name = 'My Synthetic Metric Alias'
formula = 'x + y'
query_hash = { x: @query_metric_x, y: @query_metric_y }
client.run_synthetic_query(name, formula, query_hash)
```
This example creates a formula which adds `x + y` and feeds the calculation with data from OpenTSDB. You need to pass in a hash where the key maps to the parameters in the formula with their corresponding values consisting of a Query object. When the calculation is performed, it will only operate on matching timestamps currently. If there are no matching data-points, it will return nothing.

For more information about what can be done with the formula parameters, read the documentation for the [Dentaku Calculator](https://github.com/rubysolo/dentaku). This gem expects any parameter in the formula to have a matching query in the query hash.

##### Built-in Ruby Math support

```ruby
name = 'My Synthetic Metric Alias'
formula = 'cos(x) + y'
query_hash = { x: @query_metric_x, y: @query_metric_y }
client.run_synthetic_query(name, formula, query_hash)
```

Formulas in time-series can use all of the basic methods provided by the Math module from Ruby.

NOTE: You must wrap nested mathematical expressions in formulas or Dentaku will attempt to pass them as separate arguments into the lambda below!

For example:
Assume x = 1, y = 2
 - cos(x + y) is translated into cos(1, 'add', 2) - this calls Math.cos(1, 'add', 2) - this obviously throws an error
 - cos((x + y)) is translated into cos(3) - this correctly calls Math.cos(3)

This is due to the way Dentaku handles the order of precedence; unless you wrap nested arguments, it will pass them separately.

#### Testing time_series

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
