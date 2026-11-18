# INFOMAN1 Week 15 — Database Least Privilege & Access Control

**Name:** OBIEFULE DECLAN  
**Student ID:** 2510223  
**Date:** 18/11/2026  

## Overview
In earlier weeks, our Spring Boot project (`webdev2`) connected to MySQL (`webdev2_week8` on port `3307`) using `root` or overly broad permissions. Using `root` for normal application runtime is risky because if the web app has a bug or gets compromised, an attacker could drop tables, alter schemas, or read sensitive user data.

To fix this, we applied the **Principle of Least Privilege** by separating database duties across three MySQL accounts:

| Account | Role | Allowed Privileges | Blocked Actions |
| :--- | :--- | :--- | :--- |
| `root@localhost` | Database Maintainer / Owner | Full admin & DDL (`CREATE`, `ALTER`, `DROP`, `GRANT`, view creation) | Not used in Spring Boot runtime or reporting |
| `webdev2_app@localhost` | Spring Boot Runtime User | `SELECT, INSERT, UPDATE, DELETE` on `webdev2_week8.*` | Schema changes (`CREATE`, `ALTER`, `DROP`, `INDEX`, `REFERENCES`) |
| `webdev2_report@localhost` | Read-Only Reporting User | `SELECT` on `webdev2_week8.product_sales_summary` only | Reading base tables (`users`, `products`, `order_items`) and all writes/DDL |

## How `SQL SECURITY DEFINER` Protects Sensitive Tables
We created the `product_sales_summary` view under `root@localhost` with `SQL SECURITY DEFINER`. Because MySQL checks base-table permissions against the view's `DEFINER` (`root@localhost`) instead of the caller, `webdev2_report@localhost` can query product totals and revenue without needing direct `SELECT` access to `products` or `order_items`. At the same time, sensitive columns in `users` (like password hashes and emails) stay completely hidden and inaccessible.

## Updating Spring Boot (`ddl-auto=validate`)
When `spring.jpa.hibernate.ddl-auto=update` is used, Hibernate tries to run `ALTER TABLE` or `CREATE TABLE` commands on startup, which fails once DDL privileges are removed from `webdev2_app`. By letting `root@localhost` own the schema and changing Spring Boot's `application.properties` to `spring.jpa.hibernate.ddl-auto=validate`, the app validates existing tables on startup and runs normal CRUD operations using `webdev2_app@localhost` without needing DDL rights.