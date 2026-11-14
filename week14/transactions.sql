USE infoman1_week13_test;

SELECT id, name, sku, price, stock_quantity FROM products WHERE id IN (1, 2);
SELECT COUNT(*) AS orders_before FROM customer_orders;
SELECT COUNT(*) AS items_before FROM order_items;

START TRANSACTION;

SELECT id, name, price, stock_quantity
FROM products
WHERE id = 1
FOR UPDATE;

UPDATE products
SET stock_quantity = stock_quantity - 2
WHERE id = 1 AND stock_quantity >= 2;

SELECT ROW_COUNT() AS changed_product_rows;

INSERT INTO customer_orders (id, user_id, order_date, status)
VALUES (100, 1, '2026-11-14', 'CONFIRMED');

INSERT INTO order_items (id, order_id, product_id, quantity, price)
VALUES (100, 100, 1, 2, 1200.00);

COMMIT;

SELECT id, name, stock_quantity FROM products WHERE id = 1;
SELECT * FROM customer_orders WHERE id = 100;
SELECT * FROM order_items WHERE id = 100;

START TRANSACTION;

SELECT id, name, stock_quantity
FROM products
WHERE id = 1
FOR UPDATE;

UPDATE products
SET stock_quantity = stock_quantity - 2
WHERE id = 1 AND stock_quantity >= 2;

SELECT id, name, stock_quantity AS stock_mid_transaction FROM products WHERE id = 1;

ROLLBACK;

SELECT id, name, stock_quantity AS stock_after_rollback FROM products WHERE id = 1;
SELECT * FROM customer_orders WHERE id = 101;

START TRANSACTION;

SELECT id, stock_quantity FROM products WHERE id = 1 FOR UPDATE;

UPDATE products
SET stock_quantity = stock_quantity - 1
WHERE id = 1 AND stock_quantity >= 1;

SELECT ROW_COUNT() AS changed_rows_laptop;

SAVEPOINT after_laptop_deduction;

UPDATE products
SET stock_quantity = stock_quantity - 3
WHERE id = 2 AND stock_quantity >= 3;

SELECT id, name, stock_quantity AS mid_both_changed FROM products WHERE id IN (1, 2);

ROLLBACK TO SAVEPOINT after_laptop_deduction;

SELECT id, name, stock_quantity AS after_savepoint_rollback FROM products WHERE id IN (1, 2);

ROLLBACK;

SELECT id, name, stock_quantity AS after_full_rollback FROM products WHERE id IN (1, 2);