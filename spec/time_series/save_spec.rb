require 'spec_helper'
require 'time_series'

describe OPOWER::TimeSeries::Save do

  before :each do
    @obj = OPOWER::TimeSeries::Save.new
  end

  it "should be able to save a metric" do
    options = {:metric => 'test1.test2',
               :timestamp => 12132342,
               :value => 1,
               :tags => {'x' => 1, 'y' => 2},
               :no_dup_allow => false
              }

    @obj.data = options
    @obj.save_params.should eq options
  end

end
