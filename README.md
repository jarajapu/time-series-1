## Time Series

TimeSeries is a ruby Gem for OpenTSDB that provides a set of core tools for working with an OpenTSDB data store in ruby.

### Installation

Download the gem from our gem server and install it:

    gem install time_series

Alternatively, build it from source and install it
    git clone git@github.va.opower.it:opower/time-series.git
	cd time-series
	gem build time_series.gemspec
	install gem time_series-0.1.0.gem

### Usage

#### Writing to OpenTSDB

To require access to a specific OpenTSDB data store:

	require 'time_series/Put'
	@my_tsdb = OPower::TimeSeries.new({:hostname => "opentsdb.va.opower.it", :port => 4242})

To write a specific metric (that has been registered already with OpenTSDB):

	my_metric = { :metric => 'proc.stat.cpu', :value => 20, :timestamp => Time.now.to_i,
	              :tags => {:host => 'mamamia.va.opower.it', :type => 'iowait'} }

    @my_tsdb.put(my_metric)

#### Reading from OpenTSDB


To spit out link to a GnuPlot chart (the default UI for OpenTSDB 1.1 or prior) in string format:
     require 'time_series/Query'

     link_to_chart = OPower::TimeSeries.Query({:hosts => "apsc001,apsc002",
                                               :nicknamed_metrics => "cpu.iowait,rpts_sec,cpu.user"})

If you do not plan to use the nicknames feature for metrics, you can directly send the metrics list in an array using:

     link_to_chart = OPower::TimeSeries.Query({:metrics =>
                                               ["avg:1m-avg:rate:proc.stat.cpu{host=apsc001.va.opower.it,type=user}",
                                                "max:5m-avg:rate:proc.stat.cpu{host=apsc001.va.opower.it,type=iowait}",
                                                "sum:rate:iostat.disk.msec_total{host=#{host}.va.opower.it}",
                                                "min:proc.loadavg.1min{host=apsc001.va.opower.it}"]
                                               })


To read metrics from the OpenTSDB data store in ascii format:
     require 'time_series/Query'

     values_in_ascii_array = OPower::TimeSeries.Query({:return => ascii,
                                               :metrics =>
                                               ["avg:1m-avg:rate:proc.stat.cpu{host=apsc001.va.opower.it,type=user}",
                                                "max:5m-avg:rate:proc.stat.cpu{host=apsc001.va.opower.it,type=iowait}",
                                                "sum:rate:iostat.disk.msec_total{host=#{host}.va.opower.it}",
                                                "min:proc.loadavg.1min{host=apsc001.va.opower.it}"]
                                                    })

To read metrics from the OpenTSDB data store in json format:
     require 'time_series/json'

     values_in_ascii_array = OPower::TimeSeries.Query({:return => json,
                                                    :metrics =>
                                                    ["avg:1m-avg:rate:proc.stat.cpu{host=apsc001.va.opower.it,type=user}",
                                                     "max:5m-avg:rate:proc.stat.cpu{host=apsc001.va.opower.it,type=iowait}",
                                                     "sum:rate:iostat.disk.msec_total{host=#{host}.va.opower.it}",
                                                     "min:proc.loadavg.1min{host=apsc001.va.opower.it}"]
                                                         })


#### Testing time_series ( ruby gem for reading and writing OpenTSDB )

Test cases should be added for any new code added to this project.
https://github.com/jeremyevans/fixture_dependencies is the project we use to load our test fixtures.
Documentation for creating and loading fixtures can be found at there.

Run tests locally:

    rake spec

