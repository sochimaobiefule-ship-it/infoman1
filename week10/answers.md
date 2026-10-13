# INFOMAN1 — Week 10 Lab Answers

Name: OBIEFULE DECLAN
Student ID: 2510223
GitHub repo: https://github.com/sochimaobiefule-ship-it/infoman1
Date submitted: 13/10/2026

## Task 1 — INNER JOIN Basics

**Approach / explanation:**
I inserted the Scientific Calculator and Compass using explicit column lists in the `INSERT INTO` statements. Listing columns explicitly ensures that values match their intended targets regardless of schema column order. After running each `INSERT`, I ran a `SELECT` statement targeting the newly created SKU to confirm the record was added properly._

**Code / query used (if applicable):**
```sql
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');

mysql> SELECT * FROM products WHERE sku = 'CALC-SCI-001';

mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');

mysql> SELECT * FROM products WHERE sku = 'CMP-001';    

mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Highlighter', 'HL-001', 'eighty pesos', 100, 'Active');
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Scientific Calculator', 'CALC-SCI-001', 850.00, 20, 'Active');

mysql> SELECT * FROM products WHERE sku = 'CALC-SCI-001';
+------------+-----------------------+--------------+--------+----------------+--------+
| product_id | product_name          | sku          | price  | stock_quantity | status |
+------------+-----------------------+--------------+--------+----------------+--------+
|          6 | Scientific Calculator | CALC-SCI-001 | 850.00 |             20 | Active |
+------------+-----------------------+--------------+--------+----------------+--------+

mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Compass', 'CMP-001', 120.00, 50, 'Active');

mysql> SELECT * FROM products WHERE sku = 'CMP-001';
+------------+--------------+---------+--------+----------------+--------+
| product_id | product_name | sku     | price  | stock_quantity | status |
+------------+--------------+---------+--------+----------------+--------+
|          7 | Compass      | CMP-001 | 120.00 |             50 | Active |
+------------+--------------+---------+--------+----------------+--------+

mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Highlighter', 'HL-001', 'eighty pesos', 100, 'Active');
ERROR 1366 (HY000): Incorrect decimal value: 'eighty pesos' for column 'price' at row 1

**Reflection question:**
_[Why it fails?]_
Incorrect decimal value: 'eighty pesos' for column 'price' at row 1 because the price column is defined as DECIMAL(10,2). Passing non-numeric text fails MySQL's data type validation.

## Task 2 — Finding Missing Relationships

**Approach / explanation:**
I previewed each row first using `SELECT ... WHERE product_id = X` to make sure I targeted the exact record. Then I ran the `UPDATE` or `DELETE` with the same condition and used a final `SELECT` to verify the change.

**Code / query used (if applicable):**
```sql
update
SELECT * FROM products WHERE product_id = 6;
UPDATE products SET price = 875.00 WHERE product_id = 6;
SELECT * FROM products WHERE product_id = 6;

delete
SELECT * FROM products WHERE product_id = 5;
DELETE FROM products WHERE product_id = 5;
SELECT * FROM products WHERE product_id = 5;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
update
mysql> SELECT * FROM products WHERE product_id = 6;
+------------+-----------------------+--------------+--------+----------------+--------+
| product_id | product_name          | sku          | price  | stock_quantity | status |
+------------+-----------------------+--------------+--------+----------------+--------+
|          6 | Scientific Calculator | CALC-SCI-001 | 850.00 |             20 | Active |
+------------+-----------------------+--------------+--------+----------------+--------+
1 row in set (0.132 sec)

mysql> UPDATE products SET price = 875.00 WHERE product_id = 6;
Query OK, 1 row affected (0.076 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM products WHERE product_id = 6;
+------------+-----------------------+--------------+--------+----------------+--------+
| product_id | product_name          | sku          | price  | stock_quantity | status |
+------------+-----------------------+--------------+--------+----------------+--------+
|          6 | Scientific Calculator | CALC-SCI-001 | 875.00 |             20 | Active |
+------------+-----------------------+--------------+--------+----------------+--------+
1 row in set (0.007 sec)

delete
mysql> SELECT * FROM products WHERE product_id = 5;
+------------+--------------+--------+-------+----------------+--------+
| product_id | product_name | sku    | price | stock_quantity | status |
+------------+--------------+--------+-------+----------------+--------+
|          5 | Eraser       | ER-001 | 10.00 |            200 | Active |
+------------+--------------+--------+-------+----------------+--------+
1 row in set (0.011 sec)

mysql> DELETE FROM products WHERE product_id = 5;
Query OK, 1 row affected (0.155 sec)

mysql> SELECT * FROM products WHERE product_id = 5;
Empty set (0.079 sec)

**Reflection question:**
_[Briefly explain what each statement would have done without its WHERE clause.]_
Without a WHERE clause, UPDATE products SET price = 875.00; would update every product's price in the database to 875.00. Similarly, running DELETE FROM products; without a WHERE clause would permanently wipe out all rows in the table.

## Task 3 — Four-Table Canteen Report

**Approach / explanation:**
I wrote a `LEFT JOIN` on the `employees` table joined with itself using aliases `e` for employee and `m` for manager. For the second part, I used a `CROSS JOIN` between `colors` and `sizes` to generate every possible color-size pair and checked the total count using `COUNT(*)`.

**Code / query used (if applicable):**
```sql
self join
mysql> SELECT
    -> e.employee_id,
    -> e.employee_name AS employee,
    -> m.employee_name AS manager
    -> FROM employees AS e
    -> LEFT JOIN employees AS m ON e.manager_id = m.employee_id;

cross join
mysql> SELECT
    -> c. color_name,
    -> s. size_name
    -> FROM colors AS c
    -> CROSS JOIN sizes AS s;

mysql> SELECT COUNT(*) AS total_combinations
    -> FROM colors CROSS JOIN sizes;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
self join
mysql> SELECT
    -> e.employee_id,
    -> e.employee_name AS employee,
    -> m.employee_name AS manager
    -> FROM employees AS e
    -> LEFT JOIN employees AS m ON e.manager_id = m.employee_id;
+-------------+-------------+-----------+
| employee_id | employee    | manager   |
+-------------+-------------+-----------+
|           1 | Lea Ramos   | NULL      |
|           2 | Carlo Reyes | Lea Ramos |
|           3 | Dana Cruz   | Lea Ramos |
+-------------+-------------+-----------+
3 rows in set (0.065 sec)

cross join
mysql> SELECT
    -> c. color_name,
    -> s. size_name
    -> FROM colors AS c
    -> CROSS JOIN sizes AS s;
+------------+-----------+
| color_name | size_name |
+------------+-----------+
| Red        | L         |
| Green      | L         |
| Blue       | L         |
| Red        | M         |
| Green      | M         |
| Blue       | M         |
| Red        | S         |
| Green      | S         |
| Blue       | S         |
+------------+-----------+
9 rows in set (0.026 sec)

mysql> SELECT COUNT(*) AS total_combinations
    -> FROM colors CROSS JOIN sizes;
+--------------------+
| total_combinations |
+--------------------+
|                  9 |
+--------------------+
1 row in set (0.313 sec)

**Reflection question:**
_[Why LEFT JOIN keeps Lea?]_
Lea Ramos has a manager_id of NULL. An INNER JOIN would drop her row completely, but LEFT JOIN keeps her in the results and sets her manager name to NULL.

_[One sentence stating a genuine business use (e.g. generating notebook variants) and why this must never be an accidental missing-ON.]_
A CROSS JOIN is useful for generating item variations, such as creating notebook options for every color and size pair. It must never happen accidentally due to a missing ON condition because combining large tables creates massive, useless data products that slow down the database.

## Task 4 — Aliases, Filters, and the Silent Inner Join

**Approach / explanation:**
I evolved the `products` table schema using `ALTER TABLE` statements to add a new `contact_number` column and enforce data integrity rules. I modified `product_name` to be `NOT NULL`, added a `UNIQUE` constraint on `sku`, and added a `CHECK` constraint ensuring `price > 0`. Then I tested each constraint with a passing insert and invalid writes to confirm enforcement.

**Code / query used (if applicable):**
```sql
schema evolution
mysql> ALTER TABLE products ADD COLUMN contact_number VARCHAR(20);

mysql> ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;

mysql> ALTER TABLE products ADD CONSTRAINT unique_sku UNIQUE (sku);

mysql> ALTER TABLE products ADD CONSTRAINT check_price_positive CHECK (price > 0);

passing write
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Stapler', 'STP-001', 150.00, 15, 'Active');

rejected writes
a. product_name NOT NULL
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES (NULL, 'STP-002', 150.00, 15, 'Active');

b. sku UNIQUE
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Mini Stapler', 'STP-001', 95.00, 10, 'Active');

c. CHECK (price > 0)
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Free Coupon', 'CPN-001', -10.00, 100, 'Active');
```

**Evidence (screenshot filename, output, or file reference in this folder):**
schema evoultion
mysql> ALTER TABLE products ADD COLUMN contact_number VARCHAR(20);
Query OK, 0 rows affected (0.738 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE products MODIFY product_name VARCHAR(100) NOT NULL;
Query OK, 0 rows affected (1.037 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE products ADD CONSTRAINT unique_sku UNIQUE (sku);
Query OK, 0 rows affected (0.643 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE products ADD CONSTRAINT check_price_positive CHECK (price > 0);
Query OK, 6 rows affected (0.745 sec)
Records: 6  Duplicates: 0  Warnings: 0

passing write
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Stapler', 'STP-001', 150.00, 15, 'Active');
Query OK, 1 row affected (0.214 sec)

rejected writes
a. product_name NOT NULL
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES (NULL, 'STP-002', 150.00, 15, 'Active');
ERROR 1048 (23000): Column 'product_name' cannot be null

b. sku UNIQUE
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Mini Stapler', 'STP-001', 95.00, 10, 'Active');
ERROR 1062 (23000): Duplicate entry 'STP-001' for key 'products.unique_sku'

c. CHECK (price > 0)
mysql> INSERT INTO products (product_name, sku, price, stock_quantity, status)
    -> VALUES ('Free Coupon', 'CPN-001', -10.00, 100, 'Active');
ERROR 3819 (HY000): Check constraint 'check_price_positive' is violated.

**Reflection question:**
_[Note the MySQL syntax caveat and how you tested it.]_
MySQL 8.0.16+ actively enforces CHECK constraints at runtime, whereas older versions silently ignored them.

## Task 5 — Reflection

**Approach / explanation:**
_[Write 2–4 sentences describing how you solved this task.]_

**Code / query used (if applicable):**
```sql
-- paste your SQL (or Java/JDBC, for Week 13+) here
```

**Evidence (screenshot filename, output, or file reference in this folder):**
For a campus bookstore, database-level constraints are essential for enforcing fundamental business rules such as preventing duplicate product SKUs (`unique_sku`) or invalid negative pricing (`check_price_positive` from Task 4). The database acts as the ultimate line of defense, keeping data reliable even if the user interface fails or if records are inserted directly through raw SQL. On the other hand, application-level checks excel at handling user experience tasks, like validating telephone numbers before submitting a web form or showing friendly stock warning messages to customers.

While working on Task 3, I initially made the mistake of writing a self-join without using distinct table aliases (`FROM employees JOIN employees ON manager_id = employee_id`). MySQL threw an immediate syntax error about an ambiguous table reference (`Not unique table/alias`). I resolved this issue by adding clear aliases (`employees AS e` for employees and `employees AS m` for managers) to clearly define which instance represented the worker and which represented the manager. This error highlighted why aliasing is mandatory whenever a table is joined back unto itself.

**Reflection question:**
_[Which join would you choose for an "all students including non-buyers" roster versus a "completed sales only" report, and what single symptom would tell you that you picked the wrong one?]_

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [ ] All files placed inside `week9/`
- [ ] This file completed and renamed `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)