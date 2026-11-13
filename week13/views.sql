CREATE OR REPLACE VIEW order_summary_view AS
SELECT
    co.id AS order_id,
    co.order_date,
    co.status AS order_status,
    u.id AS customer_id,
    u.username AS customer_username,
    p.id AS product_id,
    p.name AS product_name,
    p.sku AS product_sku,
    oi.quantity,
    oi.price AS unit_price,
    (oi.quantity * oi.price) AS line_total
FROM customer_orders co
JOIN users u ON u.id = co.user_id
JOIN order_items oi ON oi.order_id = co.id
JOIN products p ON p.id = oi.product_id;