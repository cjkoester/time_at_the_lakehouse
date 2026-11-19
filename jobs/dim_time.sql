-- Time dimension
--
-- Creates a time dimension as a Unity Catalog managed table, with one row per minute of the day.
--
-- Directions
-- - Set the catalog and schema parameters.
-- - Add, modify, or remove columns as needed. Keep the create table and insert statements in sync.
-- - Run it once with a Lakeflow Jobs SQL file task or in the SQL editor. The data doesn't change,
--   so it only needs to run again if you change the columns.
--
-- References
-- - Unity Catalog managed tables: https://docs.databricks.com/aws/en/tables/managed
-- - Datetime patterns: https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-datetime-pattern

use catalog identifier(:catalog);
use schema identifier(:schema);

create table if not exists dim_time (
  id int not null comment 'Integer representation of the time (HHmm)',
  time string not null comment 'Time in 12-hour format (12:00 AM - 11:59 PM)',
  hour string not null comment 'Hour in 12-hour format (01 - 12)',
  time_24 string not null comment 'Time in 24-hour format (00:00 - 23:59)',
  hour_24 string not null comment 'Hour in 24-hour format (00 - 23)',
  am_pm string not null comment 'AM or PM',
  primary key (id) rely
)
comment 'Time dimension'
tblproperties ('quality' = 'gold');

insert overwrite dim_time
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
