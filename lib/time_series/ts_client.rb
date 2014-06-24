# -*- encoding: utf-8 -*-

require 'rubygems'
require 'excon'
require 'json'

module Opower
  module TimeSeries
    # Ruby client object to interface with an OpenTSDB instance.
    class TSClient
      attr_accessor :host, :port, :client, :config, :connection

      # Creates a connection to a specified OpenTSDB instance
      #
      # @param [String] host The hostname/IP to connect to. Defaults to 'localhost'.
      # @param [Integer] port The port to connect to. Defaults to 4242.
      # @param [Boolean] persistent Keep a persistent HTTP connection
      #
      # @return [TSClient] Client connection to OpenTSDB.
      def initialize(host = '127.0.0.1', port = 4242, persistent = true)
        @host = host
        @port = port

        @client = "http://#{host}:#{port}/"
        @connection = Excon.new(@client, persistent: persistent, idempotent: true, tcp_nodelay: true)
        configure
      end

      # Configures client-specific options
      #
      # @param [Hash] cfg The configuration options to set.
      # @option cfg [Boolean] :dry_run When set to true, the client does not actually read/write to OpenTSDB.
      # @option cfg [Boolean] :validation Controls validation on queries. Defaults to false.
      def configure(cfg = {})
        @config = { dry_run: false, validation: false, version: 2.0 }
        @valid_config_keys = @config.keys

        cfg.each { |k, v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym }
      end

      # Returns suggestions for metric or tag names
      #
      # @param [String] query The string to search for
      # @param [String] type The type to search for: 'metrics', 'tagk', 'tagv'
      #
      # @return [Array] an array of possible values based on the query/type
      def suggest(query, type = 'metrics', max = 10)
        endpoint = @config[:version] >= 2.0 ? 'api/suggest' : 'suggest'
        return @client + "suggest?type=#{type}&q=#{query}" if @config[:dry_run]
        JSON.parse(@connection.get(path: endpoint, query: { type: type, q: query, max: max }).body)
      end

      # Writes the specified Metric object to OpenTSDB.
      #
      # @param [Metric] metric The metric to write to OpenTSDB
      def write(metric)
        cmd = "echo \"put #{metric}\" | nc -w 30 #{@host} #{@port}"

        if @config[:dry_run]
          cmd
        else
          # Write into the db
          ret = system(cmd)

          # Command failed to run
          unless ret || ret.nil?
            fail(IOError, "Failed to insert metric #{metric.name} with value of #{metric.value} into OpenTSDB.")
          end
        end
      end

      # Runs the specified query against OpenTSDB. If config[:dry-run] is set to true or PNG format requested,
      # it will only return the URL for the query. Otherwise it will return a Result object.
      #
      # @param [Query] query The query object to execute with.
      # @return [Result || String] the results of the query
      def run_query(query)
        url = build_url(query)
        return @client + url if @config[:dry_run] || query.format == 'png'

        validate_query(query) if @config[:validation]
        response = @connection.get(path: url)

        Opower::TimeSeries::Result.new(response, query.format, @config[:version])
      end

      # Runs the specified queries against OpenTSDB in a HTTP pipelined connection.
      #
      # @param [Array] queries An array of queries to run against OpenTSDB.
      # @return [Array] a matching array of results for each query
      def run_queries(queries)
        # requests cannot be idempotent when pipelined, so we temporarily disable it
        idempotent = @connection.data[:idempotent]
        @connection.data[:idempotent] = false

        results = run_pipelined_request(queries)

        @connection.data[:idempotent] = idempotent
        results
      end

      private

      # Validates the query before executing it on the OpenTSDB instance.
      #
      # @param [Query] query The Query object to validate.
      def validate_query(query)
        metrics = query.metrics

        metrics.each do |h|
          # Check the metrics are valid
          metric = suggest(h[:metric])

          if metric.length == 0 || metric[0] != h[:metric]
            fail(ArgumentError, "Metric #{h[:metric]} is not registered, check again.")
          end

          check_tags(h[:tags])
        end
      end

      def build_url(query)
        endpoint = @config[:version] >= 2.0 && query.format != 'ascii' ? 'api/query?' : 'q?'
        endpoint = 'q?' if query.format == 'png'
        endpoint + query.to_s
      end

      def check_tags(tags)
        return if tags.nil?

        # Check the tags are valid
        tags.each_key do |k|
          tag_key = suggest(k, 'tagk')

          next unless tag_key.length == 0 || tag_key[0] != k.to_s
          fail(ArgumentError, "Tag Key #{k} is not registered, check again.")
        end
      end

      def run_pipelined_request(queries)
        results = []

        responses = @connection.requests(build_queries(queries))
        responses.each_index do |i|
          results << Opower::TimeSeries::Result.new(responses[i], queries[i].format, @config[:version])
        end

        results
      end

      def build_queries(queries)
        requests = []
        queries.each do |query|
          endpoint = @config[:version] >= 2.0 && query.format != 'ascii' ? 'api/query?' : 'q?'
          requests << { method: :get, path: endpoint + query.to_s }
        end

        requests
      end
    end
  end
end
