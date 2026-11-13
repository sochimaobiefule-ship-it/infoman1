# INFOMAN1 Week 13 — F1: Connected Database Foundation and Views

**Name:** OBIEFULE DECLAN  
**Student ID:** 2510223  
**Project:** Inventory & Order Management System (Spring Boot + MySQL Capstone)  
**Database Engine:** MySQL Server 9.7.2 (InnoDB)  

---

## 1. Six Checkable Requirements

1. A user can register a new product with a name, unique SKU, category, price greater than `0`, and stock quantity of `0` or more, and MySQL rejects any duplicate SKU.
2. A user account can be created with a unique username and unique email so two accounts cannot share the same login or email.
3. A customer can place an order for a product only when both `user_id` and `product_id` already exist in `users` and `products` and the ordered quantity is at least `1`.
4. The database blocks any insert or update that tries to set `products.stock_quantity` below `0` using `chk_products_stock`.
5. Deleting a user or product that is already linked to an order is blocked (`ON DELETE RESTRICT`) so past order records do not end up with missing references.
6. Anyone querying `order_summary_view` can see customer usernames, product names, SKUs, quantities, unit prices, and calculated `line_total` amounts in one report without duplicating data in another table.

---

## 2. Baseline Audit of My Existing Project

When I checked my `webdev2_week8` database and Spring Boot project before starting Week 13, here is what was already working and what needed cleanup:

| Area | Current Status | Where It Is | What I Fixed for Week 13 |
| :--- | :--- | :--- | :--- |
| Main domain tables (`users`, `products`, `customer_orders`, `order_items`) | Working | `webdev2_week8` and JPA entities (`Product.java`, `User.java`, `CustomerOrder.java`, `OrderItem.java`) | Pulled only the 4 capstone tables into `schema.sql` and left out old practice tables (`pet`, `students`, `courses`, `employees`). |
| Row-level `CHECK` rules (`price > 0`, `stock_quantity >= 0`) | Incomplete | Spring Boot `ddl-auto=update` created columns without named SQL `CHECK` constraints | Wrote explicit `CHECK` constraints in `schema.sql` and tested them in `infoman1_week13_test`. |
| Reporting SQL `VIEW` | Missing | Everything in the app used JPA repository methods; there was no SQL view yet | Added `order_summary_view` in `views.sql` and tested live updates in `02_view_before_after.png`. |
| Reproducible `seed.sql` | Incomplete | Data in `webdev2_week8` came from manual browser testing in earlier weeks | Wrote a clean parent-before-child `seed.sql` that anyone can run from scratch. |
| Database login config | Working | `src/main/resources/application.properties` uses `${DB_USERNAME}` and `${DB_PASSWORD}` | Listed the env variable names in `checkpoint.md` so no passwords are pushed to GitHub. |

---

## 3. Database Design, ERD, and Normalization

### Entity-Relationship Diagram

```text
+------------------+          +----------------------+          +------------------+
|      users       |          |   customer_orders    |          |   order_items    |
+------------------+          +----------------------+          +------------------+
| PK id (BIGINT)   | 1      * | PK id (BIGINT)       | 1      * | PK id (BIGINT)   |
| UQ username (NN) |<---------| FK user_id (NN)      |<---------| FK order_id (NN) |
| UQ email (NN)    |          |    order_date (NN)   |          | FK product_id(NN)|---+
+------------------+          |    status (NN)       |          |    quantity (NN)  |   |
                              +----------------------+          |    price (NN)     |   |
                                                                +------------------+   |
                                                                                       | *
                                                                                       v 1
                                                                +------------------------+
                                                                |        products        |
                                                                +------------------------+
                                                                | PK id (BIGINT)         |
                                                                |    name (NN)           |
                                                                | UQ sku (NN)            |
                                                                |    category (NN)       |
                                                                |    price (NN)          |
                                                                |    stock_quantity (NN) |
                                                                +------------------------+

```

*(PK = Primary Key, FK = Foreign Key, UQ = UNIQUE, NN = NOT NULL)*

### Relationships and Nullability

* **Users and Orders (1-to-Many):** One user can place many orders. `customer_orders.user_id` is `NOT NULL` because an order has to belong to a customer.
* **Orders and Order Items (1-to-Many):** One order can have multiple line items. `order_items.order_id` is `NOT NULL` with `ON DELETE CASCADE` so if an order is removed, its items go with it.
* **Products and Order Items (1-to-Many):** One product can appear in many orders. `order_items.product_id` is `NOT NULL` with `ON DELETE RESTRICT` so a product cannot be deleted while orders still point to it.

### Functional Dependencies and Anomalies Prevented

In `products`, the primary key `id` determines `name`, `sku`, `category`, `price`, and `stock_quantity` (and `sku` is also unique, so `sku` determines the rest of the row too). In `order_items`, `id` determines `order_id`, `product_id`, `quantity`, and `price`. I kept `price` inside `order_items` intentionally so an order keeps the price the customer actually paid at checkout even if the product's price changes later.

Splitting `users` and `products` away from `customer_orders` and `order_items` avoids three common problems:

* **Update anomaly:** If a customer changes their email or a product's stock changes, I only update one row in `users` or `products` instead of editing every past order.
* **Insertion anomaly:** I can add a new product into `products` right away even before any customer orders it.
* **Deletion anomaly:** Removing an item from an order does not delete the customer's account or the product listing.

---

## 4. Why `order_summary_view` Is a View Instead of a Table

In `views.sql`, I created `order_summary_view` to join `customer_orders`, `users`, `order_items`, and `products` and calculate `(oi.quantity * oi.price) AS line_total`.

A normal SQL view does not store its own copy of the data—MySQL just saves the `SELECT` query and runs it against the base tables every time I query the view. I proved this in `evidence/02_view_before_after.png`: when I ran `UPDATE order_items SET quantity = 4 WHERE id = 1;`, querying `order_summary_view` immediately showed `line_total` change from `1200.00` to `4800.00` without recreating the view.

Because `order_summary_view` joins four tables and includes a calculated column (`line_total`), I do not run `INSERT`, `UPDATE`, or `DELETE` directly on the view. All data changes in my Spring Boot app go to the actual base tables (`products`, `users`, `customer_orders`, `order_items`), and the view is only used for reading reports.

---

## 5. How My App Reads Data and Protects Credentials

When I open `http://localhost:8080` in the browser, `app.js` sends a `GET` request to `/api/products?page=0&size=5`. `ProductController` passes that call to `ProductService`, which calls `ProductRepository.findAll(pageable)`. Under the hood, Spring Data JPA and Hibernate build a parameterized SQL `SELECT` query and send it through the **MySQL Connector/J JDBC driver** on `localhost:3306` to `webdev2_week8`. MySQL returns the rows from `products`, Spring converts them to `ProductResponseDTO` JSON, and `app.js` displays them in the HTML table using `.textContent` (shown in `04_mysql_matching_rows.png` and `05_app_read_ui.png`).

I keep `DB_USERNAME` and `DB_PASSWORD` out of `application.properties` and load them from local environment variables instead. If passwords were hardcoded in Git or put in frontend `app.js`, anyone viewing the GitHub repo or opening browser DevTools could see the database credentials and connect directly to MySQL.