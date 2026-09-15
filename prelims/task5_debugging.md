### 1. Error Analysis
The query failed with an `Unknown column 'member_name' in 'where clause'` error because:
* **3NF Normalization:** The `borrowing` table is an associative entity that connects `member` and `tool`. To maintain 3NF and reduce redundancy, it only stores foreign keys (`member_id`, `tool_id`) and transactional attributes (`borrow_date`, `return_date`), not descriptive text like `member_name`.
* **DDL Constraints:** In `task3_ddl.sql`, `member_name` was defined inside the `member` table, not the `borrowing` table. MySQL cannot filter by a column that doesn't exist in the target table.

---

### 2. Two-Step Query Solution (Without JOINs)

**Step 1:** Retrieve Maria Santos's `member_id` from the `member` table:
```sql
SELECT member_id 
FROM member 
WHERE member_name = 'Maria Santos';

Step 2: Query the borrowing table using her member_id:
SELECT borrow_id, tool_id, borrow_date, return_date 
FROM borrowing 
WHERE member_id = 1;
```

### 3. Core Concepts Learned
Normalization: Junction tables store foreign key IDs instead of duplicate strings like member names.

Schema Strictness: Queries must reference columns that exist in the specified table.

Multi-Step Lookups: Without JOIN syntax, relational data across tables must be queried using sequential lookup steps via primary/foreign keys.