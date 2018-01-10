require "aws-sdk-cloudwatchlogs"
require "json"

class CloudWatchLogs
  LOG_GROUP_NAME = "RDSOSMetrics"

  def initialize
    @client = Aws::CloudWatchLogs::Client.new
  end

  def retrieve_latest_metrics(log_stream_name)
    event = @client.get_log_events(
      log_group_name: LOG_GROUP_NAME,
      log_stream_name: log_stream_name,
      limit: 1,
      start_from_head: false, # latest log events are returned first
    ).events[0]

    JSON.parse(event.message)
  end
end
