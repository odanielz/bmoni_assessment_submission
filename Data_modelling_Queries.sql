--query to create device_type dimension table
{{
    config(
        materialize="table",
        unique_key="id",
        schema="mart",
        sort=["id"],
        dist="auto"
    )
}}

with
    source as (
        select
            decode(device, 'Android', 1, 'iOS', 2, 'Web', 3) as id,
            device as device_type
        from staging.posthog_events
    )
select distinct id, device_type
from source


--query to create event_type dimension table
{{
    config(
        materialize="table",
        unique_key="id",
        schema="mart",
        sort=["id"],
        dist="auto"
    )
}}

with
    source as (
        select
            decode(
                event_type,
                'view_page',
                1,
                'purchase',
                2,
                'kyc_approved',
                3,
                'login',
                4,
                'kyc_submitted',
                5
            ) as id,
            event_type
        from staging.posthog_events
    )
select distinct id, event_type
from source


--query to create marketing_performance fact table
{{
    config(
        materialize="table",
        schema="mart",
        sort=["campaign_id, campaign_date"],
        dist="auto"
    )
}}

with
    source as (
        select
            decode(
                campaign_name,
                'Campaign_1',
                1,
                'Campaign_2',
                2,
                'Campaign_3',
                3,
                'Campaign_4',
                4,
                'Campaign_5',
                5
            ) campaign_id,
            date as campaign_date,
            spend as campaign_spend,
            impressions,
            clicks,
            conversions
        from staging.marketing_performance
    )
select *
from source

--query to create posthog_events fact table
{{
    config(
        materialize="table",
        schema="mart",
        sort=["user_id", "device_type_id", "event_type_id"],
        dist="auto"
    )
}}

select
    event_date,
    user_id,
    decode(device, 'Android', 1, 'iOS', 2, 'Web', 3) as device_type_id,
    decode(
        event_type,
        'view_page',
        1,
        'purchase',
        2,
        'kyc_approved',
        3,
        'login',
        4,
        'kyc_submitted',
        5
    ) as event_type_id
from staging.posthog_events

--query to create application_data dimension table
{{
    config(
        materialize="table",
        unique_key="user_id",
        schema="mart",
        sort=["user_id"],
        dist="auto"
    )
}}
select * from staging.application_data

--query to create campaign_dimension table
{{
    config(
        materialize="table",
        unique_key="id",
        schema="mart",
        sort=["id"],
        dist="auto"
    )
}}

with source as (
select 
decode(campaign_name,
'Campaign_1', 1,
'Campaign_2', 2,
'Campaign_3', 3,
'Campaign_4', 4,
'Campaign_5', 5
) id,
campaign_name
from staging.marketing_performance
)
select distinct id, campaign_name from source
