-- ================================================
-- Bellabeat Case Study -- MySQL Queries
-- Author: Tejaswini Bhalerao
-- Tool: MySQL Workbench
-- Data: FitBit Fitness Tracker Dataset (Kaggle)
-- Purpose: Analyse heart rate and sleep patterns
--          to generate recovery insights for Bellabeat
-- ================================================


-- ================================================
-- 1. Average Sleep Hours
-- Purpose: Calculate average sleep duration across all users
-- Insight: Helps benchmark sleep against recommended 7-9 hours
-- ================================================
SELECT
  ROUND(AVG(total_minutes_asleep) / 60, 0) AS avg_sleep_hours
FROM sleep_clean;


-- ================================================
-- 2. Average Heart Rate by Hour of Day
-- Purpose: Identify at what time of day users' hearts
--          are working hardest on average
-- Insight: Helps identify Peak Activity Window for
--          targeted engagement strategies
-- ================================================
SELECT
  hour,
  ROUND(AVG(avg_heart_rate), 1) AS avg_hr
FROM heartrate_hourly
GROUP BY hour
ORDER BY avg_hr DESC;


-- ================================================
-- 3. Average Heart Rate by Day of Week
-- Purpose: Analyze heart rate variation across weekdays
--          and weekends
-- Insight: Helps understand weekly activity patterns
--          and recovery trends
-- ================================================
SELECT
  DAYNAME(date) AS day,
  ROUND(AVG(avg_heart_rate), 1) AS avg_hr
FROM heartrate_hourly
GROUP BY DAYNAME(date);


-- ================================================
-- 4. Average Heart Rate by Daily Steps
-- Purpose: Examine relationship between heart rate
--          and daily step count per user
-- Insight: Validates heart rate as an indicator of
--          physical activity intensity
-- ================================================
SELECT
  h.user_id,
  h.date,
  ROUND(AVG(h.avg_heart_rate), 1) AS avg_daily_heartrate,
  a.total_steps
FROM heartrate_hourly h
JOIN daily_activity_clean a
  ON h.user_id = a.id
  AND h.date = a.activity_date_clean
GROUP BY h.user_id, h.date, a.total_steps
LIMIT 20;


-- ================================================
-- 5. Average Heart Rate by Activity Level
-- Purpose: Calculate average heart rate across different
--          activity levels based on daily step count
-- Insight: Confirms relationship between activity
--          intensity and heart rate patterns
-- ================================================
SELECT
  CASE
    WHEN total_steps < 5000 THEN 'Low Activity'
    WHEN total_steps BETWEEN 5000 AND 10000 THEN 'Moderate Activity'
    ELSE 'High Activity'
  END AS activity_level,
  ROUND(AVG(avg_daily_heartrate), 1) AS avg_heart_rate
FROM (
  -- Subquery: Calculate average daily heart rate per user
  SELECT
    h.user_id,
    h.date,
    AVG(h.avg_heart_rate) AS avg_daily_heartrate,
    a.total_steps
  FROM heartrate_hourly h
  JOIN daily_activity_clean a
    ON h.user_id = a.id
    AND h.date = a.activity_date_clean
  GROUP BY h.user_id, h.date, a.total_steps
) t
GROUP BY activity_level;


-- ================================================
-- 6. Average Night Heart Rate
-- Purpose: Calculate overall average heart rate
--          during night hours across all users
-- Insight: Provides baseline for recovery analysis
--          and sleep quality assessment
-- ================================================
USE fitness_data;
SELECT
  ROUND(AVG(night_avg_heartrate), 0) AS avg_night_hr
FROM sleep_vs_night_heartrate;


-- ================================================
-- 7. Average Night Heart Rate vs Sleep Duration
-- Purpose: Create a table combining night heart rate
--          and sleep duration to analyse recovery patterns
-- Insight: Identifies relationship between elevated
--          night heart rate and reduced sleep quality
--          (R² = 0.66 strong negative correlation)
-- ================================================
USE fitness_data;
CREATE TABLE sleep_vs_night_heartrate AS
SELECT
  h.user_id,
  h.date,

  -- Average heart rate during night hours only
  ROUND(AVG(h.avg_heart_rate), 1) AS night_avg_heartrate,

  -- Convert sleep minutes to hours for readability
  ROUND(s.total_minutes_asleep / 60, 1) AS total_sleep_hours,
  ROUND(s.total_time_in_bed / 60, 1) AS time_in_bed_hours

FROM heartrate_hourly h

-- Join heart rate with sleep data on user and date
JOIN sleep_clean s
  ON h.user_id = s.id
  AND h.date = s.sleep_date

-- Filter for night hours only (11 PM to 6 AM)
WHERE h.hour IN (23, 0, 1, 2, 3, 4, 5, 6)

GROUP BY h.user_id, h.date, s.total_minutes_asleep, s.total_time_in_bed
LIMIT 20;
```

---
