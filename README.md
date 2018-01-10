# rdm2bq

[![Docker Repository on Quay](https://quay.io/repository/dtan4/rdm2bq/status "Docker Repository on Quay")](https://quay.io/repository/dtan4/rdm2bq)

Send [Amazon RDS Enhanced Monitoring](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html) process metrics to Google BigQuery

## Prerequisites

- [Enhanced Monitoring](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.html) must be enabled at the target RDS instance
- AWS credentials
  - which is authorized to invoke `logs:getLogEvents`
- GCP credential file
  - which is authorized to create/edit BigQuery table

## Installation

```bash
bundle install --without development test
```

### Docker

```bash
docker pull quay.io/dtan4/rdm2bq
```

## Usage

```bash
bundle exec ./rdm2bq.rb \
  -l db-THISISANEXAMPLEDATABASEID0 \
  -p foobar-1234 \
  -c credentials.json \
  -d database_metrics \
  -t db_process_metrics
```

will send the latest process metrics...

- from: CloudWatch Log Event `db-THISISANEXAMPLEDATABASEID0`
- to: BigQuery table `foobar-1234:database_metrics.db_process_metrics20180110`
  - `20180110` is the `YYYYmmdd`-formatted current date in local timezone

### Docker

:warning: Default timezone in Docker container is `UTC`.
If you want to change the timezone of BigQuery table suffix, environment variable `TZ` must be set.

```bash
docker run --rm -e TZ=Asia/Tokyo --name rdm2bq quay.io/dtan4/rdm2bq:latest \
  -l db-THISISANEXAMPLEDATABASEID0 \
  -p foobar-1234 \
  -c credentials.json \
  -d database_metrics \
  -t db_process_metrics
```

### Options / Environment variables

|Option|Environment variable|Description|Example|
|------|--------------------|-----------|-------|
||`TZ`|timezone ([tz database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) zone name)|`Asia/Tokyo`|
|`-c`, `--credentials VALUE`|`RDM2BQ_GCP_CREDENTIALS`|GCP credentials file|`/app/credentials.json`|
|`-d`, `--dataset VALUE`|`RDM2BQ_BIGQUERY_DATASET`|BigQuery dataset|`database_metrics`|
|`--dry-run`||Dry run (does not insert any metrics to BigQuery)||
|`-l`, `--log-stream VALUE`|`RDM2BQ_LOG_STREAM`|CloudWatch log stream name|`db-THISISANEXAMPLEDATABASEID0`|
|`-p`, `--project-id VALUE`|`RDM2BQ_GCP_PROJECT_ID`|GCP Project ID|`foobar-1234`|
|`-t`, `--table-prefix VALUE`|`RDM2BQ_BIGQUERY_TABLE_PREFIX`|BigQuery table prefix|`db_process_metrics`|

### BigQuery table schema

|field|type|description|example|
|---|---|---|---|
|`timestamp`|TIMESTAMP|timestamp of metrics in UTC|`2018-01-10T02:57:55Z`|
|`pid`|INTEGER|process ID|`65502`|
|`parent_pid`|INTEGER|parent process ID|`1`|
|`name`|STRING|name of the process|`postgres: user dbname 10.0.0.000(12345) idle`|
|`rss`|INTEGER|amount of RAM allocated to the process (kilobytes)|`12205284`|
|`vss`|INTEGER|amount of virtual memory allocated to the process (kilobytes)|`32727212`|

## Author

Daisuke Fujita ([@dtan4](https://github.com/dtan4))

## License

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)
