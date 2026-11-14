# INFOMAN1 Week 14 — F2: CRUD Integrity, ACID Transactions, and Concurrency Control

**Name:** OBIEFULE DECLAN  
**Student ID:** 2510223  
**Date:** 14/11/2026  

---

## 1. Business Invariant & Transaction Boundary

In my Inventory & Order Management capstone (`webdev2`), placing a customer order is not a single table write—it updates product inventory and creates matching order records across three InnoDB tables (`products`, `customer_orders`, and `order_items`).

* **Core Business Invariant:** `products.stock_quantity` must never drop below `0`, and every inventory deduction must have a matching `customer_orders` header and `order_items` line item (and vice versa).
* **Transaction Boundary:**
  * **Start:** Entering the public `@Transactional` order placement method in the Spring Boot service layer (`POST /api/orders`).
  * **Internal Steps:** Lock and read the target `products` row, verify `stock_quantity >= requestedQuantity`, deduct stock, insert the `customer_orders` row, and insert the `order_items` row.
  * **Success Commit Point:** When all repository saves complete without throwing a runtime exception, Spring commits the transaction to MySQL at method exit.
  * **Failure Rollback Point:** If stock is insufficient, a constraint fails, or a post-write runtime exception occurs after stock is deducted, Spring rolls back the entire transaction so neither the stock deduction nor partial order rows persist.

---

## 2. ACID Properties in MySQL (InnoDB) & Spring Boot

* **Atomicity (All-or-Nothing):** By wrapping stock deduction and order creation inside one `@Transactional` boundary, both changes commit together (`Order #3` reduced `Laptop` stock from `8` to `7` and saved `customer_orders` + `order_items` ID `3`) or both undo together when the simulated post-write error fires (`Laptop` stayed at `7` and no `Order #4` was saved).
* **Consistency (Rules Stay Satisfied):** Application validation checks input early, while MySQL InnoDB enforces `UNIQUE` (`uq_products_sku`, `uq_users_username`, `uq_users_email`), `FOREIGN KEY` (`fk_orders_user`, `fk_items_order`, `fk_items_product`), and `CHECK` (`stock_quantity >= 0`, `quantity > 0`) constraints as the final guardrail so invalid states never persist.
* **Isolation (Safe Concurrent Access):** Inside an active transaction, row-level locking prevents another concurrent checkout from reading stale stock values mid-transaction and overselling the last unit.
* **Durability (Survives Restarts):** Once `COMMIT` succeeds on InnoDB tables, the updated `stock_quantity` and new order rows are flushed to disk and remain intact across application and MySQL server restarts.

---

## 3. Full Rollback vs. Savepoint Rollback

A `SAVEPOINT` creates a named bookmark inside an active transaction without committing anything or ending the transaction:

* **`ROLLBACK TO SAVEPOINT <name>` (Partial Rollback):** Undoes only the SQL mutations executed *after* that savepoint while keeping earlier uncommitted work inside the same transaction alive. In my SQL test (`transactions.sql`), deducting 1 `Laptop` (`10 -> 9`), setting `SAVEPOINT after_laptop_deduction`, deducting 3 `Wireless Gaming Mouse` units (`25 -> 22`), and running `ROLLBACK TO SAVEPOINT after_laptop_deduction` restored `Mouse` back to `25` while keeping `Laptop` at `9`.
* **`ROLLBACK` (Full Rollback):** Cancels the entire transaction back to `START TRANSACTION`, undoing even the mutations made *before* the savepoint (`Laptop` returned from `9` to `10`).

---

## 4. Concurrency Risk, Application Traps, and Safe CRUD Rules

* **Lost-Update / Overselling Race Condition:** If two customers buy the last `Laptop` (`stock_quantity = 1`) at the same time using a plain `SELECT` followed by `stock - 1`, both threads can read `1`, both pass the check, and stock becomes `-1` (or fails late). My implementation avoids this by using pessimistic row locking (`FOR UPDATE` / lock on the product record inside `@Transactional`) and conditional/checked updates inside a single short database transaction—never holding locks while waiting for browser form input.
* **Avoiding Spring `@Transactional` Proxy Traps:**
  * The `@Transactional` method is a `public` service method called externally from the REST controller (`OrderController -> OrderService`), ensuring execution passes through Spring's AOP proxy rather than bypassing it via internal `this.method()` self-invocation.
  * Unchecked `RuntimeException` errors are allowed to propagate out of the service method (not swallowed in an empty `try/catch`) so Spring reliably marks the transaction for rollback before the controller maps the error response.
* **Deliberate CRUD & Deletion Rules:** Both `Products` and `Users` use parameterized JPA/ORM queries, verify target records by primary key before updating or deleting, block duplicate unique values (`SKU_EXISTS`), and block deleting products or users referenced by existing orders rather than disabling foreign key checks.