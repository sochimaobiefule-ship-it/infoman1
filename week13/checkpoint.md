# INFOMAN1 Week 13 — Reproducibility & Verification Checkpoint

**Name:** OBIEFULE DECLAN  
**Student ID:** 2510223  
**Date:** 13/11/2026  

---

## 1. Environment & Project Locations

* **MySQL Server Version:** `9.7.2` (checked in MySQL CLI with `SELECT VERSION();`)
* **Who Owns Schema Changes:** My standalone SQL files (`schema.sql`, `seed.sql`, `views.sql`) own clean database setup and views for INFOMAN1. In my Spring Boot project, JPA/Hibernate maps to the existing tables in `webdev2_week8` (`spring.jpa.hibernate.ddl-auto=update`), so I tested the SQL scripts in a separate database (`infoman1_week13_test`) to make sure Hibernate would not overwrite my manual `CHECK` constraints or views.
* **Database Submission Repository & Folder:** `https://github.com/sochimaobiefule-ship-it/infoman1` (`main` branch, folder `week13/`)
* **Application Repository & Branch:** `https://github.com/sochimaobiefule-ship-it/webdev2` (`week13` and `week14` branches)

---

## 2. How to Rebuild the Database

To recreate the database cleanly without touching existing development data, create an empty test database and run the three SQL scripts in parent-before-child order:

```sql
CREATE DATABASE infoman1_week13_test;
USE infoman1_week13_test;

schema.sql
CREATE TABLE IF NOT EXISTS users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    sku VARCHAR(60) NOT NULL,
    category VARCHAR(80) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT uq_products_sku UNIQUE (sku),
    CONSTRAINT chk_products_price CHECK (price > 0),
    CONSTRAINT chk_products_stock CHECK (stock_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customer_orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'CONFIRMED',
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES customer_orders(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_items_price CHECK (price >= 0)
) ENGINE=InnoDB;

seed.sql;
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

views.sql;
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

```

1. `schema.sql` — Creates `users`, `products`, `customer_orders`, and `order_items` using InnoDB with primary keys, foreign keys, `UNIQUE` constraints, and `CHECK` rules.
2. `seed.sql` — Inserts sample users, products, orders, and order items in parent-before-child order so joins work right away.
3. `views.sql` — Creates `order_summary_view` to join orders, customers, and products into one readable report.

---

## 3. Configuration Variable Names

In `src/main/resources/application.properties`, Spring Boot reads the MySQL connection settings from local environment variables instead of hardcoded passwords:

* `DB_URL` — JDBC connection string pointing to the local MySQL database
* `DB_USERNAME` — Local MySQL account username
* `DB_PASSWORD` — Local MySQL password

---

## 4. Requirement & Evidence Map

| Requirement / Check | How I Verified It | Evidence File |
| --- | --- | --- |
| Schema builds with PK, FK, `UNIQUE`, and `CHECK` constraints | Ran `SHOW TABLES;` and `SHOW CREATE TABLE` on `order_items` and `products` in `infoman1_week13_test` | `evidence/schema_and_constraints.png` |
| View shows live data after a base-table update | Queried `order_summary_view`, ran `UPDATE order_items SET quantity = 4 WHERE id = 1;`, and re-queried the view (`line_total` changed from `1200.00` to `4800.00`) | `evidence/view_before_after.png` |
| Database blocks invalid `UNIQUE`, `FK`, and `CHECK` inserts | Tested duplicate SKU `'LAP-001'` (`ERROR 1062`), non-existent `user_id = 999` (`ERROR 1452`), and `stock_quantity = -3` (`ERROR 3819`) | `evidence/constraint_rejections.png` |
| Running app reads real rows that match MySQL | Compared `SELECT` output from `webdev2_week8.products` against the browser product table and DevTools `GET /api/products` | `evidence/mysql_matching_rows.png`, `evidence/app_read_ui.png` |

---

## 5. Known Issues & Change Log

* **Known Issue:** My main development database (`webdev2_week8`) still contains extra tables from earlier weekly lab exercises (`courses`, `departments`, `employees`, `pet`, `students`). Running `schema.sql` in `infoman1_week13_test` isolates only the four capstone tables so anyone grading can test a clean rebuild.
* **Change Log:**
* `13/11/2026` — Extracted clean DDL into `schema.sql`, created deterministic `seed.sql` and `views.sql`, tested constraint rejections and live view updates in `infoman1_week13_test`, and verified matching app reads against `webdev2_week8`.