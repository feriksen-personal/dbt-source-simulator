-- jaffle_shop Day 02 delta changes
-- Simulates business activity on Day 02 after baseline

-- Add 22 new customers

UPDATE jaffle_shop.products
SET price = 1099.99,
    updated_at = CURRENT_TIMESTAMP
WHERE product_id = 1;  -- Laptop price increase
