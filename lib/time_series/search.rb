require_relative 'response'
require_relative 'suggest'

module OPOWER
  module TimeSeries
  # Configuration defaults

    class Search
      include Response

      attr_accessor :host, :port, :client, :url

      # Create a connection to a specific OpenTSDB instance
      #
      # Params:
      #
      # host is the host IP (defaults to localhost)
      # port is the host's port (defaults to 4242)
      #
      # Returns:
      #
      # A client to play with
      def initialize (host = '127.0.0.1', port = 4242)
        @host = host
        @port = port

        @client = "http://#{host}:#{port}/"
        @sobj = OPOWER::TimeSeries::Suggest.new(@host, @port)
      end

      # Queries the instance for a graph. 3 (useful) formats are supported:
      #
      # * ASCII returns data that is suitable for graphing or otherwise interpreting on the client
      # * JSON returns meta data for the query
      # * PNG returns a PNG image you can render on the client
      #
      #
      # Params (See http://opentsdb.net/http-api.html#/q_Parameters for more information):
      #
      #
      # options a hash which may include the following keys:
      #
      # * format (one of json, ascii, png), defaults to json.
      # * start   The query's start date. (required)
      # * end     The query's end date.
      # * m       The query itself. (required, must be an array)
      #           This is a JSON object contains aggregator, metrics and tags
      # * o       Rendering options.
      # * wxh     The dimensions of the graph.
      # * yrange  The range of the left Y axis.
      # * y2range The range of the right Y axis.
      # * ylabel  Label for the left Y axis.
      # * y2label Label for the right Y axis.
      # * yformat Format string for the left Y axis.
      # * y2formatFormat string for the right Y axis.
      # * ylog    Enables log scale for the left Y axis.
      # * y2log   Enables log scale for the right Y axis.
      # * key     Options for the key (legend) of the graph.
      # * nokey   Removes the key (legend) from the graph.
      # * nocache Forces TSD to ignore cache and fetch results from HBase.
      #
      # The syntax for metrics (m) (square brackets indicate an optional part):
      #
      # AGG:[interval-AGG:][rate:]metric[{tag1=value1[,tag2=value2...]}]

      def query (options = {})
        marr = []

        # Validate m parameter
        proc = Proc.new { err_msg = validate_m(options)
                          unless err_msg.nil?
                            puts err_msg
                            return
                          end
                        }
        proc.call

        # Create 'm' string 
        options[:m].each do|mvar|
          tag_params = []
          mvar[:tags].each{|k,v| tag_params << "#{k}=#{v}"}
          marr << mvar[:aggregator] + ":" + mvar[:metric] + "%7B" + tag_params.join(',') + "%7D"
        end
        options[:m] = marr
        
        if ( options[:format].to_s == 'json' || options[:format].nil? )
          orig_format = 'json'
          format = 'ascii'
        else
          format = options[:format].to_s
        end

        proc = Proc.new { msg = get_query(options)
                          if (@url.nil?)
                            puts msg
                            return
                          end
                        }
        proc.call

        data = get_response @url,format
        if data.empty?
          puts "No data found for this query, try again." 
          return
        end

        if (orig_format.to_s == 'json')
          # Return JSON
          make_json(data)
        elsif (format.to_s == 'ascii')
          # Return ASCII
          data
        else
          # Return URL for PNG format
          @url
        end
      end

      def get_query(options={})
        # Default to JSON format if no format specified
        options[:format] = 'json' if (options[:format].nil?)
        if (options[:format].to_s == 'json')
          options[:format] = :ascii
          format = 'ascii'
        elsif (options[:format].to_s == 'ascii')
          format = 'ascii'
        elsif (options[:format].to_s == 'png')
          format = options.delete(:format) || options.delete('format') || 'png'
        else
          return "This gem only supports ascii/json/png formats."
        end
        options[format.to_sym] = true
        params   = query_params(options, [:start, :m])
        @url = @client + "q?#{params}"
      end

      private
      # Parses a query param hash into a query string as expected by OpenTSDB
      # *Params:*
      # * params the parameters to parse into a query string
      # * requirements: any required parameters
      # *Returns:*
      # A query string
      # Raises:
      # ArgumentError if a required parameter is missing
      def query_params params = {}, requirements = []
        query = []

        requirements.each do |req|
          unless params.keys.include?(req.to_sym) || params.keys.include?(req.to_s)
            raise ArgumentError.new("#{req} is a required parameter.")
          end
        end

        params.each_pair do |k,v|
          if v.respond_to? :each
            v.each do |subv|
              query << "#{k}=#{subv}"
            end
          else
            v = v.strftime('%Y/%m/%d-%H:%M:%S') if v.respond_to? :strftime
            query << "#{k}=#{v}"
          end
        end
        query.join '&'
      end

      # Creates a JSON object
      # Params:
      # ASCII based data from the response since OpenTSDB doesn't support JSON
      # Returns:
      # JSON object
      def make_json (datastr)
        data_arr = []

        datastr.split("\n").each do|line|
          h = {}
          tags = {}
          line_arr = line.split("\s")
          h['metric'] = line_arr[0]
          h['ts'] = line_arr[1]
          h['value'] = line_arr[2]
          i = 3
          while(i < line_arr.length)
            tag_data = []
            tag_data = line_arr[i].split('=')
            tags[tag_data[0]] = tag_data[1]
            i = i + 1
          end
          h['tags'] = tags
          data_arr << h
        end
        data_arr
      end

      # Validate 'm' parameter in the query
      # 1). Must be an array
      # 2). Make sure aggregator and metric label are present
      # 3). Check for valid metric
      # 4). Check for valid tags
      def validate_m(opts)
        mparam = []
        err_msg = nil

        mparam = opts[:m] 

        # 1
        unless (mparam.is_a? Array)
          err_msg = "Query options 'm' parameter must be an array."
          return err_msg
        end
        # 2
        mparam.each do|h|
          ['aggregator', 'metric'].all? {|mtag| 
            unless h.key? (mtag.to_sym)
              err_msg = "Aggregator and metric label must be present for query to run." 
              return err_msg
            end
          }
        end
        # 3
        mparam.each do|h|
          metric = @sobj.run_suggest (h[:metric])
          return metric if (metric =~ /ERROR/)
          if (pos = metric =~ /\"#{h[:metric]}\"/).nil?
            err_msg = "Metric #{h[:metric]} is not registered, check again."
            return err_msg
          end
        end
        # 4
        mparam.each do|h|
          h[:tags].each_key do|k|
            tag_key = @sobj.run_suggest(k, 'tagk')
            return tag_key if (tag_key =~ /ERROR/)
            if (pos = tag_key =~ /\"#{k}\"/).nil?
              err_msg = "Tag Key #{k} is not registered, check again."
              return err_msg
            end
          end
        end
        err_msg
      end

    end

  end
end
