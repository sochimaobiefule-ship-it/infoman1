CREATE DATABASE IF NOT EXISTS webdev2_week16_test;
USE webdev2_week16_test;

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

CREATE OR REPLACE SQL SECURITY DEFINER VIEW product_sales_summary AS
SELECT
    p.id AS product_id,
    p.sku,
    p.name AS product_name,
    COALESCE(p.category, 'Uncategorized') AS category,
    p.price AS unit_price,
    p.stock_quantity,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.quantity * oi.price), 0.00) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.id
GROUP BY p.id, p.sku, p.name, p.category, p.price, p.stock_quantity;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE order_items;
TRUNCATE TABLE customer_orders;
TRUNCATE TABLE products;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO users (id, username, email, role, password_hash) VALUES
    (1, 'test_buyer_1', 'buyer1@example.test', 'READER', '\$2a\$10\$placeholderhashvalue0000000000000000000000000000000001'),
    (2, 'test_manager_1', 'mgr1@example.test', 'MANAGER', '\$2a\$10\$placeholderhashvalue0000000000000000000000000000000002');

INSERT INTO products (id, sku, name, category, price, stock_quantity) VALUES
    (101, 'TEST-LAP-01', 'Test Laptop', 'Electronics', 1000.00, 10),
    (102, 'TEST-MSE-02', 'Test Mouse', 'Electronics', 50.00, 20),
    (103, 'TEST-USB-03', 'Unsold USB Hub', 'Accessories', 25.00, 15);

INSERT INTO customer_orders (id, user_id, order_date, status) VALUES
    (501, 1, '2026-11-25 09:00:00', 'CONFIRMED'),
    (502, 1, '2026-11-25 10:00:00', 'CONFIRMED');

INSERT INTO order_items (id, order_id, product_id, quantity, price) VALUES
    (901, 501, 101, 2, 1000.00),
    (902, 501, 102, 3, 50.00),
    (903, 502, 102, 1, 50.00);

SELECT * FROM product_sales_summary ORDER BY product_id;

SELECT * FROM order_summary_view ORDER BY order_id, product_id;

SELECT * FROM products WHERE id = 999999;

INSERT INTO products (sku, name, category, price, stock_quantity)
VALUES ('TEST-LAP-01', 'Duplicate Laptop', 'Electronics', 999.00, 5);

INSERT INTO customer_orders (user_id, order_date, status)
VALUES (9999, '2026-11-25 11:00:00', 'CONFIRMED');

DELETE FROM products WHERE id = 101;

SELECT id, sku, name, stock_quantity FROM products ORDER BY id;

START TRANSACTION;
INSERT INTO customer_orders (id, user_id, order_date, status)
VALUES (503, 1, '2026-11-25 12:00:00', 'CONFIRMED');
INSERT INTO order_items (id, order_id, product_id, quantity, price)
VALUES (904, 503, 103, 2, 25.00);
UPDATE products SET stock_quantity = stock_quantity - 2 WHERE id = 103;
COMMIT;

SELECT id, sku, stock_quantity FROM products WHERE id = 103;

START TRANSACTION;
UPDATE products SET stock_quantity = stock_quantity - 3 WHERE id = 103;
INSERT INTO customer_orders (id, user_id, order_date, status)
VALUES (504, 9999, '2026-11-25 12:05:00', 'CONFIRMED');
ROLLBACK;

SELECT id, sku, stock_quantity FROM products WHERE id = 103;
SELECT COUNT(*) AS rolled_back_order_count FROM customer_orders WHERE id = 504;

EXPLAIN
SELECT
    co.id AS order_id,
    co.order_date,
    u.username,
    p.sku,
    oi.quantity,
    oi.price
FROM customer_orders co
JOIN users u ON u.id = co.user_id
JOIN order_items oi ON oi.order_id = co.id
JOIN products p ON p.id = oi.product_id
WHERE co.status = 'CONFIRMED'
  AND p.category = 'Electronics'
ORDER BY co.order_date DESC;

SHOW GRANTS FOR 'webdev2_app'@'localhost';
SHOW GRANTS FOR 'webdev2_report'@'localhost';