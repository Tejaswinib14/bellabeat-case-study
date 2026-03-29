-- ================================================
-- Bellabeat Case Study -- BigQuery SQL Queries
-- Author: Tejaswini Bhalerao
-- Tool: Google BigQuery
-- Data: FitBit Fitness Tracker Dataset (Kaggle)
-- Purpose: Analyse smart device usage patterns to
--          generate insights for Bellabeat
-- ================================================


-- ================================================
-- 1. Total Unique Users
-- Purpose:Identify number of distinct users in dataset
-- Insight: Helps understand dataset size and user coverage
-- ================================================
SELECT 
  COUNT(DISTINCT id) AS total_users
FROM `corded-nature-467221-g0.bellabeat_fitness.daily_activity`;


-- ================================================
-- 2. Average Daily Steps Across All Users
-- Purpose: Understand overall activity level of users
-- Insight: Helps determine if users meet recommended daily 10,000 step goals
-- ================================================
SELECT 
  AVG(total_steps) AS avg_daily_steps
FROM `corded-nature-467221-g0.bellabeat_fitness.daily_activity`;


-- ================================================
-- 3. Average Steps by Day of Week
-- Purpose: Identify activity patterns across weekdays vs weekends
-- Insight: Helps detect behavioral trends in user activity 
-- ================================================
SELECT
  day_of_week,
  ROUND(AVG(total_steps), 0) AS avg_steps_per_day
FROM `corded-nature-467221-g0.bellabeat_fitness.daily_activity`
GROUP BY day_of_week
ORDER BY day_of_week;


-- ================================================
-- 4. Activity Level Classification
-- Purpose: Categorize users based on steps and active minutes
-- Insight: Helps segment users into activity groups for analysis
-- ================================================
SELECT
  id,
  activity_date,
  total_steps,

  -- Calculate total active minutes
  lightly_active_minutes + fairly_active_minutes + very_active_minutes AS total_active_minutes,

  -- Categorize users based on daily step count
  CASE
    WHEN total_steps < 5000 THEN 'Sedentary'
    WHEN total_steps BETWEEN 5000 AND 7499 THEN 'Less Active'
    WHEN total_steps BETWEEN 7500 AND 9999 THEN 'Moderately Active'
    WHEN total_steps BETWEEN 10000 AND 12499 THEN 'Active'
    ELSE 'Highly Active'
  END AS steps_category,
  
  -- Categorize users based on total active minutes
  CASE
    WHEN (lightly_active_minutes + fairly_active_minutes + very_active_minutes) < 30 THEN 'Low Activity'
    WHEN (lightly_active_minutes + fairly_active_minutes + very_active_minutes) BETWEEN 30 AND 59 THEN 'Moderate Activity'
    ELSE 'High Activity'
  END AS active_minutes_category
  
FROM `corded-nature-467221-g0.bellabeat_fitness.daily_activity`
ORDER BY activity_date;


-- ================================================
-- 5. Activity Level Distribution
-- Purpose: Calculate percentage of users in each activity category
-- Insight: Helps understand overall user engagement levels
-- ================================================
WITH classified AS (
  SELECT
    id,
    activity_date,
    total_steps,

    -- Calculate total active minutes per user per day
    (lightly_active_minutes + fairly_active_minutes + very_active_minutes) AS total_active_minutes,
  
    -- Combined classification using steps AND active minutes
    CASE
      WHEN total_steps >= 10000
        AND (lightly_active_minutes + fairly_active_minutes + very_active_minutes) >= 60 THEN 'Highly Active'
      WHEN total_steps BETWEEN 7500 AND 9999
        AND (lightly_active_minutes + fairly_active_minutes + very_active_minutes) >= 60 THEN 'Active'
      WHEN total_steps BETWEEN 7500 AND 9999
        AND (lightly_active_minutes + fairly_active_minutes + very_active_minutes) BETWEEN 30 AND 59 THEN 'Moderately Active'
      WHEN total_steps < 5000
        AND (lightly_active_minutes + fairly_active_minutes + very_active_minutes) < 30 THEN 'Sedentary'
      ELSE 'Lightly Active'
    END AS activity_level
  
  FROM `corded-nature-467221-g0.bellabeat_fitness.daily_activity`
)

SELECT
  activity_level,
  COUNT(*) AS total_days,

  -- Calculate percentage distribution across activity levels
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
  
FROM classified
GROUP BY activity_level
ORDER BY percentage DESC;


