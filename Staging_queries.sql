--DDL to create posthog_events
CREATE TABLE staging.posthog_events (
    event_date   DATE,
    user_id      VARCHAR(50),
    device       VARCHAR(50),
    event_type   VARCHAR(50)
);


--DDL to create marketing_performance
CREATE TABLE staging.marketing_performance (
    campaign_name   VARCHAR(255),
    date            DATE,
    spend           DECIMAL(18,2),
    impressions     BIGINT,
    clicks          BIGINT,
    conversions     BIGINT
);

--DDL to create application_data staging tables
CREATE TABLE staging.application_data (
    user_id             VARCHAR(50)    NOT NULL,
    country             VARCHAR(100),
    kyc_status          VARCHAR(20),
    total_transactions  INTEGER        DEFAULT 0,
    total_spent         DECIMAL(18,2)  DEFAULT 0.00
);
