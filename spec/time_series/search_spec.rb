require 'time_series'
require 'spec_helper'

describe OPOWER::TimeSeries::Search do
  include OPOWER::TimeSeries::Response

  before :each do
    @start = 123456
    @endt = 134567
    @m = "mtest"

    @obj = OPOWER::TimeSeries::Search.new
    @res_class =  OPOWER::TimeSeries::Response
  end

  it "should be able to query for a metric from a host in ascii format" do
    # Query Options
    options = {
               :format => :ascii,
               :start => @start,
               :end => @endt,
               :m => @m
              }
    link = @obj.get_query(options)
    @res_class.url = link
    @res_class.url.should eq link
  end


  it "should be able to query for a metric from a host in json format" do
    # Query Options
    options = {
               :format => :json,
               :start => @start,
               :end => @endt,
               :m => @m
              }
    link = @obj.get_query(options)
    @res_class.url = link
    @res_class.url.should eq link
  end


  it "should be able to query link to a Gnuplot chart in png format" do
    # Query Options
    options = {
               :format => :png,
               :start => @start,
               :end => @endt,
               :m => @m,
               :nocache => true
              }
    link = @obj.get_query(options)
    @res_class.url = link
    @res_class.url.should eq link
  end

end
