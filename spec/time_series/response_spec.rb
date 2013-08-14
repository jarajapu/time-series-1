require 'spec_helper'
require 'time_series'

describe OPOWER::TimeSeries::Response do

  before :each do
    @res = OPOWER::TimeSeries::Response
  end

  it "should save and return url" do
    url = "http://testurl/"
    @res.url = url
    @res.url.should == url
  end

end
