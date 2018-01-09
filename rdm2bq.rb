#!/usr/bin/env ruby

require "aws-sdk-cloudwatchlogs"
require "json"

LOG_GROUP_NAME = "RDSOSMetrics"

client = Aws::CloudWatchLogs::Client.new

event = client.get_log_events(
  log_group_name: LOG_GROUP_NAME,
  log_stream_name: ARGV[0],
  limit: 1,
  start_from_head: false, # latest log events are returned first
).events[0]

p JSON.parse(event.message)
