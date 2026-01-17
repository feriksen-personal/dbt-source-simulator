-- jaffle_crm baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed campaigns
INSERT INTO jaffle_crm.campaigns (campaign_id, campaign_name, start_date, end_date, budget) VALUES
(1, 'Spring Sale 2024', '2024-03-01', '2024-03-31', 5000.00),
(2, 'Summer Promotion', '2024-06-01', '2024-06-30', 7500.00),
(3, 'Back to School', '2024-08-01', '2024-08-31', 6000.00);

-- Seed email activity
INSERT INTO jaffle_crm.email_activity (activity_id, customer_id, campaign_id, sent_date, opened, clicked) VALUES
(1, 1, 1, '2024-03-05 10:00:00', true, true),
(2, 2, 1, '2024-03-05 10:05:00', true, false),
(3, 3, 1, '2024-03-05 10:10:00', false, false),
(4, 4, 2, '2024-06-05 14:00:00', true, true),
(5, 5, 2, '2024-06-05 14:05:00', true, true);

-- Seed web sessions
INSERT INTO jaffle_crm.web_sessions (session_id, customer_id, session_start, session_end, page_views) VALUES
(1, 1, '2024-03-06 09:00:00', '2024-03-06 09:30:00', 12),
(2, 2, '2024-03-06 10:00:00', '2024-03-06 10:15:00', 5),
(3, 3, '2024-03-07 15:00:00', '2024-03-07 15:45:00', 20),
(4, 4, '2024-06-06 11:00:00', '2024-06-06 11:25:00', 8),
(5, 5, '2024-06-06 16:00:00', '2024-06-06 16:10:00', 3);
