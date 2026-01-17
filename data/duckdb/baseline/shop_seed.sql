-- jaffle_shop baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed customers
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email) VALUES
(1, 'Michael', 'Scott', 'michael.scott@dundermifflin.com'),
(2, 'Dwight', 'Schrute', 'dwight.schrute@dundermifflin.com'),
(3, 'Jim', 'Halpert', 'jim.halpert@dundermifflin.com'),
(4, 'Pam', 'Beesly', 'pam.beesly@dundermifflin.com'),
(5, 'Ryan', 'Howard', 'ryan.howard@dundermifflin.com');

-- Seed products
INSERT INTO jaffle_shop.products (product_id, name, category, price) VALUES
(1, 'Laptop', 'Electronics', 999.99),
(2, 'Mouse', 'Electronics', 29.99),
(3, 'Keyboard', 'Electronics', 79.99),
(4, 'Monitor', 'Electronics', 299.99),
(5, 'Desk Chair', 'Furniture', 199.99);

-- Seed orders
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status) VALUES
(1, 1, '2024-01-15', 'completed'),
(2, 2, '2024-01-16', 'completed'),
(3, 3, '2024-01-17', 'pending'),
(4, 4, '2024-01-18', 'completed'),
(5, 5, '2024-01-19', 'cancelled');

-- Seed order items
INSERT INTO jaffle_shop.order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1, 999.99),
(2, 1, 2, 2, 29.99),
(3, 2, 3, 1, 79.99),
(4, 3, 4, 1, 299.99),
(5, 4, 5, 1, 199.99);
