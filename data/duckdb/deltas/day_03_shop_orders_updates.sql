-- jaffle_shop Day 03 delta changes
-- Simulates business activity on Day 03 after baseline

-- Add 28 new customers

UPDATE jaffle_shop.orders
SET status = 'cancelled',
    updated_at = CURRENT_TIMESTAMP
WHERE order_id IN (310, 318, 293);
