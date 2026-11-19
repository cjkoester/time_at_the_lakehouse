# Time at the Lakehouse
Generate calendar & time dimensions for the Databricks Data Intelligence Platform

## Features
- Generate calendar/date and time dimensions as Unity Catalog managed Delta tables
- Includes notebooks for Lakeflow Jobs and Lakeflow Spark Declarative Pipelines (SDP)
- Primary keys and column comments for BI tools and AI/BI Genie
- Automatic liquid clustering (`cluster by auto`)
- SQL notebooks easy to modify to meet requirements
- Lightweight and fast (Serverless or single-node compute)

## Notebooks
| Notebook | Use with | Output |
| --- | --- | --- |
| [dim_calendar.sql](dim_calendar.sql) | Lakeflow Jobs | `dim_calendar` table |
| [dim_time.sql](dim_time.sql) | Lakeflow Jobs | `dim_time` table |
| [dim_calendar_sdp.sql](dim_calendar_sdp.sql) | Lakeflow Spark Declarative Pipelines | `dim_calendar` materialized view |
| [dim_time_sdp.sql](dim_time_sdp.sql) | Lakeflow Spark Declarative Pipelines | `dim_time` materialized view |

## Usage
### Lakeflow Jobs
1. Import `dim_calendar.sql` and `dim_time.sql` into your workspace (or clone this repo as a Git folder).
2. Set the `catalog` and `schema` parameters, either with the notebook widgets or as job task parameters.
3. Schedule `dim_calendar` to run daily so the rolling date range stays current. `dim_time` only needs to run once.

### Lakeflow Spark Declarative Pipelines
1. Add `dim_calendar_sdp.sql` and `dim_time_sdp.sql` as source code in a Unity Catalog pipeline.
2. Set the pipeline's default catalog and schema. The materialized views are published there.
3. Schedule the pipeline to refresh daily.

### Requirements
- Unity Catalog
- Serverless compute or Databricks Runtime 15.4 LTS and above
- Predictive optimization enabled, so `cluster by auto` can select clustering keys

## Calendar dimension
Defaults to a rolling 5 year period ending on the current date. Example values are for 2026-04-15.

| Column | Type | Description | Example |
| --- | --- | --- | --- |
| `date_int` (PK) | int | Surrogate key in yyyyMMdd format | 20260415 |
| `calendar_date` | date | Calendar date | 2026-04-15 |
| `calendar_year` | int | Calendar year | 2026 |
| `calendar_month` | string | Full month name | April |
| `month_of_year` | int | Month number (1 - 12) | 4 |
| `calendar_day` | string | Full day name | Wednesday |
| `day_of_week` | int | Day of week starting Sunday (1 = Sunday) | 4 |
| `day_of_week_start_monday` | int | Day of week starting Monday (1 = Monday) | 3 |
| `is_week_day` | string | Y if Monday - Friday, otherwise N | Y |
| `day_of_month` | int | Day of month (1 - 31) | 15 |
| `is_last_day_of_month` | string | Y if the last day of the month, otherwise N | N |
| `day_of_year` | int | Day of year (1 - 366) | 105 |
| `week_of_year_iso` | int | ISO 8601 week of year (1 - 53) | 16 |
| `quarter_of_year` | int | Calendar quarter (1 - 4) | 2 |
| `fiscal_year_oct_to_sep` | int | Fiscal year, October - September | 2026 |
| `fiscal_month_oct_to_sep` | int | Fiscal month, October - September (1 = October) | 7 |
| `fiscal_year_jul_to_jun` | int | Fiscal year, July - June | 2026 |
| `fiscal_month_jul_to_jun` | int | Fiscal month, July - June (1 = July) | 10 |

## Time dimension
One row per minute of the day (1,440 rows).

| `id` (PK) | `time` | `hour` | `time_24` | `hour_24` | `am_pm` |
| --- | --- | --- | --- | --- | --- |
| 0 | 12:00 AM | 12 | 00:00 | 0 | AM |
| 1 | 12:01 AM | 12 | 00:01 | 0 | AM |
| 2 | 12:02 AM | 12 | 00:02 | 0 | AM |
| ... | ... | ... | ... | ... | ... |
| 1435 | 02:35 PM | 2 | 14:35 | 14 | PM |
| ... | ... | ... | ... | ... | ... |
| 2359 | 11:59 PM | 11 | 23:59 | 23 | PM |

## License
[MIT](LICENSE)
