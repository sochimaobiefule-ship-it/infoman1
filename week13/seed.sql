INSERT INTO users (id, username, email) VALUES
(1, 'capstone_user', 'capstone@example.com'),
(2, 'maria_santos', 'maria.santos@example.com'),
(3, 'justice_singh', 'singh.justice21@gmail.com');

INSERT INTO products (id, name, sku, category, price, stock_quantity) VALUES
(1, 'Laptop', 'LAP-001', 'Electronics', 1200.00, 10),
(2, 'Wireless Gaming Mouse', 'MOUSE-LOGI-01', 'Peripherals', 49.99, 25),
(3, 'Mechanical Keyboard', 'KEY-200', 'Peripherals', 89.99, 15),
(4, 'USB-C Docking Station', 'DOCK-405', 'Accessories', 135.00, 8);

INSERT INTO customer_orders (id, user_id, order_date, status) VALUES
(1, 1, '2026-10-15', 'CONFIRMED'),
(2, 3, '2026-11-12', 'CONFIRMED'),
(3, 2, '2026-11-13', 'CONFIRMED');

INSERT INTO order_items (id, order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1, 1200.00),
(2, 2, 1, 2, 1200.00),
(3, 3, 2, 3, 49.99);