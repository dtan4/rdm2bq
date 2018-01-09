#!/usr/bin/env ruby

require "aws-sdk-cloudwatchlogs"

LOG_GROUP_NAME = "RDSOSMetrics"

client = Aws::CloudWatchLogs::Client.new

events = client.get_log_events(
  log_group_name: LOG_GROUP_NAME,
  log_stream_name: ARGV[0],
).events

p events.length
