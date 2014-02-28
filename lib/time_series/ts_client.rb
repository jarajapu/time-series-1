require 'httparty'

module Opower
  module TimeSeries
    # Ruby client object to interface with an OpenTSDB instance.
    class TSClient
      attr_accessor :host, :port, :client, :config

      # Creates a connection to a specified OpenTSDB instance
      #
      # @param [String] host The hostname/IP to connect to. Defaults to 'localhost'.
      # @param [Integer] port The port to connect to. Defaults to 4242.
      #
      # @return [TSClient] Client connection to OpenTSDB.
      def initialize (host = '127.0.0.1', port = 4242)
        @host = host
        @port = port

        @client = "http://#{host}:#{port}/"
        self.configure()
      end

      # Configures client-specific options
      #
      # @param [Hash] cfg The configuration options to set.
      # @option cfg [Boolean] :dry_run When set to true, the client does not actually read/write to OpenTSDB.
      # @option cfg [Boolean] :validation Controls validation on queries. Defaults to true.
      def configure(cfg = {})
        @config = {:dry_run => false, :validation => true, :version => 2.0}
        @valid_config_keys = @config.keys

        cfg.each { |k, v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym }
      end

      # Returns suggestions for metric or tag names
      #
      # @param [String] query The string to search for
      # @param [String] type The type to search for: 'metrics', 'tagk', 'tagv'
      #
      # @return [Array] an array of possible values based on the query/type
      def suggest (query, type = 'metrics', max = 1)
        endpoint = @config[:version] >= 2.0 ? 'api/suggest' : 'suggest'
        return @client + "suggest?type=#{type}&q=#{query}" if @config[:dry_run]
        HTTParty.get(@client + endpoint, :query => { :type => type, :q => query, :max => max}).parsed_response
      end

      # Writes the specified Metric object to OpenTSDB.
      #
      # @param [Metric] metric The metric to write to OpenTSDB
      def write (metric)
        cmd = "echo \"put #{metric.to_s}\" | nc -w 30 #{@host} #{@port}"

        unless(@config[:dry_run])
          # Write into the db
          ret = system(cmd)

          # Command failed to run
          unless ret || ret.nil?
            raise IOError.new("Failed to insert metric #{metric.name} with value of #{metric.value} into OpenTSDB.")
          end
        else
          cmd
        end
      end

      # Runs the specified query against OpenTSDB. If config[:dry-run] is set to true,
      # it will only return the URL for the query.
      #
      # @param [Query] query The query object to execute with.
      # @return [String] the results of the query
      def run_query(query)
        validate_query(query) unless @config[:dry_run] || !@config[:validation]
        return @client + 'q?' + query.to_s if query.format == 'png'

        endpoint = @config[:version] >= 2.0 && query.response != 'ascii' ? 'api/query?' : 'q?'
        return @client + endpoint + query.to_s if @config[:dry_run]
        data = HTTParty.get(@client + endpoint + query.to_s)

        if (query.response == 'json' && @config[:version] < 2.0)
          parse_json(data.parsed_response)
        elsif (query.format == 'ascii')
          data.parsed_response
        end
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
          return metric if (metric =~ /ERROR/)
          if (metric.length == 0 || metric[0] != h[:metric])
            raise ArgumentError.new("Metric #{h[:metric]} is not registered, check again.")
          end

          unless h[:tags].nil?
            # Check the tags are valid
            h[:tags].each_key do |k|
              tag_key = suggest(k, 'tagk')
              return tag_key if (tag_key =~ /ERROR/)
              if (tag_key.length == 0 || tag_key[0] != k.to_s)
                raise ArgumentError.new("Tag Key #{k} is not registered, check again.")
              end
            end
          end
        end
      end

      # Parses the ASCII response from OpenTSDB 1.1 and creates an appropriate JSON representation.
      #
      # @param [String] data The ASCII string
      # @return [Object] JSON representation.
      def parse_json (data)
        data_arr = []
        return data_arr if data.nil?

        data.split("\n").each do |line|
          h = {}
          tags = {}
          line_arr = line.split("\s")
          h['metric'] = line_arr[0]
          h['ts'] = line_arr[1]
          h['value'] = line_arr[2]
          i = 3

          while (i < line_arr.length)
            tag_data = line_arr[i].split('=')
            tags[tag_data[0]] = tag_data[1]
            i = i + 1
          end

          h['tags'] = tags
          data_arr << h
        end

        data_arr
      end

    end
  end
end