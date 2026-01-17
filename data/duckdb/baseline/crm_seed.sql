-- jaffle_crm baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed campaigns (created within last 30 days, with logical date ranges)
INSERT INTO jaffle_crm.campaigns (campaign_id, campaign_name, start_date, end_date, budget, created_at, updated_at, deleted_at) VALUES
-- Campaign 1: Created 30 days ago, ran for 10 days (now ended)
(1, 'New Year Sale', CURRENT_DATE - 28, CURRENT_DATE - 18, 5000.00, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days', NULL),
-- Campaign 2: Created 20 days ago, started 18 days ago, running now (ends in 2 days)
(2, 'Flash Deals', CURRENT_DATE - 18, CURRENT_DATE + 2, 7500.00, CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_TIMESTAMP - INTERVAL '20 days', NULL),
-- Campaign 3: Created 10 days ago, started 8 days ago, runs for 2 more weeks
(3, 'Customer Appreciation', CURRENT_DATE - 8, CURRENT_DATE + 14, 6000.00, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '10 days', NULL);

-- Seed email activity (events from last 5 days, tied to active campaigns)
INSERT INTO jaffle_crm.email_activity (activity_id, customer_id, campaign_id, sent_date, opened, clicked, created_at, updated_at, deleted_at) VALUES
(1, 1, 2, CURRENT_TIMESTAMP - INTERVAL '5 days', true, true, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(2, 2, 2, CURRENT_TIMESTAMP - INTERVAL '5 days', true, false, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(3, 3, 2, CURRENT_TIMESTAMP - INTERVAL '5 days', false, false, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(4, 4, 3, CURRENT_TIMESTAMP - INTERVAL '2 days', true, true, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', NULL),
(5, 5, 3, CURRENT_TIMESTAMP - INTERVAL '2 days', true, true, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', NULL);

-- Seed web sessions (activity from last 5 days)
INSERT INTO jaffle_crm.web_sessions (session_id, customer_id, session_start, session_end, page_views, created_at, updated_at, deleted_at) VALUES
(1, 1, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', 12, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(2, 2, CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days', 5, CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days', NULL),
(3, 3, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', 20, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', NULL),
(4, 4, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', 8, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', NULL),
(5, 5, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day', 3, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day', NULL);
