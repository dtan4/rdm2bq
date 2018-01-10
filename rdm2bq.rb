#!/usr/bin/env ruby

require "aws-sdk-cloudwatchlogs"
require "json"
require "optparse"

LOG_GROUP_NAME = "RDSOSMetrics"

opts = {
  log_stream_name: "",
}

op = OptionParser.new

op.on("-l", "--log-stream VALUE", "CloudWatch log stream name") { |v| opts[:log_stream_name] = v }

op.parse!(ARGV)

client = Aws::CloudWatchLogs::Client.new

event = client.get_log_events(
  log_group_name: LOG_GROUP_NAME,
  log_stream_name: opts[:log_stream_name],
  limit: 1,
  start_from_head: false, # latest log events are returned first
).events[0]

metrics = JSON.parse(event.message)

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
