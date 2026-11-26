# INFOMAN1 Week 16 — Defect Log & Tested Risks (`defects.md`)

**Date:** 26/11/2026  
**Databases:** `webdev2_week8` (runtime) & `webdev2_week16_test` (test) on MySQL port `3307`  
**Summary:** 2 resolved issues (`DEF-001`, `DEF-002`) and 3 verified database integrity/security risks (`RISK-01` – `RISK-03`), with full regression reruns.

---

## 1. Fixed Defects

### DEF-001: `manager_demo` Displays `READER` Badge Instead of `MANAGER` in Users Table

- **Severity:** Medium
- **Status:** Closed (Verified in Automated Suite `13/13` & Live UI)
- **Symptom:** After signing in as `manager_demo` (`MANAGER`), Section 3 (`Users — Create New User`) rendered a `READER` role badge on the `manager_demo` row (`ID 6`) instead of `MANAGER`.
- **Reproduction Steps:**
  1. Start Spring Boot with `APP_SEED_MANAGER_PASSWORD` set so `manager_demo` is seeded with `role = 'MANAGER'` in `webdev2_week8.users`.
  2. Sign in as `manager_demo` at `http://localhost:8080`.
  3. Scroll to the Users table and inspect the Role badge for `manager_demo`.
- **Expected vs. Actual Behavior:**
  - *Expected:* `manager_demo` displays `MANAGER` matching its database column (`users.role = 'MANAGER'`).
  - *Actual:* Every user row displayed `READER`.
- **Root Cause (Cross-Layer):**
  1. `webdev2_week8.users` stored `MANAGER` properly, and Spring Security authorities worked, so write endpoints were not blocked.
  2. However, `UserResponseDTO` only contained `id`, `username`, and `email` (no `role` field), and `UserService.toDTO(User)` never mapped `user.getRole()`.
  3. Because `/api/users` returned JSON without `role`, `app.js` hit its fallback (`const roleText = u.role || "READER";`) and displayed `READER` for all users.
- **Fix Applied (at Responsible Layer):**
  - **`UserResponseDTO.java`:** Added `private String role`, its getter/setter, and a 4-argument constructor `UserResponseDTO(Long id, String username, String email, String role)` while keeping the 3-argument constructor delegating to it.
  - **`UserService.java`:** Updated `toDTO(User)` to pass `user.getRole()` into `new UserResponseDTO(...)`.
- **Retest & Regression Evidence:**
  - Rebuilt and ran `.\mvnw.cmd test`: **13/13 tests passed (`BUILD SUCCESS`)**, confirming `Week16ApiSecurityTests` (`6/6`), `Week16ServiceUnitTests` (`4/4`), `Week16MySqlTransactionTests` (`2/2`), and `Webdev2ApplicationTests` (`1/1`) had zero regressions.
  - Restarted Spring Boot and reloaded `http://localhost:8080`: `manager_demo` (`ID 6`) now displays the `MANAGER` badge (`evidence/uat-01-manager-login-session.png`).

---

### DEF-002: `reader_demo` Login Failed (`Invalid username or password.`) During UAT-07

- **Severity:** Low (Environment / Startup Configuration)
- **Status:** Closed (Verified in `UAT-07`)
- **Symptom:** Attempting to sign in as `reader_demo` to test read-only access failed with `Invalid username or password.`, even though `manager_demo` logged in normally.
- **Reproduction Steps:**
  1. Open a new PowerShell session and set `DB_PASSWORD` and `APP_SEED_MANAGER_PASSWORD`, leaving `APP_SEED_READER_PASSWORD` unset.
  2. Start the server with `.\mvnw.cmd spring-boot:run`.
  3. Attempt to log in at `http://localhost:8080` using `reader_demo`.
- **Expected vs. Actual Behavior:**
  - *Expected:* `reader_demo` logs in with `READER` role and sees the read-only catalog/directory.
  - *Actual:* Login failed because the startup seeder skipped creating/updating `reader_demo` when `APP_SEED_READER_PASSWORD` was blank.
- **Root Cause:** PowerShell `$env:` variables are scoped to a single terminal session, and the startup account seeder only seeds `reader_demo` when `APP_SEED_READER_PASSWORD` is provided.
- **Fix Applied:** Set `$env:APP_SEED_READER_PASSWORD` alongside `$env:APP_SEED_MANAGER_PASSWORD` and `$env:DB_PASSWORD` before running `.\mvnw.cmd spring-boot:run`, and documented the session variable requirement in `checkpoint.md`.
- **Retest & Regression Evidence:**
  - Signed in as `reader_demo` (`READER`) at `http://localhost:8080`; verified read-only UI with create/update/delete forms hidden (`evidence/uat-07-reader-readonly.png`).
  - Re-verified `manager_demo` login (`UAT-01`) to confirm both seeded accounts work together.

---

## 2. Additional Tested High-Risk Scenarios (Honest Risk Log)

No additional application defects were uncovered during Week 16 testing. Rather than inventing defects, the following high-risk database scenarios were explicitly tested and verified:

- **RISK-01 — Partial Stock Deduction on Order Failure (`TC-12`):**
  - *Risk:* Decrementing `products.stock_quantity` before inserting `customer_orders` could leave phantom stock reductions if order creation fails mid-request.
  - *Verification:* In `verification.sql` (Section 3B, logged in `evidence/verification_output.txt`) and `Week16MySqlTransactionTests`, `Product 103` (`stock_quantity = 13`) was decremented by `3` before an intentional FK failure (`user_id = 9999`, `ERROR 1452`), followed by `ROLLBACK`. Post-check confirmed `stock_quantity = 13` and `rolled_back_order_count = 0`.
- **RISK-02 — Orphan Records & Duplicate Product SKUs (`TC-05`, `TC-07`, `TC-08`):**
  - *Risk:* Relying only on frontend checks could allow duplicate SKUs, orders for non-existent users, or deletion of products referenced by past orders.
  - *Verification:* Tested directly against MySQL in `verification.sql` (Section 2, logged in `evidence/verification_output.txt`): duplicate SKU `'TEST-LAP-01'` failed with `ERROR 1062`, invalid `user_id = 9999` failed with `ERROR 1452`, and deleting referenced `product_id = 101` failed with `ERROR 1451`.
- **RISK-03 — Over-Privileged Runtime or Reporting DB Accounts (`TC-13`, `TC-14`):**
  - *Risk:* Running the app or reporting queries as `root` would allow accidental schema drops or unauthorized table modifications.
  - *Verification:* `SHOW GRANTS` in `verification.sql` (Section 5, logged in `evidence/verification_output.txt`) confirmed `'webdev2_app'@'localhost'` has only DML (`SELECT, INSERT, UPDATE, DELETE`) on `webdev2_week8.*` (no DDL) and `'webdev2_report'@'localhost'` has only `SELECT` on `webdev2_week8.product_sales_summary`.