# INFOMAN1 Week 14 — F2 Reproducibility & Verification Checkpoint

**Name:** OBIEFULE DECLAN  
**Student ID:** 2510223  
**Date:** 14/11/2026  

---

## 1. Repository & Database Locations

- **INFOMAN1 Submission Folder:** `https://github.com/sochimaobiefule-ship-it/infoman1/tree/main/week14`
- **Foundation Scripts (Week 13 F1):** `../week13/schema.sql`, `../week13/seed.sql`, `../week13/views.sql` (no destructive schema changes required in Week 14; InnoDB tables and constraints carry forward directly).
- **Application Repository & Branch:** `https://github.com/sochimaobiefule-ship-it/webdev2` (`week14` branch — Spring Boot backend + browser UI).
- **Databases Used:**
  * `infoman1_week13_test` — Disposable test database for `transactions.sql` (SQL commit, controlled rollback, and savepoint verification).
  * `webdev2_week8` — Local development database connected to Spring Boot via `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD` environment variables.

---

## 2. CRUD & Delete Policy Summary (Two Principal Resources)

1. **Products (`/api/products`):**
   * **Create / Read / Filter / Update / Delete:** Persists directly to `webdev2_week8.products` and survives full browser reloads.
   * **Validation & Affected-Row Handling:** Locates records by primary key (`id`), checks `rowCount` / entity existence before mutating, rejects duplicate SKUs (`SKU_EXISTS`), and enforces positive price and non-negative stock.
   * **Delete Policy:** Products referenced in `order_items` cannot be deleted (protected by `fk_items_product ON DELETE RESTRICT` and service error handling) so historical order lines are never orphaned.
2. **Users (`/api/users`):**
   * **Create / Read / Update / Delete:** Persists directly to `webdev2_week8.users` with unique username/email checks and primary-key lookup before update or delete.
   * **Delete Policy:** Users with existing rows in `customer_orders` are blocked from deletion (`fk_orders_user ON DELETE RESTRICT`).

---

## 3. Requirement & Evidence Map

| Requirement / Check | How I Verified It | Evidence File(s) |
| --- | --- | --- |
| SQL savepoint partial rollback vs. full rollback | Executed `transactions.sql` Scenario C in `infoman1_week13_test`: deducted Laptop (`10 -> 9`), set `SAVEPOINT after_laptop_deduction`, deducted Mouse (`25 -> 22`), ran `ROLLBACK TO SAVEPOINT` (Mouse `25`, Laptop `9`), then `ROLLBACK` (Laptop `10`, Mouse `25`) | `evidence/mysql_savepoint_1.png`, `evidence/mysql_savepoint_2.png` |
| Persisted CRUD + invalid input handling for `Products` and `Users` | Created `Product #11 (Charging Cable)` and `User #5 (joshua_ochacho)`, tested duplicate SKU `LAP-001` rejection (`SKU_EXISTS`), cleaned up test rows, and verified matching rows in MySQL | `evidence/app_crud_create_product.png`, `evidence/app_crud_create_user.png`, `evidence/app_crud_existing_sku_error.png`, `evidence/mysql_crud_verification.png` |
| Successful multi-record atomic workflow (`COMMIT`) | Submitted `Order #3` (`justice_singh`, `Laptop` qty `1`) without failure simulation; verified `Laptop` stock dropped `8 -> 7` and matching rows persisted in `customer_orders` and `order_items` | `evidence/app_order_commit_ui.png`, `evidence/mysql_order_commit.png` |
| Post-write failure rollback (`ROLLBACK`) | Checked *"Simulate post-write failure after stock deduction"* and submitted an order; verified server returned error (`An unexpected server error occurred`), `Laptop` stock remained `7`, and no orphan order/item rows were saved | `evidence/app_order_rollback_ui.png`, `evidence/mysql_order_rollback.png` |