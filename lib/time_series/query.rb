require 'httparty'

module Opower
  module TimeSeries
    # Represents a query that can be sent to an OpenTSDB instance through a [TSDBClient] object.
    class Query
      attr_accessor :metrics, :config, :response, :format

      # Creates a new Query object.
      #
      # @param [Hash] config The configuration for this query.
      # @option config [String] :format The format to return data with. Defaults to 'json'.
      # @option config [String, Integer, DateTime] :start The start time. Required field.
      # @option config [String, Integer, DateTime] :end The end time. Optional field.
      # @option config [Hash] :m Array of metric hashes.
      #  * :aggregator [String] The aggregation type to utilize. Required.
      #  * :metric [String] The metric name. Required.
      #  * :tags [Hash] Hash consisting of Tag Key / Tag Value pairs. Optional.
      #  * :down_sample [Hash] to specify downsampling period and function
      #    * :period [String] The period of time to downsample one
      #    * :function [String] The function [min, max, sum, avg, dev]
      # @option config [Boolean] padding If set to true, OpenTSDB (>= 2.0) will pad the start/end period.
      #
      # This object also supports all of the options available to the REST API for OpenTSDB.
      # See http://opentsdb.net/http-api.html#/q_Parameters for more information.
      #
      # @return [Query] new Query object
      def initialize(config = {})
        validate_metrics(config, [:start, :m])

        metric_arr = []
        @config = config
        @metrics = @config.delete(:m)

        # Create 'm' string
        @metrics.each do |m|
          tag_params = []
          ds = m[:downsample]
          m[:tags].each { |k, v| tag_params << "#{k}=#{v}" } unless m[:tags].nil?
          metric_arr << m[:aggregator] + ':'
          metric_arr << ds[:period] + '-' + ds[:function] + ':' unless ds.nil?
          metric_arr << m[:name] + '{' + tag_params.join(',') + '}'
        end

        @config[:m] = metric_arr
        @format = @config.delete(:format).to_s

        if (@format == 'json' || @format.nil?)
          @response = 'json'
          @format = 'ascii'
        end
      end

      # Builds a URI-encoded string in the format that OpenTSDB expects.
      #
      # @return [String] query string
      def get_query
        # Default to JSON format if no format specified
        @format = 'json' if (@format.nil?)
        URI.encode(build_request(@config))
      end

      # Builds the full GET URL for the OpenTSDB REST API.
      #
      # @return [String] full GET URL
      def to_s
        return "q?#{get_query}"
      end

    private
      # Validates 'm' parameter in the query
      #
      # @param [Hash] config The configuration to validate.
      # @param [Array] requirements The required fields to check for.
      def validate_metrics(config, requirements)
        requirements.each do |req|
          unless config.keys.include?(req.to_sym) || config.keys.include?(req.to_s)
            raise ArgumentError.new("#{req} is a required parameter.")
          end
        end

        metrics = config[:m]

        # check is opts is an Array
        raise ArgumentError.new('m parameter must be an array.') unless (metrics.is_a? Array)
        raise ArgumentError.new('m parameter must not be empty.') unless (metrics.length > 0)

        # check that the aggregator and metric labels exist
        metrics.each do |h|
          raise ArgumentError.new("Expected a Hash - got a #{h.class}: '#{h}'") unless h.is_a? Hash
          %w(aggregator metric).all? { |mtag|
            unless h.has_key? (mtag.to_sym)
              raise ArgumentError.new('Aggregator and metric label must be present for query to run.')
            end
          }
        end
      end

      # Builds the query string for the OpenTSDB REST API.
      #
      # @param [Hash] params the hash to parse
      # @return [String] the GET query string for this object.
      def build_request (params = {})
        query = []

        params.each_pair do |k, v|
          if v.respond_to? :each
            v.each do |subv|
              query << "#{k.to_s.strip}=#{subv.to_s.strip}"
            end
          else
            v = v.strftime('%Y/%m/%d-%H:%M:%S') if v.respond_to? :strftime
            query << "#{k.to_s.strip}=#{v.to_s.strip}"
          end
        end

        query << @format
        query.join('&')
      end
    end
  end
end
