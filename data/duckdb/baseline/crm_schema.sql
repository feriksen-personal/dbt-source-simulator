-- jaffle_crm database schema
-- Marketing/CRM system tables

-- Campaigns table
CREATE TABLE IF NOT EXISTS jaffle_crm.campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2)
);

-- Email activity table
CREATE TABLE IF NOT EXISTS jaffle_crm.email_activity (
    activity_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    campaign_id INTEGER,
    sent_date TIMESTAMP,
    opened BOOLEAN,
    clicked BOOLEAN,
    FOREIGN KEY (campaign_id) REFERENCES jaffle_crm.campaigns(campaign_id)
);

-- Web sessions table
CREATE TABLE IF NOT EXISTS jaffle_crm.web_sessions (
    session_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    page_views INTEGER
);
