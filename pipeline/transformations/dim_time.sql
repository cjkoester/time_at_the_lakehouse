-- Time dimension for Lakeflow Spark Declarative Pipelines
--
-- Creates a time dimension as a materialized view, with one row per minute of the day.
--
-- Directions
-- - Add, modify, or remove columns as needed. Keep the column list and the query in sync.
-- - Add this file to a pipeline. The table is published to the pipeline's default catalog and schema.
--
-- References
-- - Lakeflow Spark Declarative Pipelines: https://docs.databricks.com/aws/en/ldp/
-- - CREATE MATERIALIZED VIEW (pipelines): https://docs.databricks.com/aws/en/ldp/developer/ldp-sql-ref-create-materialized-view
-- - Datetime patterns: https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-datetime-pattern

create or refresh materialized view dim_time (
  id int not null comment 'Integer representation of the time (HHmm)',
  time string not null comment 'Time in 12-hour format (12:00 AM - 11:59 PM)',
  hour string not null comment 'Hour in 12-hour format (01 - 12)',
  time_24 string not null comment 'Time in 24-hour format (00:00 - 23:59)',
  hour_24 string not null comment 'Hour in 24-hour format (00 - 23)',
  am_pm string not null comment 'AM or PM'
  -- Informational primary key constraints in pipelines are in Public Preview. To declare one, add:
  -- , constraint dim_time_pk primary key (id)
)
comment 'Time dimension'
tblproperties ('quality' = 'gold')
as
with times as (
  select explode(sequence(to_timestamp('1900-01-01 00:00'), to_timestamp('1900-01-01 23:59'), interval 1 minute)) as time
)
select
  cast(date_format(time, 'HHmm') as int) as id,
  date_format(time, 'hh:mm a') as time,
  date_format(time, 'hh') as hour,
  date_format(time, 'HH:mm') as time_24,
  date_format(time, 'HH') as hour_24,
  date_format(time, 'a') as am_pm
from
  times;
