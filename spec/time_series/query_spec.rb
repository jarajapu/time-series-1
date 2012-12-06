require_relative '../spec_helper'
require 'time_series/query'


describe OPower::TimeSeries::Query do

  before :each do


  end

  it "should be able to construct a free-form query" do

    q = OPower::TimeSeries::Query.new(:query => "q?start=2012/05/24-15:45:00&end=2012/05/24-16:45:40&
                             m=sum:rate:proc.stat.cpu{host=dbsc002.va.opower.it,type=user}&ascii")
    q.class.should == "Query"

  end

  it "should be able to query for a metric from a host in ascii format" do

  end


  it "should be able to query for a metric from a host in json format" do

  end


  it "should be able to query link to a Gnuplot chart in png format" do

  end

end