## Time Series

TimeSeries is a ruby Gem for OpenTSDB that provides a set of core tools for working with an OpenTSDB data store in ruby.

### Installation

Download the gem from our gem server and install it:

    gem install time_series

Alternatively, build it from source and install it:

    git clone git@github.va.opower.it:opower/time-series.git
    cd time-series
    gem build time_series.gemspec
    install gem time_series-0.1.0.gem

### Usage

#### Search for a registered metric 

To find whether a specified metric or tag:

        my_tsdb = OPOWER::TimeSeries::Suggest.new('opentsdb.va.opower.it', 4242)

To find a metric:

        my_tsdb.run_suggest('proc.stat.cpu')

To find a tag key:

        my_tsdb.run_suggest('proc.stat.cpu', 'tagk')

To find a tag value:

        my_tsdb.run_suggest('proc.stat.cpu', 'tagv')

#### Writing to OpenTSDB

To require access to a specific OpenTSDB data store:

        my_tsdb = OPOWER::TimeSeries::Save.new('opentsdb.va.opower.it', 4242)

If no hostname and port are specified, this OPower gem defaults to 127.0.0.1:4242

To write a specific metric (that has been registered already with OpenTSDB):

Required: metric and value
Optional: no_dup_allow - default to false

    options = {:metric => 'proc.stat.cpu',
               :timestamp => Time.now.to_i,
               :value => 10,
               :tags => {:host => 'something.va.opower.it', :type => 'iowait'},
               :no_dup_allow => true
              }

    my_tsdb.put(options)


#### Reading from OpenTSDB

     require 'time_series/Search'
     my_tsdb = OPOWER::TimeSeries::Search.new('opentsdb.va.opower.it', 4242)

     # Params (See http://opentsdb.net/http-api.html#/q_Parameters for more information):
     #
     #
     # options a hash which may include the following keys:
     #
     # * format (one of json, ascii, png), defaults to json.
     # * start   The query's start date. (required)
     # * end     The query's end date.
     # * m       The query itself. (required, must be an array)
     #           This is a JSON object contains aggregator, metrics and tags
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

To spit out link to a GnuPlot chart (the default UI for OpenTSDB 1.1 or prior) in string format:

     options = {
                :format => :png,
                :start => '2013-01-01 01:00:00'
                :end => '2013-02-01 01:00:00',
                :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }],
                :nocache => true
               }

     my_tsdb.query(options)


To read metrics from the OpenTSDB data store in ascii format:

     options = {
                :format => :ascii,
                :start => 14535353
                :end => 16786786,
                :m => [{ :aggregator => 'sum', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }]
               }

     my_tsdb.query(options)


To read metrics from the OpenTSDB data store in json format:

     options = {
                :format => :json,
                :start => '3m-ago'
                :m => [{ :aggregator => 'max', :metric => 'proc.stat.cpu', :tags => {:type => 'iowait', :version => 2.1} }],
                :nocache => true
               }

     my_tsdb.query(options)



#### Testing time_series ( ruby gem for reading and writing OpenTSDB )

Test cases should be added for any new code added to this project.
https://github.com/jeremyevans/fixture_dependencies is the project we use to load our test fixtures.
Documentation for creating and loading fixtures can be found at there.

Run tests locally:

    rake spec

