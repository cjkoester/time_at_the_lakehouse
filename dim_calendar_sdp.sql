-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Lakehouse Calendar Dimension for Lakeflow Spark Declarative Pipelines (SDP)
-- MAGIC This notebook creates a calendar dimension (Also known as date dimension) for the lakehouse. It is intended to be executed within a Lakeflow Spark Declarative Pipeline, and defaults to loading data using a rolling 5 year period.
-- MAGIC
-- MAGIC ### Directions
-- MAGIC - Modify the date range as necessary by updating the dates CTE
-- MAGIC - Add/modify/remove columns as necessary, keeping the column list and the query in sync
-- MAGIC - Add to a Lakeflow Spark Declarative Pipeline. The table is published to the pipeline's default catalog and schema
-- MAGIC
-- MAGIC ### Requirements
-- MAGIC - Unity Catalog enabled pipeline
-- MAGIC - Predictive optimization enabled for `cluster by auto` to select clustering keys
-- MAGIC
-- MAGIC ### References
-- MAGIC - [Five Simple Steps for Implementing a Star Schema in Databricks With Delta Lake](https://www.databricks.com/blog/2022/05/20/five-simple-steps-for-implementing-a-star-schema-in-databricks-with-delta-lake.html)
-- MAGIC - [Datetime Patterns for Formatting and Parsing](https://spark.apache.org/docs/latest/sql-ref-datetime-pattern.html)

-- COMMAND ----------

-- DBTITLE 1,Load dim_calendar
create or refresh materialized view dim_calendar (
  date_int int not null comment 'Surrogate key in yyyyMMdd format',
  calendar_date date comment 'Calendar date',
  calendar_year int comment 'Calendar year',
  calendar_month string comment 'Full month name (January - December)',
  month_of_year int comment 'Month number (1 - 12)',
  calendar_day string comment 'Full day name (Sunday - Saturday)',
  day_of_week int comment 'Day of week starting Sunday (1 = Sunday, 7 = Saturday)',
  day_of_week_start_monday int comment 'Day of week starting Monday (1 = Monday, 7 = Sunday)',
  is_week_day string comment 'Y if Monday - Friday, otherwise N',
  day_of_month int comment 'Day of month (1 - 31)',
  is_last_day_of_month string comment 'Y if the last day of the month, otherwise N',
  day_of_year int comment 'Day of year (1 - 366)',
  week_of_year_iso int comment 'ISO 8601 week of year (1 - 53)',
  quarter_of_year int comment 'Calendar quarter (1 - 4)',
  fiscal_year_oct_to_sep int comment 'Fiscal year for an October - September fiscal calendar',
  fiscal_month_oct_to_sep int comment 'Fiscal month for an October - September fiscal calendar (1 = October)',
  fiscal_year_jul_to_jun int comment 'Fiscal year for a July - June fiscal calendar',
  fiscal_month_jul_to_jun int comment 'Fiscal month for a July - June fiscal calendar (1 = July)',
  constraint dim_calendar_pk primary key (date_int)
)
comment "Calendar dimension"
cluster by auto
tblproperties ("quality" = "gold")
as
--Set the date range in the dates CTE below
with dates as (
  select explode(sequence(current_date() - interval 5 years, current_date(), interval 1 day)) AS calendar_date
)
select
  year(calendar_date) * 10000 + month(calendar_date) * 100 + day(calendar_date) as date_int,
  calendar_date,
  year(calendar_date) AS calendar_year,
  date_format(calendar_date, 'MMMM') as calendar_month,
  month(calendar_date) as month_of_year,
  date_format(calendar_date, 'EEEE') as calendar_day,
  dayofweek(calendar_date) AS day_of_week,
  weekday(calendar_date) + 1 as day_of_week_start_monday,
  case
    when weekday(calendar_date) < 5 then 'Y'
    else 'N'
  end as is_week_day,
  dayofmonth(calendar_date) as day_of_month,
  case
    when calendar_date = last_day(calendar_date) then 'Y'
    else 'N'
  end as is_last_day_of_month,
  dayofyear(calendar_date) as day_of_year,
  weekofyear(calendar_date) as week_of_year_iso,
  quarter(calendar_date) as quarter_of_year,
  /* Use fiscal periods needed by organization fiscal calendar */
  case
    when month(calendar_date) >= 10 then year(calendar_date) + 1
    else year(calendar_date)
  end as fiscal_year_oct_to_sep,
  (month(calendar_date) + 2) % 12 + 1 AS fiscal_month_oct_to_sep,
  case
    when month(calendar_date) >= 7 then year(calendar_date) + 1
    else year(calendar_date)
  end as fiscal_year_jul_to_jun,
  (month(calendar_date) + 5) % 12 + 1 AS fiscal_month_jul_to_jun
from
  dates
