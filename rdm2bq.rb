#!/usr/bin/env ruby

require "optparse"

require_relative "./cloud_watch_logs"

class CLI
  def initialize
    @opts = {
      log_stream_name: "",
    }
  end

  def run(argv)
    parse_opts(argv)

    cloud_watch_logs = CloudWatchLogs.new
    metrics = cloud_watch_logs.retrieve_latest_metrics(@opts[:log_stream_name])

    #
    # processList
    #   cpuUsedPc - The percentage of CPU used by the process.
    #   id - The identifier of the process.
    #   memoryUsedPc - The amount of memory used by the process, in kilobytes.
    #   name - The name of the process.
    #   parentID - The process identifier for the parent process of the process.
    #   rss - The amount of RAM allocated to the process, in kilobytes.
    #   tgid - The thread group identifier, which is a number representing the process ID to which a thread belongs. This identifier is used to group threads from the same process.
    #   vss - The amount of virtual memory allocated to the process, in kilobytes.
    #

    metrics["processList"].each do |process|
      puts({
        parent_pid: process["parentID"],
        pid: process["id"],
        name: process["name"].strip,
        rss: process["rss"],
        tgid: process["tgid"],
        timestamp: metrics["timestamp"],
        vss: process["vss"],
      })
    end
  end

  private

  def parse_opts(argv)
    op = OptionParser.new

    op.on("-l", "--log-stream VALUE", "CloudWatch log stream name") { |v| @opts[:log_stream_name] = v }

    op.parse!(argv)
  end
end

CLI.new.run(ARGV)
