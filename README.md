# Time at the Lakehouse
Generate calendar and time dimensions for Databricks. Derived from [calendar-dimension-spark](https://github.com/BlueGranite/calendar-dimension-spark).

## Features
- Generate calendar (date) and time dimensions as Unity Catalog managed tables
- Plain SQL files for Lakeflow Jobs (or the SQL editor) and for Lakeflow Spark Declarative Pipelines. Copy them into your own project.
- Column comments for discoverability, plus informational primary keys in the jobs version
- Easy to modify to meet your requirements
- Lightweight and fast

## Requirements
- A Unity Catalog enabled workspace

## Repository contents
| Path | Description |
| --- | --- |
| `jobs/dim_calendar.sql` | Creates and reloads the calendar dimension as a managed table. |
| `jobs/dim_time.sql` | Creates and loads the time dimension as a managed table. |
| `pipeline/transformations/dim_calendar.sql` | Calendar dimension as a materialized view for Lakeflow Spark Declarative Pipelines. |
| `pipeline/transformations/dim_time.sql` | Time dimension as a materialized view for Lakeflow Spark Declarative Pipelines. |

## Usage

### Lakeflow Jobs
1. Copy the files in `jobs` into your project or workspace.
2. Create a job with a SQL file task for each file, running on a serverless SQL warehouse. Set the `catalog` and `schema` parameters on the job or task.
3. Schedule `dim_calendar` to run daily so the rolling date range stays current. `dim_time` only needs to run once.

To run a file interactively instead, open it in the SQL editor and fill in the `catalog` and `schema` parameters.

### Lakeflow Spark Declarative Pipelines
1. Create a pipeline (serverless recommended) and set its default catalog and schema.
2. Add the files in `pipeline/transformations` as pipeline source code.
3. Schedule the pipeline to refresh daily so the rolling date range in `dim_calendar` stays current.

## Examples

**Calendar dimension**

Sample rows spanning a month end and the start of an October fiscal year.

| date_int | calendar_date | calendar_year | calendar_month | month_of_year | calendar_day | day_of_week | day_of_week_start_monday | is_week_day | day_of_month | is_last_day_of_month | day_of_year | week_of_year_iso | quarter_of_year | fiscal_year_oct_to_sep | fiscal_month_oct_to_sep | fiscal_year_jul_to_jun | fiscal_month_jul_to_jun |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 20260928 | 2026-09-28 | 2026 | September | 9 | Monday | 2 | 1 | Y | 28 | N | 271 | 40 | 3 | 2026 | 12 | 2027 | 3 |
| 20260929 | 2026-09-29 | 2026 | September | 9 | Tuesday | 3 | 2 | Y | 29 | N | 272 | 40 | 3 | 2026 | 12 | 2027 | 3 |
| 20260930 | 2026-09-30 | 2026 | September | 9 | Wednesday | 4 | 3 | Y | 30 | Y | 273 | 40 | 3 | 2026 | 12 | 2027 | 3 |
| 20261001 | 2026-10-01 | 2026 | October | 10 | Thursday | 5 | 4 | Y | 1 | N | 274 | 40 | 4 | 2027 | 1 | 2027 | 4 |
| 20261002 | 2026-10-02 | 2026 | October | 10 | Friday | 6 | 5 | Y | 2 | N | 275 | 40 | 4 | 2027 | 1 | 2027 | 4 |
| 20261003 | 2026-10-03 | 2026 | October | 10 | Saturday | 7 | 6 | N | 3 | N | 276 | 40 | 4 | 2027 | 1 | 2027 | 4 |
| 20261004 | 2026-10-04 | 2026 | October | 10 | Sunday | 1 | 7 | N | 4 | N | 277 | 40 | 4 | 2027 | 1 | 2027 | 4 |

**Time dimension**

One row per minute of the day (1,440 rows). Sample rows:

| id | time | hour | time_24 | hour_24 | am_pm |
| --- | --- | --- | --- | --- | --- |
| 0 | 12:00 AM | 12 | 00:00 | 00 | AM |
| 1 | 12:01 AM | 12 | 00:01 | 00 | AM |
| 2 | 12:02 AM | 12 | 00:02 | 00 | AM |
| 1159 | 11:59 AM | 11 | 11:59 | 11 | AM |
| 1200 | 12:00 PM | 12 | 12:00 | 12 | PM |
| 1330 | 01:30 PM | 01 | 13:30 | 13 | PM |
| 2359 | 11:59 PM | 11 | 23:59 | 23 | PM |

## License
Released under the [MIT License](LICENSE).
