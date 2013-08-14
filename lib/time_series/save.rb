require_relative 'response'
require_relative 'suggest'

module OPOWER
  module TimeSeries
    # Configuration defaults

    class Save
      include OPOWER::TimeSeries::Response

      attr_accessor :host, :port, :client, :save_params

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
 
      # Adds a new record in OpenTSDB.
      #
      # Params (See http://opentsdb.net/ for more information):
      #
      # options a hash which may include the following keys:
      #
      # * metric           The metric label. (required)
      # * value            The value for that row. (required)
      # * timestamp        Timestamp in numeric. (Default: Current Timestamp)
      # * tags             Array of tags for the row.
      # * no_dup_allow     Allows duplicate rows by default.
      #
      # The syntax for put :
      #
      # put metric value [{tag1=value1[,tag2=value2...]}]

      def put (options = {})

        result = ''

        # Default to Current Timestamp
        options[:timestamp] = Time.now.to_i unless options[:timestamp]

        proc = Proc.new { err = validate (options) 
                          unless (err.nil?)
                            puts err
                            return
                          end
                        }
        proc.call

        # Format the string for Opentsdb
        options[:tags].each{|k,v| result += "#{k}=#{v} "}
        rec = ['put',options[:metric],options[:timestamp],options[:value],result.rstrip].join(' ')

        # Write into the db
        ret = system("echo \"#{rec}\" | nc -w 30 #{@host} #{@port}")

        # Command failed to run
        unless ret || ret.nil?
          puts "Command failed to insert #{rec} into OpenTSDB."
          return
        end

        puts "Successfully saved."
      end

      def data=(options)
        @save_params = options
      end

      def data
        @save_params
      end

      private

      def validate(options={})
        req_fields = ['metric', 'value']

        # Make sure the data exists & validate required fields
        if (options.empty?)
          return 'No data is available to write into tsdb.'
        end

        # Required fields check
        req_fields.each do|f|
          if options[f.to_sym].nil?
            return "#{f} is required to write into tsdb."
          end
        end

        # Check for duplicate metrics, default: false
        if options[:no_dup_allow]
          metric = @sobj.run_suggest options[:metric]
          metric =~ /\"#{options[:metric]}\"/
          return "Metric already exists, duplicate not allowed. " +
          "Hint: Do not set no_dup_allow option when you submit data." if $&
        end

        # Reject if user provided timestamp as not numeric
        return "Timestamp must be numeric" if options[:timestamp] && !(options[:timestamp].is_a? Fixnum)

        # Validation passed
        nil
      end

    end

  end
end

