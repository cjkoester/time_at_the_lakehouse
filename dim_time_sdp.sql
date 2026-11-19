-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Lakehouse Time Dimension for Lakeflow Spark Declarative Pipelines (SDP)
-- MAGIC This notebook creates a time dimension for the lakehouse at minute grain (1,440 rows).
-- MAGIC
-- MAGIC ### Directions
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

-- DBTITLE 1,Load dim_time
create or refresh materialized view dim_time (
  id int not null comment 'Surrogate key in HHmm format (0 - 2359)',
  time string comment '12-hour clock time (hh:mm AM/PM)',
  hour int comment 'Hour on a 12-hour clock (1 - 12)',
  time_24 string comment '24-hour clock time (HH:mm)',
  hour_24 int comment 'Hour on a 24-hour clock (0 - 23)',
  am_pm string comment 'AM or PM',
  constraint dim_time_pk primary key (id)
)
comment "Time dimension"
cluster by auto
tblproperties ("quality" = "gold")
as
with times as (
  select explode(sequence(to_timestamp('1900-01-01 00:00'), to_timestamp('1900-01-01 23:59'), interval 1 minute)) as time
)
select
  cast(date_format(time, 'HHmm') as int) as id,
  date_format(time, 'hh:mm a') as time,
  cast(date_format(time, 'h') as int) as hour,
  date_format(time, 'HH:mm') as time_24,
  hour(time) as hour_24,
  date_format(time, 'a') as am_pm
from
  times
