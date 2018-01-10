require "google/cloud/bigquery"

class BigQuery
  def initialize(credentials, project_id)
    @client = Google::Cloud::Bigquery.new(
      credentials: credentials,
      project_id: project_id,
    )
  end

  def post_metrics(dataset, table_prefix, metrics)
    table = current_table_name(table_prefix)
    create_table(dataset, table) unless table_exists?(dataset, table)

    @client.dataset(dataset).table(table).insert(transform_metrics_to_bq_rows(metrics))
  end

  private

  def create_table(dataset, table)
    @client.dataset(dataset).create_table(table) do |schema|
      schema.timestamp "timestamp", mode: :required
      schema.integer "pid", mode: :required
      schema.integer "parent_pid", mode: :required
      schema.string "name", mode: :required
      schema.integer "rss", mode: :required
      schema.integer "vss", mode: :required
    end
  end

  def current_table_name(table_prefix)
    "#{table_prefix}#{Time.now.strftime("%Y%m%d")}"
  end

  def table_exists?(dataset, table)
    !!@client.dataset(dataset).table(table)
  end

  def transform_metrics_to_bq_rows(metrics)
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
    # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html#USER_Monitoring.OS.CloudWatchLogs
    #

    metrics["processList"].map do |process|
      {
        timestamp: Time.parse(metrics["timestamp"]),
        pid: process["id"],
        parent_pid: process["parentID"],
        name: process["name"].strip,
        rss: process["rss"],
        vss: process["vss"],
      }
    end
  end
end
