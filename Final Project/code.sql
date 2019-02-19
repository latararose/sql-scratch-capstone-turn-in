-- First 100 rows of data

SELECT *
 from subscriptions
 limit 100;

-- Verify segment count

SELECT count(id), segment
 from subscriptions
 group by segment;

-- Months in Operation

select min(subscription_start), max(subscription_start)
 from subscriptions;

-- Subscription Start Data

select min(subscription_start), max(subscription_start)
 from subscriptions;

-- Cancellation Data

select min(subscription_end), max(subscription_end)
 from subscriptions;

-- Temporary months table and cross join with subscriptions table 

with months AS 
(select 
 '2017-01-01' AS first_day,
 '2017-01-31' AS last_day
 union
 select 
 '2017-02-01' AS first_day,
 '2017-02-28' AS last_day
 union
 select 
 '2017-03-01' AS first_day,
'2017-03-31' AS last_day
),
cross_join AS 
( select * from subscriptions
 cross join months
) select * from cross_join limit 10;

-- Full query to calculate company churn rate for each month

with months AS 
(select 
 '2017-01-01' AS first_day,
 '2017-01-31' AS last_day
 union
 select 
 '2017-02-01' AS first_day,
 '2017-02-28' AS last_day
 union
 select 
 '2017-03-01' AS first_day,
'2017-03-31' AS last_day
),
cross_join AS 
( select * from subscriptions
 cross join months
), 
status AS 
(select
 id,
 first_day AS month, segment,
 case
 		when (subscription_start < first_day) and (subscription_end > first_day or subscription_end is null) then 1
 		else 0
 end AS is_active,
case
 		when (subscription_end between first_day and last_day) then 1 
 		else 0
 end AS is_canceled
 from cross_join
), status_aggregate AS 
(select month,
 sum(is_active) AS sum_active,
 sum(is_canceled) AS sum_canceled
 from status
 group by month
) select month, 
1.0 * sum_canceled/sum_active AS churn_rate
from status_aggregate;

-- Full query to calculate company churn rate for each month and each segment 

with months AS 
(select 
 '2017-01-01' AS first_day,
 '2017-01-31' AS last_day
 union
 select 
 '2017-02-01' AS first_day,
 '2017-02-28' AS last_day
 union
 select 
 '2017-03-01' AS first_day,
'2017-03-31' AS last_day
),
cross_join AS 
( select * from subscriptions
 cross join months
), 
status AS 
(select
 id,
 first_day AS month,
 case
 when (subscription_start < first_day) and (subscription_end > first_day or subscription_end is null) and (segment = 87) then 1
 else 0
 end AS is_active_87,
case
 when (subscription_start < first_day) and
(subscription_end > first_day or subscription_end is null) and (segment = 30) then 1
else 0
end AS is_active_30,
case
when (subscription_end between first_day and last_day) and (segment = 87) then 1 
 else 0
 end AS is_canceled_87,
 case
 when (subscription_end between first_day and last_day) and (segment = 30) then 1 
 		else 0
 end AS is_canceled_30
 from cross_join
), status_aggregate AS 
(select month,
 sum(is_active_87) AS sum_active_87,
 sum(is_active_30) AS sum_active_30,
 sum(is_canceled_87) AS sum_canceled_87,
 sum(is_canceled_30) AS sum_canceled_30
 from status
 group by month
) select month, 
1.0 * sum_canceled_87/sum_active_87 AS churn_rate_87,
1.0 * sum_canceled_30/sum_active_30 AS churn_rate_30
from status_aggregate;


