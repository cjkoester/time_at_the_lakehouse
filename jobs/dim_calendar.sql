-- Calendar dimension
--
-- Creates a calendar dimension (also known as a date dimension) as a Unity Catalog managed table.
-- Defaults to a rolling 5 year period that ends on the current date, so schedule it to run daily.
--
-- Directions
-- - Set the catalog and schema parameters.
-- - Change the date range by updating the dates CTE.
-- - Add, modify, or remove columns as needed. Keep the create table and insert statements in sync.
-- - Schedule it daily with a Lakeflow Jobs SQL file task, or run it in the SQL editor.
--
-- References
-- - Unity Catalog managed tables: https://docs.databricks.com/aws/en/tables/managed
-- - Datetime patterns: https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-datetime-pattern

use catalog identifier(:catalog);
use schema identifier(:schema);

create table if not exists dim_calendar (
  date_int int not null comment 'Integer representation of the date (yyyyMMdd)',
  calendar_date date not null comment 'Calendar date',
  calendar_year int not null comment 'Calendar year',
  calendar_month string not null comment 'Calendar month (January, February, March)',
  month_of_year int not null comment 'Month of year (1 - 12)',
  calendar_day string not null comment 'Calendar day (Monday, Tuesday, Wednesday)',
  day_of_week int not null comment 'Day of week starting Sunday (1 - 7)',
  day_of_week_start_monday int not null comment 'Day of week starting Monday (1 - 7)',
  is_week_day string not null comment 'Flag for weekday, a day of the week other than Saturday or Sunday (Y, N)',
  day_of_month int not null comment 'Day of the month (1 - 31)',
  is_last_day_of_month string not null comment 'Flag for last day of the month (Y, N)',
  day_of_year int not null comment 'Day of the year (1 - 366)',
  week_of_year_iso int not null comment 'ISO week of the year (1 - 53)',
  quarter_of_year int not null comment 'Quarter of the year (1 - 4)',
  fiscal_year_oct_to_sep int not null comment 'Fiscal year for October to September',
  fiscal_month_oct_to_sep int not null comment 'Fiscal month for October to September (1 - 12)',
  fiscal_year_jul_to_jun int not null comment 'Fiscal year for July to June',
  fiscal_month_jul_to_jun int not null comment 'Fiscal month for July to June (1 - 12)',
  primary key (date_int) rely
)
comment 'Calendar dimension'
cluster by auto
tblproperties ('quality' = 'gold');

insert overwrite dim_calendar
-- Set the date range in the dates CTE below
with dates as (
  select explode(sequence(current_date() - interval 5 years, current_date(), interval 1 day)) as calendar_date
)
select
  year(calendar_date) * 10000 + month(calendar_date) * 100 + day(calendar_date) as date_int,
  calendar_date,
  year(calendar_date) as calendar_year,
  date_format(calendar_date, 'MMMM') as calendar_month,
  month(calendar_date) as month_of_year,
  date_format(calendar_date, 'EEEE') as calendar_day,
  dayofweek(calendar_date) as day_of_week,
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
  /* Use the fiscal periods that match your organization's fiscal calendar */
  case
    when month(calendar_date) >= 10 then year(calendar_date) + 1
    else year(calendar_date)
  end as fiscal_year_oct_to_sep,
  (month(calendar_date) + 2) % 12 + 1 as fiscal_month_oct_to_sep,
  case
    when month(calendar_date) >= 7 then year(calendar_date) + 1
    else year(calendar_date)
  end as fiscal_year_jul_to_jun,
  (month(calendar_date) + 5) % 12 + 1 as fiscal_month_jul_to_jun
from
  dates;
