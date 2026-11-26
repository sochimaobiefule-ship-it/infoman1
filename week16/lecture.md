# INFOMAN1 Week 16 — Engineering & Database Integration Reflection (`lecture.md`)

**Student:** OBIEFULE DECLAN
**Student ID:** 2510223  
**Date:** 26/11/2026 
**Databases:** `webdev2_week16_test` (test) & `webdev2_week8` (runtime) on MySQL port `3307`

---

## 1. Three Meaningful Test Choices & Coverage Reasoning

Rather than only testing happy-path CRUD through the browser, three database-backed test choices were prioritized because they catch failures that UI checks alone can hide:

1. **Real MySQL Constraint Enforcement (`TC-05`, `TC-07`, `TC-08`):**
   * *Why it matters:* An in-memory substitute or frontend validation rule does not prove that MySQL's schema constraints actually reject bad writes. By inserting a duplicate SKU (`'TEST-LAP-01'`), inserting an order with an invalid `user_id = 9999`, and attempting to delete a referenced parent product (`id = 101`) directly on `webdev2_week16_test`, we confirmed MySQL enforces `ERROR 1062` (`UNIQUE`), `ERROR 1452` (`FOREIGN KEY` insert), and `ERROR 1451` (`FOREIGN KEY` parent delete) at the storage layer.
2. **Post-Write Transaction Rollback (`TC-11`, `TC-12`):**
   * *Why it matters:* Testing only a valid order commit (`TC-11`) proves writes succeed, not that failures clean up partial work. In `TC-12` (`verification.sql` Section 3B and `Week16MySqlTransactionTests`), `Product 103` (`stock_quantity = 13`) was decremented by `3` *before* triggering a foreign-key failure (`user_id = 9999`) and calling `ROLLBACK`. Checking post-state (`stock_quantity = 13` and `rolled_back_order_count = 0`) proved MySQL did not leave phantom stock reductions behind.
3. **Database Privilege Separation (`TC-13`, `TC-14`):**
   * *Why it matters:* Application role checks (`MANAGER` vs. `READER` in Spring Security) protect HTTP routes, but database accounts enforce defense-in-depth if credentials leak or a raw SQL connection is opened. Verifying `SHOW GRANTS` for `'webdev2_app'@'localhost'` (DML-only on `webdev2_week8.*`) and `'webdev2_report'@'localhost'` (`SELECT`-only on `product_sales_summary`) confirmed that runtime code cannot run DDL (`CREATE`/`ALTER`/`DROP`) and reporting accounts cannot read `users.password_hash` or modify base tables.

---

## 2. Independent Report Output & Join Cardinality Analysis

To verify `product_sales_summary` (`week15/access_control.sql` and `week16/verification.sql`), a controlled 3-product, 2-order baseline dataset was seeded into `webdev2_week16_test` and calculated by hand before running `SELECT * FROM product_sales_summary ORDER BY product_id;`:

* **Hand-Calculated Expected Totals:**
  * **Product `101` (`Test Laptop`, `$1000.00`):** Sold once in order `501` (`qty = 2`) → `total_units_sold = 2`, `total_revenue = 2000.00`.
  * **Product `102` (`Test Mouse`, `$50.00`):** Sold in order `501` (`qty = 3`) and order `502` (`qty = 1`) → `total_units_sold = 4`, `total_revenue = 200.00`.
  * **Product `103` (`Unsold USB Hub`, `$25.00`):** Zero matching rows in `order_items` → preserved by `LEFT JOIN` with `COALESCE(SUM(...), 0)` → `total_units_sold = 0`, `total_revenue = 0.00`.

* **Actual MySQL Output:**
  ```text
  +------------+-------------+----------------+-------------+------------+----------------+------------------+---------------+
  | product_id | sku         | product_name   | category    | unit_price | stock_quantity | total_units_sold | total_revenue |
  +------------+-------------+----------------+-------------+------------+----------------+------------------+---------------+
  |        101 | TEST-LAP-01 | Test Laptop    | Electronics |    1000.00 |             10 |                2 |          2000 |
  |        102 | TEST-MSE-02 | Test Mouse     | Electronics |      50.00 |             20 |                4 |           200 |
  |        103 | TEST-USB-03 | Unsold USB Hub | Accessories |      25.00 |             15 |                0 |             0 |
  +------------+-------------+----------------+-------------+------------+----------------+------------------+---------------+
  ```

* **Join Cardinality & Empty-Result Reasoning:**
* Joining `products` directly to `order_items` (`1:N`) avoids multiplying parent rows across unrelated tables, while `GROUP BY p.id, p.sku, p.name, p.category, p.price, p.stock_quantity` collapses multiple line items per product into a single summary row.
* Using `LEFT JOIN` instead of `INNER JOIN` keeps unsold products (`Product 103`) visible with `0` units sold rather than silently hiding dead stock. If a filter on the child table (`order_items` or `customer_orders`) were placed in a `WHERE` clause instead of the `ON` clause, rows where `oi.product_id IS NULL` would fail the predicate and turn the outer join into an inner join.

---

## 3. Cross-Layer Diagnosis (`DEF-001`)

During UAT (`UAT-01`), signing in as `manager_demo` granted full write access to create/edit/delete forms, yet the Users table rendered a `READER` badge on `manager_demo` (`ID 6`).

* **Layer-by-Layer Trace:**
1. **Database (`webdev2_week8.users`):** Inspected `users` and confirmed `manager_demo` had `role = 'MANAGER'`.
2. **Security Layer (`Spring Security`):** Confirmed `CustomUserDetailsService` loaded `ROLE_MANAGER` from `users.role`, explaining why `POST`/`PUT`/`DELETE` requests succeeded.
3. **API / DTO Layer (`UserService.java` & `UserResponseDTO.java`):** Inspected `/api/users` serialization and found that `UserResponseDTO` only declared `id`, `username`, and `email`—`role` was never copied in `UserService.toDTO(User)`.
4. **Frontend (`app.js`):** Found `const roleText = u.role || "READER";`, which silently defaulted every user row to `"READER"` whenever `u.role` was `undefined`.


* **Fix & Regression Verification:**
* Fixed the issue at the responsible mapping layer (`UserResponseDTO.java` and `UserService.java`) rather than hardcoding UI workarounds.
* Re-ran the full Maven suite (`.\mvnw.cmd test` → **13/13 passed**, `0` failures) and re-verified both `manager_demo` (`MANAGER` badge) and `reader_demo` (`READER` badge, read-only UI) so the DTO change did not expose sensitive fields (`password_hash`) or break security rules.

---

## 4. `EXPLAIN` Query Plan & Index / Schema Evolution Decisions

### `EXPLAIN` Interpretation (`verification.sql` Section 4)

```text
-> Nested loop inner join  (cost=2.75 rows=1.5)
    -> Nested loop inner join  (cost=1.93 rows=4.5)
        -> Nested loop inner join  (cost=1.1 rows=3)
            -> Sort: co.order_date DESC  (cost=0.55 rows=3)
                -> Filter: ((co.`status` = 'CONFIRMED') and (co.user_id is not null))  (cost=0.55 rows=3)
                    -> Table scan on co  (cost=0.55 rows=3)
            -> Single-row index lookup on u using PRIMARY (id = co.user_id)  (cost=0.35 rows=1)
        -> Index lookup on oi using FKb2vrrqy10nnyqhb5ergl5498r (order_id = co.id)  (cost=0.525 rows=1.5)
    -> Filter: (p.category = 'Electronics')  (cost=0.272 rows=0.333)
        -> Single-row index lookup on p using PRIMARY (id = oi.product_id)  (cost=0.272 rows=1)
```

* **What the plan shows:**
* The inner joins across `users`, `order_items`, and `products` already use indexes (`PRIMARY` on `u.id` and `p.id`, and foreign-key index `FKb2vrrqy10nnyqhb5ergl5498r` on `oi.order_id`).
* `customer_orders` (`co`) performs a full table scan (`Table scan on co`, `rows=3`) followed by an explicit `Sort: co.order_date DESC` because there is no index on `(status, order_date)`. On a 3-row test table, scanning a single data page is cheap and expected.


* **Index Candidate & Tradeoff:**
* As `customer_orders` grows into thousands of rows, adding a composite index `CREATE INDEX idx_orders_status_date ON customer_orders (status, order_date);` would allow MySQL to filter `status = 'CONFIRMED'` and read rows already ordered by `order_date DESC` without a filesort.
* *Tradeoff:* Every secondary index adds disk storage and slightly slows `INSERT` and `UPDATE` operations on `customer_orders` because InnoDB must update both the clustered primary key and the secondary B-tree. Therefore, the index is documented as a scale-up candidate rather than over-indexing a tiny table prematurely.


* **Schema Evolution Ownership:**
* All schema changes remain owned by versioned SQL scripts (`week13/schema.sql`, `week13/views.sql`, `week15/access_control.sql`) and JPA entity mappings rather than ad-hoc edits on the live `webdev2_week8` database, keeping fresh setup (`webdev2_week16_test`) and runtime (`webdev2_week8`) aligned.