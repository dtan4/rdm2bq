#!/usr/bin/env ruby

require "logger"
require "optparse"

require_relative "./bigquery"
require_relative "./cloud_watch_logs"

class CLI
  def initialize(logger = Logger.new(STDOUT))
    @logger = logger
    @opts = {
      credentials: ENV["RDM2BQ_GCP_CREDENTIALS"],
      dataset: ENV["RDM2BQ_BIGQUERY_DATASET"],
      dry_run: false,
      log_stream_name: ENV["RDM2BQ_LOG_STREAM"],
      project_id: ENV["RDM2BQ_GCP_PROJECT_ID"],
      table_prefix: ENV["RDM2BQ_BIGQUERY_TABLE_PREFIX"],
    }
  end

  def run(argv)
    parse_opts(argv)

    cloud_watch_logs = CloudWatchLogs.new
    metrics = cloud_watch_logs.retrieve_latest_metrics(@opts[:log_stream_name])

    if @opts[:dry_run]
      @logger.info "[dry-run] #{metrics.length} records will be inserted to BigQuery"
    else
      bigquery = BigQuery.new(@opts[:credentials], @opts[:project_id])
      bigquery.post_metrics(@opts[:dataset], @opts[:table_prefix], metrics)
    end

    @logger.info "successfully inserted"
  end

  private

  def parse_opts(argv)
    op = OptionParser.new

    op.on("-c", "--credentials VALUE", "GCP credentials file") { |v| @opts[:credentials] = v }
    op.on("-d", "--dataset VALUE", "BigQuery dataset") { |v| @opts[:dataset] = v }
    op.on("--dry-run", "Dry run (does not insert any metrics to BigQuery)") { |v| @opts[:dry_run] = true }
    op.on("-l", "--log-stream VALUE", "CloudWatch log stream name") { |v| @opts[:log_stream_name] = v }
    op.on("-p", "--project-id VALUE", "GCP Project ID") { |v| @opts[:project_id] = v }
    op.on("-t", "--table-prefix VALUE", "BigQuery table prefix") { |v| @opts[:table_prefix] = v }

    op.parse!(argv)
  end
end

CLI.new.run(ARGV)
