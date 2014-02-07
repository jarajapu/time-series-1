module Opower
  module TimeSeries
    # Represents a metric that can be inserted into OpenTSDB instance through a [TSDBClient] object.
    class Metric
      attr_reader :name, :value, :timestamp, :tags

      # Initializer for the Metric class.
      #
      # @param [Hash] config configuration hash consisting of the following values:
      # @option config [String] :name The metric name (required)
      # @option config [String] :value The metric value (required)
      # @option config [String, Integer, Timestamp] :timestamp The timestamp in either epoch or a TimeStamp object.
      # @option config [Array] :tags Array of tags to set for this metric. (tag_key => value)
      # @option config [Boolean] :no_duplicates? Prevent from inserting on existing metrics. Defaults to false.
      #
      # @return [Metric] a new Metric object
      def initialize(config = {})
        validate(config, %w(name value))

        @name = config[:name]
        @value = config[:value]
        @timestamp = config[:timestamp] ||  Time.now.to_i
        @tags = config[:tags] || {}
        @no_duplicates = config[:no_duplicates?]
      end

      # Checks if duplicate metrics should be inserted upon write to OpenTSDB
      #
      # @return [Boolean]
      def no_duplicates?
        @no_duplicates
      end

      # Converts the metric into the format required for use by `put` to insert into OpenTSDB.
      #
      # @return [String] put string
      def to_s
        result = ''
        # Format the string for OpenTSDB
        @tags.each { |k, v| result += "#{k}=#{v} " } unless @tags.nil?
        [@name, @timestamp, @value, result.rstrip].join(' ')
      end

    private
      # Validates the metric inputs
      #
      # @param [Hash] config The configuration to validate.
      # @param [Array] required_fields The required fields to be set inside the configuration.
      def validate(config={}, required_fields)
        # Make sure the data exists & validate required fields
        if (config.empty?)
          raise ArgumentError.new('No data is available to write into TSDB.')
        end

        # Required fields check
        required_fields.each do |f|
          if config[f.to_sym].nil?
            raise ArgumentError.new("#{f} is required to write into TSDB.")
          end
        end

        # Reject if user provided timestamp as not numeric
        raise ArgumentError.new('Timestamp must be numeric') if config[:timestamp] && !(config[:timestamp].is_a? Fixnum)
      end
    end
  end
end