


module OPower
  module TimeSeries

  class Dao
    attr_accessor :connect_options

    def initialize(options = {})
      opts = {
               :hostname => 'opentsdb.va.opower.it',
               :port => 4242
             }.merge(options)

      @connect_options = opts
    end
  end

  end
end
