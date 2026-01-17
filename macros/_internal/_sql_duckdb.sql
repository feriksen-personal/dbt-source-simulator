{#
  Internal macros that return SQL content for DuckDB adapter.
  Each macro returns the SQL as a string to be executed via run_query().

  This file is auto-generated from SQL files in data/duckdb/.
  To regenerate, run: python /tmp/convert_sql_to_macros.py
#}

{% macro _get_duckdb_baseline_shop_schema() %}
-- Create schema first
CREATE SCHEMA IF NOT EXISTS jaffle_shop;

-- jaffle_shop database schema
-- E-commerce/ERP system tables

-- Customers table
CREATE TABLE IF NOT EXISTS jaffle_shop.customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- NULL = active, non-NULL = soft deleted
);

-- Products table
CREATE TABLE IF NOT EXISTS jaffle_shop.products (
    product_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- NULL = active, non-NULL = discontinued
);

-- Orders table
CREATE TABLE IF NOT EXISTS jaffle_shop.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,  -- NULL = active, non-NULL = cancelled/deleted
    FOREIGN KEY (customer_id) REFERENCES jaffle_shop.customers(customer_id)
);

-- Order items table
CREATE TABLE IF NOT EXISTS jaffle_shop.order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,  -- Rarely used (line items typically immutable)
    FOREIGN KEY (order_id) REFERENCES jaffle_shop.orders(order_id),
    FOREIGN KEY (product_id) REFERENCES jaffle_shop.products(product_id)
);
{% endmacro %}

{% macro _get_duckdb_baseline_shop_seed() %}
-- jaffle_shop baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed customers (spread over 5 days to show customer acquisition pattern)
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at) VALUES
(1, 'Michael', 'Scott', 'michael.scott@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(2, 'Dwight', 'Schrute', 'dwight.schrute@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days', NULL),
(3, 'Jim', 'Halpert', 'jim.halpert@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', NULL),
(4, 'Pam', 'Beesly', 'pam.beesly@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', NULL),
(5, 'Ryan', 'Howard', 'ryan.howard@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day', NULL);

-- Seed products (created 30 days ago - established catalog)
INSERT INTO jaffle_shop.products (product_id, name, category, price, created_at, updated_at, deleted_at) VALUES
(1, 'Laptop', 'Electronics', 999.99, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days', NULL),
(2, 'Mouse', 'Electronics', 29.99, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days', NULL),
(3, 'Keyboard', 'Electronics', 79.99, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days', NULL),
(4, 'Monitor', 'Electronics', 299.99, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP - INTERVAL '30 days', NULL),
(5, 'Desk Chair', 'Furniture', 199.99, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '15 days', NULL);

-- Seed orders (recent activity over last 5 days)
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at) VALUES
-- Order 1: Created 5 days ago, completed next day
(1, 1, CURRENT_DATE - 5, 'completed', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '4 days', NULL),
-- Order 2: Created 4 days ago, completed next day
(2, 2, CURRENT_DATE - 4, 'completed', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '3 days', NULL),
-- Order 3: Created 3 days ago, still pending
(3, 3, CURRENT_DATE - 3, 'pending', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', NULL),
-- Order 4: Created 2 days ago, completed next day
(4, 4, CURRENT_DATE - 2, 'completed', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '1 day', NULL),
-- Order 5: Created 1 day ago, cancelled same day
(5, 5, CURRENT_DATE - 1, 'cancelled', CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day', NULL);

-- Seed order items (created with their orders, immutable)
INSERT INTO jaffle_shop.order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at, deleted_at) VALUES
(1, 1, 1, 1, 999.99, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(2, 1, 2, 2, 29.99, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', NULL),
(3, 2, 3, 1, 79.99, CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days', NULL),
(4, 3, 4, 1, 299.99, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', NULL),
(5, 4, 5, 1, 199.99, CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', NULL);
{% endmacro %}

{% macro _get_duckdb_baseline_crm_schema() %}
-- Create schema first
CREATE SCHEMA IF NOT EXISTS jaffle_crm;

-- jaffle_crm database schema
-- Marketing/CRM system tables

-- Campaigns table
CREATE TABLE IF NOT EXISTS jaffle_crm.campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- NULL = active, non-NULL = archived
);

-- Email activity table (append-only event stream)
CREATE TABLE IF NOT EXISTS jaffle_crm.email_activity (
    activity_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    campaign_id INTEGER,
    sent_date TIMESTAMP,
    opened BOOLEAN,
    clicked BOOLEAN,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- When event was recorded
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Rarely changes (append-only)
    deleted_at TIMESTAMP,  -- Rarely used (events are immutable)
    FOREIGN KEY (campaign_id) REFERENCES jaffle_crm.campaigns(campaign_id)
);

-- Web sessions table (append-only event stream)
CREATE TABLE IF NOT EXISTS jaffle_crm.web_sessions (
    session_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    page_views INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- When session was recorded
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Could update if session extends
    deleted_at TIMESTAMP  -- Rarely used
);
{% endmacro %}

{% macro _get_duckdb_baseline_crm_seed() %}
-- jaffle_crm baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed campaigns (created within last 30 days, with logical date ranges)
INSERT INTO jaffle_crm.campaigns (campaign_id, campaign_name, start_date, end_date, budget, created_at, updated_at, deleted_at) VALUES
-- Campaign 1: Created 30 days ago, ran for 10 days (now ended)
(1, 'New Year Sale', CURRENT_DATE - 28, CURRENT_DATE - 18, 5000.00, CURRENT_DATE - 30, CURRENT_DATE - 30, NULL),
-- Campaign 2: Created 20 days ago, started 18 days ago, running now (ends in 2 days)
(2, 'Flash Deals', CURRENT_DATE - 18, CURRENT_DATE + 2, 7500.00, CURRENT_DATE - 20, CURRENT_DATE - 20, NULL),
-- Campaign 3: Created 10 days ago, started 8 days ago, runs for 2 more weeks
(3, 'Customer Appreciation', CURRENT_DATE - 8, CURRENT_DATE + 14, 6000.00, CURRENT_DATE - 10, CURRENT_DATE - 10, NULL);

-- Seed email activity (events from last 5 days, tied to active campaigns)
INSERT INTO jaffle_crm.email_activity (activity_id, customer_id, campaign_id, sent_date, opened, clicked, created_at, updated_at, deleted_at) VALUES
(1, 1, 2, CURRENT_DATE - 5, true, true, CURRENT_DATE - 5, CURRENT_DATE - 5, NULL),
(2, 2, 2, CURRENT_DATE - 5, true, false, CURRENT_DATE - 5, CURRENT_DATE - 5, NULL),
(3, 3, 2, CURRENT_DATE - 5, false, false, CURRENT_DATE - 5, CURRENT_DATE - 5, NULL),
(4, 4, 3, CURRENT_DATE - 2, true, true, CURRENT_DATE - 2, CURRENT_DATE - 2, NULL),
(5, 5, 3, CURRENT_DATE - 2, true, true, CURRENT_DATE - 2, CURRENT_DATE - 2, NULL);

-- Seed web sessions (activity from last 5 days)
INSERT INTO jaffle_crm.web_sessions (session_id, customer_id, session_start, session_end, page_views, created_at, updated_at, deleted_at) VALUES
(1, 1, CURRENT_DATE - 5, CURRENT_DATE - 5, 12, CURRENT_DATE - 5, CURRENT_DATE - 5, NULL),
(2, 2, CURRENT_DATE - 4, CURRENT_DATE - 4, 5, CURRENT_DATE - 4, CURRENT_DATE - 4, NULL),
(3, 3, CURRENT_DATE - 3, CURRENT_DATE - 3, 20, CURRENT_DATE - 3, CURRENT_DATE - 3, NULL),
(4, 4, CURRENT_DATE - 2, CURRENT_DATE - 2, 8, CURRENT_DATE - 2, CURRENT_DATE - 2, NULL),
(5, 5, CURRENT_DATE - 1, CURRENT_DATE - 1, 3, CURRENT_DATE - 1, CURRENT_DATE - 1, NULL);
{% endmacro %}

{% macro _get_duckdb_utilities_truncate_shop() %}
-- Truncate all jaffle_shop tables
-- Order matters: delete child tables before parent tables to avoid FK constraint errors

-- Delete order items first (has FKs to orders and products)
DELETE FROM jaffle_shop.order_items;

-- Delete orders next (has FK to customers)
DELETE FROM jaffle_shop.orders;

-- Delete products (no dependencies on it anymore)
DELETE FROM jaffle_shop.products;

-- Delete customers last (no dependencies on it anymore)
DELETE FROM jaffle_shop.customers;
{% endmacro %}

{% macro _get_duckdb_utilities_truncate_crm() %}
-- Truncate all jaffle_crm tables
-- Order matters: delete child tables before parent tables to avoid FK constraint errors

-- Delete email activity first (has FK to campaigns)
DELETE FROM jaffle_crm.email_activity;

-- Delete web sessions (no FK dependencies)
DELETE FROM jaffle_crm.web_sessions;

-- Delete campaigns last (was referenced by email_activity)
DELETE FROM jaffle_crm.campaigns;
{% endmacro %}
