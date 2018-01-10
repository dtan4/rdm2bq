#!/usr/bin/env ruby

require "logger"
require "optparse"

require_relative "./bigquery"
require_relative "./cloud_watch_logs"

class CLI
  def initialize(logger = Logger.new(STDOUT))
    @logger = logger
    @opts = {
      credentials: "",
      dataset: "",
      log_stream_name: "",
      project_id: "",
      table_prefix: "",
    }
  end

  def run(argv)
    parse_opts(argv)

    cloud_watch_logs = CloudWatchLogs.new
    metrics = cloud_watch_logs.retrieve_latest_metrics(@opts[:log_stream_name])

    bigquery = BigQuery.new(@opts[:credentials], @opts[:project_id])
    bigquery.post_metrics(@opts[:dataset], @opts[:table_prefix], metrics)

    @logger.info "successfully inserted"
  end

  private

  def parse_opts(argv)
    op = OptionParser.new

    op.on("-c", "--credentials VALUE", "GCP credentials file") { |v| @opts[:credentials] = v }
    op.on("-d", "--dataset VALUE", "BigQuery dataset") { |v| @opts[:dataset] = v }
    op.on("-l", "--log-stream VALUE", "CloudWatch log stream name") { |v| @opts[:log_stream_name] = v }
    op.on("-p", "--project-id VALUE", "GCP Project ID") { |v| @opts[:project_id] = v }
    op.on("-t", "--table-prefix VALUE", "BigQuery table prefix") { |v| @opts[:table_prefix] = v }

    op.parse!(argv)
  end
end

CLI.new.run(ARGV)
