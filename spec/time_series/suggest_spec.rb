require 'spec_helper'
require 'time_series'

describe OPOWER::TimeSeries::Suggest do
  include OPOWER::TimeSeries::Response

  before :each do
    @sobj = OPOWER::TimeSeries::Suggest.new
    @res_class =  OPOWER::TimeSeries::Response
  end

  it "should create suggest object" do
    @sobj.host.should eq '127.0.0.1'
    @sobj.port.should eq 4242 
  end

  it "should return metrics for a given metric" do
    link = @sobj.get_suggest('loadtest.ei', 'metrics')
    @res_class.url = link
    @res_class.url.should eq link
  end


  it "should return tag keys for a given tag" do
    link = @sobj.get_suggest('build', 'tagk')
    @res_class.url = link
    @res_class.url.should eq link
  end

  it "should return tag values for a given tag" do
    link = @sobj.get_suggest('3.1', 'tagv')
    @res_class.url = link
    @res_class.url.should eq link
  end
end

