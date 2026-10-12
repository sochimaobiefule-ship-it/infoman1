# INFOMAN1 — Week 9 Lab Answers

Name: OBIEFULE DECLAN
Student ID: 2510223
GitHub repo: https://github.com/sochimaobiefule-ship-it/infoman1
Date submitted: 12/10/2026

## Task 1 — INNER JOIN Basics

**Approach / explanation:**
I wrote a SELECT query to join `students` and `orders` using `INNER JOIN`. I gave `students` the alias `s` and `orders` the alias `o` so the query is easier to read. For the ON condition, I matched the primary key `s.student_id` to the foreign key `o.student_id`. Lastly, I added `ORDER BY o.order_id` at the end to sort the results.

**Code / query used (if applicable):**
```sql
mysql> SELECT
    ->     s.student_name,
    ->     s.program,
    ->     o.order_id,
    ->     o.order_date
    -> FROM students s
    -> INNER JOIN orders o
    ->     ON s.student_id = o.student_id
    -> ORDER BY o.order_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> SELECT
    ->     s.student_name,
    ->     s.program,
    ->     o.order_id,
    ->     o.order_date
    -> FROM students s
    -> INNER JOIN orders o
    ->     ON s.student_id = o.student_id
    -> ORDER BY o.order_id;
+--------------+---------+----------+------------+
| student_name | program | order_id | order_date |
+--------------+---------+----------+------------+
| Ana Cruz     | BSIT    |      101 | 2026-08-10 |
| Ana Cruz     | BSIT    |      102 | 2026-08-15 |
| Dan Reyes    | BSIT    |      103 | 2026-08-16 |
+--------------+---------+----------+------------+
3 rows in set (0.183 sec)

**Reflection question:**
_[Why does an INNER JOIN hide students who never ordered, and when is that exactly the behavior a sales report wants?]_
An INNER JOIN only shows rows where the keys match in both tables. Ben Lim and Cara Yu don't have any entries in the orders table, so MySQL automatically leaves them out. This is useful for a sales report because you usually only want to see actual transactions and active buyers, not extra rows with empty order data for people who haven't bought anything.

## Task 2 — Finding Missing Relationships

**Approach / explanation:**
For query a, I used a `LEFT JOIN` starting from `students` so that every student stays in the list, even if they didn't place an order. For query b, I added `WHERE o.order_id IS NULL` to filter the left join output so it only shows the students who have no orders linked to them.

**Code / query used (if applicable):**
```sql
query a
mysql> SELECT
    ->     s.student_id,
    ->     s.student_name,
    ->     s.program,
    ->     o.order_id,
    ->     o.order_date
    -> FROM students s
    -> LEFT JOIN orders o
    ->     ON s.student_id = o.student_id
    -> ORDER BY s.student_id;

query b
mysql> SELECT
    ->     s.student_id,
    ->     s.student_name,
    ->     s.program
    -> FROM students s
    -> LEFT JOIN orders o
    ->     ON s.student_id = o.student_id
    -> WHERE o.order_id IS NULL;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
query a
mysql> SELECT
    ->     s.student_id,
    ->     s.student_name,
    ->     s.program,
    ->     o.order_id,
    ->     o.order_date
    -> FROM students s
    -> LEFT JOIN orders o
    ->     ON s.student_id = o.student_id
    -> ORDER BY s.student_id;
+------------+--------------+---------+----------+------------+
| student_id | student_name | program | order_id | order_date |
+------------+--------------+---------+----------+------------+
|          1 | Ana Cruz     | BSIT    |      102 | 2026-08-15 |
|          1 | Ana Cruz     | BSIT    |      101 | 2026-08-10 |
|          2 | Ben Lim      | BSCS    |     NULL | NULL       |
|          3 | Cara Yu      | BSIS    |     NULL | NULL       |
|          4 | Dan Reyes    | BSIT    |      103 | 2026-08-16 |
+------------+--------------+---------+----------+------------+
5 rows in set (0.324 sec)

query b
mysql> SELECT
    ->     s.student_id,
    ->     s.student_name,
    ->     s.program
    -> FROM students s
    -> LEFT JOIN orders o
    ->     ON s.student_id = o.student_id
    -> WHERE o.order_id IS NULL;
+------------+--------------+---------+
| student_id | student_name | program |
+------------+--------------+---------+
|          2 | Ben Lim      | BSCS    |
|          3 | Cara Yu      | BSIS    |
+------------+--------------+---------+
2 rows in set (0.044 sec)

**Reflection question:**
_[What does NULL mean in the unmatched columns of a LEFT JOIN, and why must you test it with IS NULL instead of equals?]_
NULL in a LEFT JOIN means there was no matching record found in the table on the right. You have to use IS NULL instead of = NULL because in SQL, NULL represents unknown data, so comparing anything with = to NULL results in UNKNOWN instead of TRUE.

## Task 3 — Four-Table Canteen Report

**Approach / explanation:**
I connected all four tables by chaining `INNER JOIN` statements step by step: `students` to `orders` using `student_id`, `orders` to `order_items` using `order_id`, and `order_items` to `menu_items` using `menu_id`. I made sure to qualify every column with table aliases (like `s.student_name` and `o.order_id`) to avoid ambiguity errors. I also calculated `line_total` by multiplying `oi.quantity * m.price` and sorted the results by `order_id` and `item_name`.

**Code / query used (if applicable):**
```sql
mysql> SELECT
    ->     s.student_name,
    ->     s.program,
    ->     o.order_id,
    ->     m.item_name,
    ->     oi.quantity,
    ->     m.price,
    ->     (oi.quantity * m.price) AS line_total
    -> FROM students s
    -> INNER JOIN orders o
    ->     ON s.student_id = o.student_id
    -> INNER JOIN order_items oi
    ->     ON o.order_id = oi.order_id
    -> INNER JOIN menu_items m
    ->     ON oi.menu_id = m.menu_id
    -> ORDER BY o.order_id, m.item_name;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> SELECT
    ->     s.student_name,
    ->     s.program,
    ->     o.order_id,
    ->     m.item_name,
    ->     oi.quantity,
    ->     m.price,
    ->     (oi.quantity * m.price) AS line_total
    -> FROM students s
    -> INNER JOIN orders o
    ->     ON s.student_id = o.student_id
    -> INNER JOIN order_items oi
    ->     ON o.order_id = oi.order_id
    -> INNER JOIN menu_items m
    ->     ON oi.menu_id = m.menu_id
    -> ORDER BY o.order_id, m.item_name;
+--------------+---------+----------+--------------+----------+-------+------------+
| student_name | program | order_id | item_name    | quantity | price | line_total |
+--------------+---------+----------+--------------+----------+-------+------------+
| Ana Cruz     | BSIT    |      101 | Iced Tea     |        1 | 30.00 |      30.00 |
| Ana Cruz     | BSIT    |      101 | Siomai Rice  |        2 | 65.00 |     130.00 |
| Ana Cruz     | BSIT    |      102 | Burger Steak |        1 | 89.00 |      89.00 |
| Dan Reyes    | BSIT    |      103 | Siomai Rice  |        1 | 65.00 |      65.00 |
+--------------+---------+----------+--------------+----------+-------+------------+
4 rows in set (0.150 sec)

**Reflection question:**
_[Why does each JOIN in a multi-table chain need its own ON condition, and what goes wrong when two joins share one?]_
Each JOIN needs its own ON condition because it defines the specific link between two tables. If you omit an ON clause or reuse the wrong one, SQL can't match the rows properly. This causes a cross join (Cartesian product), which multiplies every row in one table by every row in the other, duplicating data and ruining your total amounts.

## Task 4 — Aliases, Filters, and the Silent Inner Join

**Approach / explanation:**
I wrote two queries filtering for August 2026 orders sorted newest first. The first version uses standard `INNER JOIN`s across all tables. The second version starts with `LEFT JOIN`s from `students` down to `menu_items`, but includes `WHERE o.order_date >= '2026-08-01'`.

**Code / query used (if applicable):**
```sql
first version
mysql> SELECT
    ->     s.student_name AS buyer,
    ->     m.item_name AS item,
    ->     (oi.quantity * m.price) AS line_total,
    ->     o.order_date
    -> FROM students s
    -> INNER JOIN orders o ON s.student_id = o.student_id
    -> INNER JOIN order_items oi ON o.order_id = oi.order_id
    -> INNER JOIN menu_items m ON oi.menu_id = m.menu_id
    -> WHERE o.order_date >= '2026-08-01'
    -> ORDER BY o.order_date DESC;

second version
mysql> SELECT
    ->     s.student_name AS buyer,
    ->     m.item_name AS item,
    ->     (oi.quantity * m.price) AS line_total,
    ->     o.order_date
    -> FROM students s
    -> INNER JOIN orders o ON s.student_id = o.student_id
    -> INNER JOIN order_items oi ON o.order_id = oi.order_id
    -> INNER JOIN menu_items m ON oi.menu_id = m.menu_id
    -> WHERE o.order_date >= '2026-08-01'
    -> ORDER BY o.order_date DESC;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
first version
mysql> SELECT
    ->     s.student_name AS buyer,
    ->     m.item_name AS item,
    ->     (oi.quantity * m.price) AS line_total,
    ->     o.order_date
    -> FROM students s
    -> INNER JOIN orders o ON s.student_id = o.student_id
    -> INNER JOIN order_items oi ON o.order_id = oi.order_id
    -> INNER JOIN menu_items m ON oi.menu_id = m.menu_id
    -> WHERE o.order_date >= '2026-08-01'
    -> ORDER BY o.order_date DESC;
+-----------+--------------+------------+------------+
| buyer     | item         | line_total | order_date |
+-----------+--------------+------------+------------+
| Dan Reyes | Siomai Rice  |      65.00 | 2026-08-16 |
| Ana Cruz  | Burger Steak |      89.00 | 2026-08-15 |
| Ana Cruz  | Siomai Rice  |     130.00 | 2026-08-10 |
| Ana Cruz  | Iced Tea     |      30.00 | 2026-08-10 |
+-----------+--------------+------------+------------+
4 rows in set (0.143 sec)

second version
mysql> SELECT
    ->     s.student_name AS buyer,
    ->     m.item_name AS item,
    ->     (oi.quantity * m.price) AS line_total,
    ->     o.order_date
    -> FROM students s
    -> LEFT JOIN orders o ON s.student_id = o.student_id
    -> LEFT JOIN order_items oi ON o.order_id = oi.order_id
    -> LEFT JOIN menu_items m ON oi.menu_id = m.menu_id
    -> WHERE o.order_date >= '2026-08-01'
    -> ORDER BY o.order_date DESC;
+-----------+--------------+------------+------------+
| buyer     | item         | line_total | order_date |
+-----------+--------------+------------+------------+
| Dan Reyes | Siomai Rice  |      65.00 | 2026-08-16 |
| Ana Cruz  | Burger Steak |      89.00 | 2026-08-15 |
| Ana Cruz  | Siomai Rice  |     130.00 | 2026-08-10 |
| Ana Cruz  | Iced Tea     |      30.00 | 2026-08-10 |
+-----------+--------------+------------+------------+
4 rows in set (0.090 sec)

**Reflection question:**
_[Why does adding WHERE on the right-side table remove the NULL rows a LEFT JOIN just preserved, and where should that rule live instead?]_
Adding a WHERE condition on a right-table column gets rid of NULL rows because NULL fails standard comparisons like >=. If you want to keep those NULL rows from a LEFT JOIN, the condition needs to go inside the ON clause instead of WHERE.  

## Task 5 — Reflection

**Approach / explanation:**
_[Write 2–4 sentences describing how you solved this task.]_

**Code / query used (if applicable):**
```sql
-- paste your SQL (or Java/JDBC, for Week 13+) here
```

**Evidence (screenshot filename, output, or file reference in this folder):**
I would choose an INNER JOIN for financial sales reports like in Task 1, where non-buyers like Ben Lim and Cara Yu would just clutter transaction totals. Conversely, I would use a LEFT JOIN for student engagement audits to preserve NULL rows and easily spot inactive students who haven't ordered yet.

In Task 3, I initially got ERROR 1052: Column 'order_id' in field list is ambiguous. The symptom was MySQL rejecting my query because both orders and order_items share that exact column name. I fixed it by qualifying the column with the table alias as o.order_id, giving MySQL explicit instructions on which table to reference.

**Reflection question:**
_[Which join would you choose for an "all students including non-buyers" roster versus a "completed sales only" report, and what single symptom would tell you that you picked the wrong one?]_
For an "all students including non-buyers" roster, I would use a LEFT JOIN to keep students without orders visible as NULL. For a "completed sales only" report, I would pick an INNER JOIN to show active purchases only. The main symptom that shows I picked the wrong join is either missing inactive students who should be listed (used INNER by mistake) or having unwanted NULL rows cluttering total sales numbers (used LEFT by mistake).

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [ ] All files placed inside `week9/`
- [ ] This file completed and renamed `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)
