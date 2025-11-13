--select * from mart_mart.dim_application_data;
--What is the Daily Active Users (DAU) for each day in October 2025? = 31
--Assumptions: Since there is no standard definition for an active user, I am assuming that any user who has performed the 
--following activities view_page, purchase, login, kyc_submitted is at least active.
select 
event_date,  
count(distinct user_id) as active_user_count
 from mart_mart.fact_posthog_events pe
 join mart_mart.dim_event_type et on pe.event_type_id = et.id
 where pe.event_date between '2025-10-01' and '2025-10-31'
 and et.event_type in ('view_page', 'purchase', 'login', 'kyc_submitted')
 group by 1
 order by 1 asc;

--What is the total number of users who made at least one purchase during the month? = 970
with base as (select 
user_id,  
count(user_id) as activity_count
 from mart_mart.fact_posthog_events pe
 join mart_mart.dim_event_type et on pe.event_type_id = et.id
 where pe.event_date between '2025-10-01' and '2025-10-31'
 and et.event_type in ('purchase')
 group by 1
 order by 2 asc)
 select count(user_id) from base;

 --How many KYC approvals were recorded each day, and how does this vary by device type?
select 
event_date,
device_type, 
count(user_id) as active_user_count
 from mart_mart.fact_posthog_events pe
 left join mart_mart.dim_event_type et on pe.event_type_id = et.id
 left join mart_mart.dim_device_type dt on pe.device_type_id = dt.id
 where pe.event_date between '2025-10-01' and '2025-10-31'
 and et.event_type in ('kyc_approved')
 group by 1, 2
 order by 1, 2 asc;


 --Which marketing campaign achieved the highest conversion rate and ROI?
 --Assumption: There is no clear data point to calculate campaign ROI. however, using the campaign date and event date, I was 
 -- able to get the campaign users which I then used to get a closer metrics to campaign ROI.
 --calculate conversion rate
 with base as (
 select campaign_name, 
 sum(campaign_spend) as total_campaign_spend,
 sum(impressions) as total_impressions,
 sum(clicks) as total_clicks,
 sum(conversions) as total_conversions
 from mart_mart.fact_marketing_performance mp
 left join mart_mart.dim_campaign c on mp.campaign_id = c.id
 group by 1
 )
 select 
 campaign_name,
 round((cast(total_conversions as float)/cast(total_clicks as float))*100, 2) as conversion_rate
 from base
 ;


 --calculate ROI
 WITH campaign_users AS (
    SELECT
        pe.user_id,
        c.campaign_name,
        mp.campaign_date,
        mp.campaign_spend,
        mp.conversions
    FROM mart_mart.fact_posthog_events pe
    JOIN mart_mart.fact_marketing_performance mp on pe.event_date = mp.campaign_date
    JOIN mart_mart.dim_campaign c on mp.campaign_id = c.id

),
user_revenue AS (
    SELECT
        user_id,
        SUM(total_spent) AS total_revenue
    FROM mart_mart.dim_application_data
    GROUP BY user_id
),
campaign_revenue AS (
    SELECT
        cu.campaign_name,
        SUM(ur.total_revenue) AS total_revenue,
        SUM(cu.campaign_spend) AS total_spend
    FROM campaign_users cu
    LEFT JOIN user_revenue ur ON cu.user_id = ur.user_id
    GROUP BY cu.campaign_name
)
SELECT
    campaign_name,
    total_revenue,
    total_spend,
    ROUND(((total_revenue - total_spend) / NULLIF(total_spend, 0)) * 100, 2) AS roi_percentage
FROM campaign_revenue
ORDER BY roi_percentage DESC;



--What is the average income level of transacting users?
--Assumptions: The data has no data point for user's income, what I have done is to infer the average income from their total spend.
SELECT
user_id,
    ROUND(AVG(total_spent), 2) AS avg_income_level
FROM mart_mart.dim_application_data
WHERE total_transactions > 0
group by 1;
 
