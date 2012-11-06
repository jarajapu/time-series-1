
require 'yaml'

module OPOWER
  module TimeSeries
  # Configuration defaults

  class Query


    def initialize(hosts,metrics,start,ends)
      @query_string = "q?"
      @hosts_list = hosts.split(",")
      @metrics_list = metrics.split(",")
      @start = start
      @ends = ends
      @ylabel = "num_cpu_cycles"
      @y2label = "num_cpu_cycles"
    end


    def build_query
          # Step 1. Add start time to query
          # Optionally add end time if defined
          start_time = Time.at(@start.to_i).strftime("%Y/%m/%d-%H:%M:%S")

          if @ends.empty?
            @query_string = @query_string + "start=#{start_time}&ignore=91&"
          else
            end_time = Time.at(@ends.to_i).strftime("%Y/%m/%d-%H:%M:%S")
            @query_string = @query_string + "start=#{start_time}&end=#{end_time}&ignore=91&"
          end

          # Step 2. For each host and each metric requested, build the query string by
          # by appending to it.
          # Currently supported metrics: cpu.idle, cpu.user, cpu.system, cpu.iowait,
          # loadavg.5min, loadavg.1min
          # ios_in_progress,msec_total,msec_weighted_total
          @hosts_list.each do |host|

            @metrics_list.each do |metric|

              metric_type = metric.split("_")[0]
              metric_axis = metric.split("_")[1]

              case metric_type
              when "cpu.user"
               @query_string = @query_string + "m=avg:1m-avg:rate:proc.stat.cpu{host=#{host}.va.opower.it,type=user}"
              when "cpu.iowait"
               @query_string = @query_string + "m=avg:1m-avg:rate:proc.stat.cpu{host=#{host}.va.opower.it,type=iowait}"
              when "cpu.system"
               @query_string = @query_string + "m=avg:1m-avg:rate:proc.stat.cpu{host=#{host}.va.opower.it,type=system}"
              when "cpu.idle"
               @query_string = @query_string + "m=avg:1m-avg:rate:proc.stat.cpu{host=#{host}.va.opower.it,type=idle}"
              when "loadavg.1min"
               @query_string = @query_string + "m=sum:proc.loadavg.1min{host=#{host}.va.opower.it}"
              when "loadavg.5min"
               @query_string = @query_string + "m=sum:proc.loadavg.5min{host=#{host}.va.opower.it}"
              when "rpt.rate"
               @query_string = @query_string + "m=sum:rate:report.print.real_time_count{host=#{host}.va.opower.it}"
              when "ios"
               @query_string = @query_string + "m=sum:iostat.disk.ios_in_progress{host=#{host}.va.opower.it}"
              when "msec"
               @query_string = @query_string + "m=sum:rate:iostat.disk.msec_total{host=#{host}.va.opower.it}"
              when "wmsec"
               @query_string = @query_string + "m=sum:rate:iostat.disk.msec_weighted_total{host=#{host}.va.opower.it}"
              else
               @query_string = @query_string + "m=sum:#{metric_type}{host=#{host}.va.opower.it}"
              end

              set_labels(metric_type,metric_axis)
              @query_string = @query_string + set_axis(metric_axis)
            end

          end

          if defined?(@y2label).nil?
           @query_string = @query_string + "#{@ylabel}&yrange=[0:]&y2range=[0:]&key=out%20center%20top%20box&wxh=1529x579&png"
          else
           @query_string = @query_string + "#{@ylabel}&#{@y2label}&yrange=[0:]&y2range=[0:]&key=out%20center%20top%20box&wxh=1529x579&png"
          end
          return @query_string
    end


    def set_axis(metric_axis)

        if metric_axis == "y2"
           return "&o=axis%20x1y2&"
        else
           return "&o=&"
        end

     end



    def set_labels(metric_type,metric_axis)

          if metric_type.include? "cpu"
           if metric_axis == "y2"
             @y2label = "y2label=num_cpu_cycles"
           else
             @ylabel = "ylabel=num_cpu_cycles"
           end
          end
          if metric_type.include? "loadavg"
           if metric_axis == "y2"
             @y2label = "y2label=load_average"
           else
             @ylabel = "ylabel=load_average"
           end
          end
          if metric_type.include? "rpt.rate"
           if metric_axis == "y2"
             @y2label = "y2label=reports_per_sec"
           else
             @ylabel = "ylabel=reports_per_sec"
           end
          end
          if metric_type.include? "ios"
           if metric_axis == "y2"
             @y2label = "y2label=iops_per_sec"
           else
             @ylabel = "ylabel=iops_per_sec"
           end
          end
          if metric_type.include? "msec"
           if metric_axis == "y2"
             @y2label = "y2label=millisec_per_sec_spent_in_io"
           else
             @ylabel = "ylabel=millisec_per_sec_spent_in_io"
           end
          end

       end



  end

  end
end
