-- Databricks notebook source
-- MAGIC %md
-- MAGIC ## Lakehouse Time Dimension
-- MAGIC This notebook creates a time dimension for the lakehouse at minute grain (1,440 rows).
-- MAGIC
-- MAGIC ### Directions
-- MAGIC - Set the `catalog` and `schema` parameters (notebook widgets or Lakeflow Jobs task parameters)
-- MAGIC - Add/modify/remove columns as necessary. Update both the `create table` and `insert overwrite` statements, then drop the existing table so it is recreated with the new schema
-- MAGIC - Run notebook to load the table
-- MAGIC
-- MAGIC ### Requirements
-- MAGIC - Unity Catalog
-- MAGIC - Serverless compute or Databricks Runtime 15.4 LTS and above
-- MAGIC - Predictive optimization enabled for `cluster by auto` to select clustering keys
-- MAGIC
-- MAGIC ### References
-- MAGIC - [Five Simple Steps for Implementing a Star Schema in Databricks With Delta Lake](https://www.databricks.com/blog/2022/05/20/five-simple-steps-for-implementing-a-star-schema-in-databricks-with-delta-lake.html)
-- MAGIC - [Datetime Patterns for Formatting and Parsing](https://spark.apache.org/docs/latest/sql-ref-datetime-pattern.html)

-- COMMAND ----------

-- DBTITLE 1,Parameters
create widget text catalog default 'main';
create widget text schema default 'default';

-- COMMAND ----------

-- DBTITLE 1,Set Catalog & Schema
use catalog identifier(:catalog);
use schema identifier(:schema);

-- COMMAND ----------

-- DBTITLE 1,Create dim_time
create table if not exists dim_time (
  id int not null comment 'Surrogate key in HHmm format (0 - 2359)',
  time string comment '12-hour clock time (hh:mm AM/PM)',
  hour int comment 'Hour on a 12-hour clock (1 - 12)',
  time_24 string comment '24-hour clock time (HH:mm)',
  hour_24 int comment 'Hour on a 24-hour clock (0 - 23)',
  am_pm string comment 'AM or PM',
  constraint dim_time_pk primary key (id)
)
comment 'Time dimension'
cluster by auto
tblproperties ('quality' = 'gold')

-- COMMAND ----------

-- DBTITLE 1,Load dim_time
insert overwrite dim_time
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
