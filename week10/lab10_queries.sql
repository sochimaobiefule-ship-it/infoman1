-- INFOMAN1 - Week 10: Safe DML & Data Integrity Practical Test
CREATE DATABASE IF NOT EXISTS infoman1_bookstore;
USE infoman1_bookstore;

CREATE TABLE products (
  product_id INT PRIMARY KEY AUTO_INCREMENT,
  product_name VARCHAR(100),
  sku VARCHAR(30),
  price DECIMAL(10,2),
  stock_quantity INT,
  status VARCHAR(20)
);

CREATE TABLE sales (
  sale_id INT PRIMARY KEY AUTO_INCREMENT,
  product_id INT,
  sale_date DATE,
  quantity INT,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE employees (
  employee_id INT PRIMARY KEY,
  employee_name VARCHAR(100) NOT NULL,
  manager_id INT
);

CREATE TABLE colors (
  color_name VARCHAR(30) PRIMARY KEY
);

CREATE TABLE sizes (
  size_name VARCHAR(10) PRIMARY KEY
);

INSERT INTO products (product_name, sku, price, stock_quantity, status) VALUES
  ('Notebook', 'NB-001', 45.00, 100, 'Active'),
  ('Ballpen', 'BP-001', 15.00, 250, 'Active'),
  ('USB Drive', 'USB-001', 350.00, 30, 'Active'),
  ('Ruler', 'RL-001', 25.00, 80, 'Active'),
  ('Eraser', 'ER-001', 10.00, 200, 'Active');

INSERT INTO sales (product_id, sale_date, quantity) VALUES
  (1, '2026-08-10', 5),
  (2, '2026-08-11', 10);

INSERT INTO employees VALUES
  (1, 'Lea Ramos', NULL),
  (2, 'Carlo Reyes', 1),
  (3, 'Dana Cruz', 1);

INSERT INTO colors VALUES ('Red'), ('Blue'), ('Green');
INSERT INTO sizes VALUES ('S'), ('M'), ('L');


-- TASK 1: Safe INSERT

-- Insert Scientific Calculator
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');

mysql> SELECT * FROM products WHERE sku = 'CALC-SCI-001';

-- Insert Compass
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');

mysql> SELECT * FROM products WHERE sku = 'CMP-001';    

-- Insert Highlighter
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Highlighter', 'HL-001', 'eighty pesos', 100, 'Active');

-- Rejected Insert Test (Wrong Data Type)
-- INSERT INTO products (product_name, sku, price, stock_quantity, status) 
-- VALUES ('Highlighter', 'HL-001', 'eighty pesos', 100, 'Active');


-- TASK 2: UPDATE & DELETE Without Collateral Damage

-- UPDATE
SELECT * FROM products WHERE product_id = 6;
UPDATE products SET price = 875.00 WHERE product_id = 6;
SELECT * FROM products WHERE product_id = 6;

-- DELETE
SELECT * FROM products WHERE product_id = 5;
DELETE FROM products WHERE product_id = 5;
SELECT * FROM products WHERE product_id = 5;


-- TASK 3: Self Join & Cross Join

-- Self Join
mysql> SELECT
    -> e.employee_id,
    -> e.employee_name AS employee,
    -> m.employee_name AS manager
    -> FROM employees AS e
    -> LEFT JOIN employees AS m ON e.manager_id = m.employee_id;

-- Cross join
mysql> SELECT
    -> c. color_name,
    -> s. size_name
    -> FROM colors AS c
    -> CROSS JOIN sizes AS s;

-- Combination Count Check
mysql> SELECT COUNT(*) AS total_combinations
    -> FROM colors CROSS JOIN sizes;


-- TASK 4: Constraints & Table Evolution

-- Schema evolution
ALTER TABLE products ADD COLUMN contact_number VARCHAR(20);
ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;
ALTER TABLE products ADD CONSTRAINT unique_sku UNIQUE (sku);
ALTER TABLE products ADD CONSTRAINT check_price_positive CHECK (price > 0);

-- Passing write
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Stapler', 'STP-001', 150.00, 15, 'Active');

-- Rejected writes
-- a. product_name NOT NULL
-- mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
--     -> VALUES (NULL, 'STP-002', 150.00, 15, 'Active');

-- b. sku UNIQUE
-- mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
--     -> VALUES ('Mini Stapler', 'STP-001', 95.00, 10, 'Active');

-- c. CHECK (price > 0)
-- mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
--     ->   VALUES ('Free Coupon', 'CPN-001', -10.00, 100, 'Active');