# INFOMAN1 — Midterm Practical Assessment: Answer Document

**Name:** _OBIEFULE DECLAN________________________________________________  
**Student ID:** __2510223__________________________________________  
**Repository URL:** __https://github.com/sochimaobiefule-ship-it/infoman1______________________________________  
**Date Submitted:** __30-10-2026______________________________________

---

## Task 1: Normalization Audit & 3NF Decomposition

### Approach
<!-- Describe how you inspected the flat table and decided on the decomposition order -->
I looked into the event_booking_flat table to identify repeating groups, partial dependencies, and transitive dependencies. First, I analyzed the multi-valued speaker_list column containing comma-separated values to establish 1NF. Next, I examined non-key attributes dependent on only part of the composite primary key to reach 2NF. Finally, I identified attributes dependent on other non-key attributes to decouple them into 3NF lookup tables.



### 1. Data Anomalies in `event_booking_flat`
<!-- Identify and explain at least one real example of each anomaly in the provided flat table -->

- **Update Anomaly:**
  If the capacity of Metro Tech Auditorium increases to 350, we have to update multiple rows. If we update one row and forget another, the database ends up with inconsistent venue capacities.

- **Insertion Anomaly:**
  If EventHub wants to register a new venue before any event or session is booked there, we cannot insert it because booking_id and session_code are primary keys and cannot be NULL.

- **Deletion Anomaly:**
  If we delete the booking for Health Informatics 2025, we completely lose the record for the venue V-PARK and organizer Digital Health Alliance if they have no other active bookings.

### 2. Functional Dependencies
<!-- List all functional dependencies identified in the flat dataset -->
- `... (booking_id, session_code) -> ticket_category, ticket_price, tickets_booked ...`
- `... booking_id -> booking_date, organizer_id, event_title, venue_code ...`
- `... organizer_id -> organizer_name, organizer_email ...`
- `... venue_code -> venue_name, venue_city, venue_capacity ...`
- `... speaker_id -> speaker_name ...`

### 3. Normalization Progression
<!-- Detail each step from unnormalized flat table to 1NF, 2NF, and 3NF -->

- **First Normal Form (1NF)** (include how speakers become atomic rows):
  Remove multi-valued comma-separated speaker lists so every cell contains atomic data. Each speaker name is extracted into an independent entity, and session-speaker relationships are handled through a linking table.
  
- **Second Normal Form (2NF):**
  Remove partial functional dependencies where attributes depend only on booking_id rather than the composite key. We separate the event booking header data into a bookings entity, leaving session line items dependent on booking_id, session_code.
  
- **Third Normal Form (3NF):**
  Remove transitive functional dependencies where non-key attributes depend on other non-key attributes. organizer_name and organizer_email depend on organizer_id, while venue_name, venue_city, and venue_capacity depend on venue_code. We isolate these into dedicated organizers and venues tables.

### 4. Final Relational Schema Notation
<!-- Provide the complete relational schema in standard notation: TableName(<u>pk</u>, attr1, attr2, fk_col [FK]) -->

```
venues(<u>venue_code</u>, venue_name, venue_city, venue_capacity)

organizers(<u>organizer_id</u>, organizer_name, organizer_email)

events(<u>booking_id</u>, booking_date, event_title, organizer_id [FK], venue_code [FK])

booking_sessions(<u>booking_id [FK], session_code</u>, ticket_category, ticket_price, tickets_booked)

speakers(<u>speaker_id</u>, speaker_name)

session_speakers(<u>booking_id [FK], session_code [FK], speaker_id [FK]</u>)
```

### Evidence
<!-- Reference the rows of the seed data that demonstrate each anomaly -->
Update Anomaly: V-METRO details repeat across rows with booking_id 101 and 103.

Insertion Anomaly: event_booking_flat requires booking_id and session_code for every record, preventing unbooked venues or organizers from being created.

Deletion Anomaly: Row booking_id 105 contains the only record for V-PARK and Digital Health Alliance in the seed table.

Multi-valued 1NF violation: booking_id 101, session_code 'SESS-A1' contains 'Dr. Perez, Engr. Cruz' in speaker_list.


### Reflection
Why does the many-to-many relationship between sessions and speakers require a junction table instead of another column?
A many-to-many relationship cannot be represented cleanly as a single column without either breaking 1NF atomicity or creating massive redundancy and duplicate rows for every speaker. A junction table decomposes the N:M relationship into two 1:N relationships, keeping attributes atomic, enabling easy querying/indexing, and allowing independent management of speakers and sessions.


---

## Task 2: DDL Implementation with Constraints

### Approach
<!-- Explain your data type choices and constraint definitions (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, DEFAULT, CHECK) -->
I built the 3NF tables using standard data types like `INT` for primary/foreign keys and quantities, `VARCHAR` for text strings, `DATE` for booking dates, and `DECIMAL(8,2)` for prices. I added guardrails like `NOT NULL` on essential fields, `UNIQUE` on organizer email addresses, `DEFAULT` for ticket categories/counts, and `CHECK` constraints to make sure `venue_capacity > 0` and `ticket_price >= 0.00`. Foreign keys were created to enforce referential integrity across all relationships.



### Code / Query Used
<!-- Paste or summarize your DDL (full script is in task2_schema_ddl.sql) -->

```
mysql> CREATE TABLE venues (
    ->     venue_code VARCHAR(20) NOT NULL,
    ->     venue_name VARCHAR(100) NOT NULL,
    ->     venue_city VARCHAR(50) NOT NULL,
    ->     venue_capacity INT NOT NULL,
    ->     CONSTRAINT pk_venues PRIMARY KEY (venue_code),
    ->     CONSTRAINT chk_venue_capacity CHECK (venue_capacity > 0)
    -> );

mysql> CREATE TABLE organizers (
    ->     organizer_id INT NOT NULL,
    ->     organizer_name VARCHAR(100) NOT NULL,
    ->     organizer_email VARCHAR(100) NOT NULL,
    ->     CONSTRAINT pk_organizers PRIMARY KEY (organizer_id),
    ->     CONSTRAINT uq_organizer_email UNIQUE (organizer_email)
    -> );

mysql> CREATE TABLE events (
    ->     booking_id INT NOT NULL,
    ->     booking_date DATE NOT NULL,
    ->     event_title VARCHAR(150) NOT NULL,
    ->     organizer_id INT NOT NULL,
    ->     venue_code VARCHAR(20) NOT NULL,
    ->     CONSTRAINT pk_events PRIMARY KEY (booking_id),
    ->     CONSTRAINT fk_events_organizer FOREIGN KEY (organizer_id) REFERENCES organizers(organizer_id),
    ->     CONSTRAINT fk_events_venue FOREIGN KEY (venue_code) REFERENCES venues(venue_code)
    -> );

mysql> CREATE TABLE booking_sessions (
    ->     booking_id INT NOT NULL,
    ->     session_code VARCHAR(20) NOT NULL,
    ->     ticket_category VARCHAR(50) NOT NULL DEFAULT 'Standard',
    ->     ticket_price DECIMAL(8,2) NOT NULL,
    ->     tickets_booked INT NOT NULL DEFAULT 1,
    ->     CONSTRAINT pk_booking_sessions PRIMARY KEY (booking_id, session_code),
    ->     CONSTRAINT fk_bs_booking FOREIGN KEY (booking_id) REFERENCES events(booking_id),
    ->     CONSTRAINT chk_ticket_price CHECK (ticket_price >= 0.00)
    -> );

mysql> CREATE TABLE speakers (
    ->     speaker_id INT AUTO_INCREMENT NOT NULL,
    ->     speaker_name VARCHAR(100) NOT NULL,
    ->     CONSTRAINT pk_speakers PRIMARY KEY (speaker_id)
    -> );

mysql> CREATE TABLE session_speakers (
    ->     booking_id INT NOT NULL,
    ->     session_code VARCHAR(20) NOT NULL,
    ->     speaker_id INT NOT NULL,
    ->     CONSTRAINT pk_session_speakers PRIMARY KEY (booking_id, session_code, speaker_id),
    ->     CONSTRAINT fk_ss_session FOREIGN KEY (booking_id, session_code) REFERENCES booking_sessions(booking_id, session_code),
    ->     CONSTRAINT fk_ss_speaker FOREIGN KEY (speaker_id) REFERENCES speakers(speaker_id)
    -> );
```

### Evidence: Table Verification (SHOW TABLES / DESCRIBE)
<!-- Paste the verification output of your tables -->

```
mysql> SHOW TABLES;
+----------------------------+
| Tables_in_eventhub_midterm |
+----------------------------+
| booking_sessions           |
| events                     |
| organizers                 |
| session_speakers           |
| speakers                   |
| venues                     |
+----------------------------+

mysql> DESCRIBE venues;
+----------------+--------------+------+-----+---------+-------+
| Field          | Type         | Null | Key | Default | Extra |
+----------------+--------------+------+-----+---------+-------+
| venue_code     | varchar(20)  | NO   | PRI | NULL    |       |
| venue_name     | varchar(100) | NO   |     | NULL    |       |
| venue_city     | varchar(50)  | NO   |     | NULL    |       |
| venue_capacity | int          | NO   |     | NULL    |       |
+----------------+--------------+------+-----+---------+-------+

mysql> DESCRIBE organizers;
+-----------------+--------------+------+-----+---------+-------+
| Field           | Type         | Null | Key | Default | Extra |
+-----------------+--------------+------+-----+---------+-------+
| organizer_id    | int          | NO   | PRI | NULL    |       |
| organizer_name  | varchar(100) | NO   |     | NULL    |       |
| organizer_email | varchar(100) | NO   | UNI | NULL    |       |
+-----------------+--------------+------+-----+---------+-------+

mysql> DESCRIBE events;
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| booking_id   | int          | NO   | PRI | NULL    |       |
| booking_date | date         | NO   |     | NULL    |       |
| event_title  | varchar(150) | NO   |     | NULL    |       |
| organizer_id | int          | NO   | MUL | NULL    |       |
| venue_code   | varchar(20)  | NO   | MUL | NULL    |       |
+--------------+--------------+------+-----+---------+-------+

mysql> DESCRIBE booking_sessions;
+-----------------+--------------+------+-----+----------+-------+
| Field           | Type         | Null | Key | Default  | Extra |
+-----------------+--------------+------+-----+----------+-------+
| booking_id      | int          | NO   | PRI | NULL     |       |
| session_code    | varchar(20)  | NO   | PRI | NULL     |       |
| ticket_category | varchar(50)  | NO   |     | Standard |       |
| ticket_price    | decimal(8,2) | NO   |     | NULL     |       |
| tickets_booked  | int          | NO   |     | 1        |       |
+-----------------+--------------+------+-----+----------+-------+

mysql> DESCRIBE speakers;
+--------------+--------------+------+-----+---------+----------------+
| Field        | Type         | Null | Key | Default | Extra          |
+--------------+--------------+------+-----+---------+----------------+
| speaker_id   | int          | NO   | PRI | NULL    | auto_increment |
| speaker_name | varchar(100) | NO   |     | NULL    |                |
+--------------+--------------+------+-----+---------+----------------+

mysql> DESCRIBE session_speakers;
+--------------+-------------+------+-----+---------+-------+
| Field        | Type        | Null | Key | Default | Extra |
+--------------+-------------+------+-----+---------+-------+
| booking_id   | int         | NO   | PRI | NULL    |       |
| session_code | varchar(20) | NO   | PRI | NULL    |       |
| speaker_id   | int         | NO   | PRI | NULL    |       |
+--------------+-------------+------+-----+---------+-------+
```

### Reflection
Which table in your schema needed a composite primary key, and why?
booking_sessions needed a composite primary key because a single event booking can contain multiple session codes, and a session code like SESS-A1 can appear across different event bookings. Similarly, session_speakers needed a composite primary key to uniquely identify each speaker assigned to a specific session line item.



---

## Task 3: Data Migration & Safe DML Operations

### Approach
<!-- Explain how you moved data from event_booking_flat into your 3NF tables without data loss, including how speaker names were split -->
To migrate data cleanly without redundancy, I used `INSERT INTO ... SELECT DISTINCT` queries to extract unique records for `venues`, `organizers`, `events`, and `booking_sessions` directly from `event_booking_flat`. For the multi-valued `speaker_list`, I populated atomic entries in `speakers` and linked them to their respective session bookings in `session_speakers`. For DML operations, I strictly applied the 4-step Safe Change Loop.



### Code / Query Used
<!-- Paste or summarize your migration INSERT statements and the V-CAMPUS insert (full script is in task3_dml_operations.sql) -->

```
mysql> INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
    -> SELECT DISTINCT venue_code, venue_name, venue_city, venue_capacity
    -> FROM event_booking_flat;

mysql> INSERT INTO organizers (organizer_id, organizer_name, organizer_email)
    -> SELECT DISTINCT organizer_id, organizer_name, organizer_email
    -> FROM event_booking_flat;

mysql> INSERT INTO events (booking_id, booking_date, event_title, organizer_id, venue_code)
    -> SELECT DISTINCT booking_id, booking_date, event_title, organizer_id, venue_code
    -> FROM event_booking_flat;

mysql> INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
    -> SELECT DISTINCT booking_id, session_code, ticket_category, ticket_price, tickets_booked
    -> FROM event_booking_flat;

mysql> INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
    -> VALUES ('V-CAMPUS', 'University Amphitheater', 'Quezon City', 500);
```

### Safe Change Loop: 10% Ticket Price Increase
<!-- Document each of the 4 steps of the Safe Change Loop -->

- **Step 1 (Preview Rows):**
  ```
  mysql> SELECT booking_id, session_code, ticket_category, ticket_price
    -> FROM booking_sessions
    -> WHERE ticket_price > 400.00;
  ```
- **Step 2 (Confirm Target Count):**
  +------------+--------------+-----------------+--------------+
  | booking_id | session_code | ticket_category | ticket_price |
  +------------+--------------+-----------------+--------------+
  |        101 | SESS-A1      | Standard        |       500.00 |
  |        101 | SESS-A2      | VIP             |      1200.00 |
  |        105 | SESS-D1      | VIP             |      1500.00 |
  |        106 | SESS-D2      | Standard        |       600.00 |
  +------------+--------------+-----------------+--------------+  
  
  +-------------+
  | target_rows |
  +-------------+
  |           4 |
  +-------------+
  
- **Step 3 (Execute UPDATE):**
  ```
  mysql> UPDATE booking_sessions
    -> SET ticket_price = ticket_price * 1.10
    -> WHERE ticket_price > 400.00;
  ```
- **Step 4 (Verify Changes):**
  ```
  mysql> SELECT booking_id, session_code, ticket_category, ticket_price
    -> FROM booking_sessions
    -> WHERE ticket_price > 400.00;
  ```

### Safe Change Loop: DELETE of `V-TEMP`
- **Step 1 (Preview Rows):**
  ```
  mysql> SELECT * FROM venues WHERE venue_code = 'V-TEMP';
  ```
  - **Step 2 (Confirm Target Count):**
  +------------+------------------------+------------+----------------+
  | venue_code | venue_name             | venue_city | venue_capacity |
  +------------+------------------------+------------+----------------+
  | V-TEMP     | Temporary Pop-up Venue | Manila     |             50 |
  +------------+------------------------+------------+----------------+

  +-------------+
  | target_rows |
  +-------------+
  |           1 |
  +-------------+

- **Step 3 (Execute DELETE):**
  ```
  mysql> DELETE FROM venues WHERE venue_code = 'V-TEMP';
  ```
- **Step 4 (Verify Changes):**
  ```
  mysql> SELECT * FROM venues WHERE venue_code = 'V-TEMP';
  Empty set (0.034 sec)
  ```

### Evidence: Constraint Protection Verification
<!-- Show the query attempting to insert invalid data (negative ticket price) and the MySQL error response -->

- **Invalid SQL Statement:**
  ```
  mysql> INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
    -> VALUES (101, 'SESS-TEST', 'Standard', -100.00, 1);
  ```
- **MySQL Error Message Received:**
  ```
  ERROR 3819 (HY000): Check constraint 'chk_ticket_price' is violated.
  ```

### Reflection
Why is the `DELETE` targeted by primary key rather than by venue name?
A DELETE statement is targeted by primary key because the primary key is guaranteed to be unique for every single record. Targeting by non-unique fields like venue name or city risks accidentally deleting multiple unintended rows if duplicate or matching records exist.



---

## Task 4: Filtering, Functions & Aggregate Analytics

### Approach
<!-- Explain how you chose filters, wildcards, and grouping columns -->
For Query 1, I used explicit parentheses around the `OR` condition to ensure proper logical precedence over `AND`. For Query 2, I used `CONCAT()` to combine name and email fields and `DATEDIFF()` to calculate days elapsed. For Query 3, I applied `LIKE` with wildcards `%City` and `M%`. For Query 4, I grouped data by `ticket_category` and used `HAVING` to filter aggregated ticket totals.



### Query 1: Compound Logical Filtering with Precedence
**SQL Query:**
```
mysql> SELECT
    ->     e.booking_id,
    ->     e.booking_date,
    ->     e.event_title,
    ->     bs.session_code,
    ->     bs.ticket_category,
    ->     bs.ticket_price
    -> FROM events e
    -> JOIN booking_sessions bs ON e.booking_id = bs.booking_id
    -> WHERE e.booking_date BETWEEN '2025-04-10' AND '2025-04-20'
    ->   AND (bs.ticket_category = 'VIP' OR bs.ticket_price > 500.00);
```
**Output:**
```
+------------+--------------+-------------------------+--------------+-----------------+--------------+
| booking_id | booking_date | event_title             | session_code | ticket_category | ticket_price |
+------------+--------------+-------------------------+--------------+-----------------+--------------+
|        101 | 2025-04-10   | Modern Web & DB Summit  | SESS-A1      | Standard        |       550.00 |
|        101 | 2025-04-10   | Modern Web & DB Summit  | SESS-A2      | VIP             |      1320.00 |
|        105 | 2025-04-20   | Health Informatics 2025 | SESS-D1      | VIP             |      1650.00 |
+------------+--------------+-------------------------+--------------+-----------------+--------------+
```

### Query 2: Scalar String & Date Functions
**SQL Query:**
```
mysql> SELECT
    ->     e.booking_id,
    ->     e.event_title,
    ->     CONCAT(o.organizer_name, ' <', o.organizer_email, '>') AS contact_card,
    ->     e.booking_date,
    ->     DATEDIFF('2025-05-01', e.booking_date) AS days_elapsed
    -> FROM events e
    -> JOIN organizers o ON e.organizer_id = o.organizer_id;
```
**Output:**
```
+------------+-----------------------------+-------------------------------------------------+--------------+--------------+
| booking_id | event_title                 | contact_card                                    | booking_date | days_elapsed |
+------------+-----------------------------+-------------------------------------------------+--------------+--------------+
|        101 | Modern Web & DB Summit      | Tech Forward PH <info@techforward.ph>           | 2025-04-10   |           21 |
|        102 | Urban Ecology Seminar       | Green Earth Initiative <contact@greenearth.org> | 2025-04-12   |           19 |
|        104 | Community Climate Action    | Green Earth Initiative <contact@greenearth.org> | 2025-04-18   |           13 |
|        103 | AI & Cloud Infrastructure   | Innovate Campus Lab <lead@innovatecampus.edu>   | 2025-04-15   |           16 |
|        105 | Health Informatics 2025     | Digital Health Alliance <care@digitalhealth.ph> | 2025-04-20   |           11 |
|        106 | Telemedicine Implementation | Digital Health Alliance <care@digitalhealth.ph> | 2025-04-22   |            9 |
+------------+-----------------------------+-------------------------------------------------+--------------+--------------+
```

### Query 3: Pattern Matching with LIKE Wildcards
**SQL Query:**
```
mysql> SELECT
    ->     venue_code,
    ->     venue_name,
    ->     venue_city,
    ->     venue_capacity
    -> FROM venues
    -> WHERE venue_city LIKE '%City' OR venue_city LIKE 'M%';
```
**Output:**
```
+------------+-------------------------+-------------+----------------+
| venue_code | venue_name              | venue_city  | venue_capacity |
+------------+-------------------------+-------------+----------------+
| V-BAY      | Bayview Convention Hall | Manila      |            150 |
| V-CAMPUS   | University Amphitheater | Quezon City |            500 |
| V-METRO    | Metro Tech Auditorium   | Quezon City |            300 |
+------------+-------------------------+-------------+----------------+
```

### Query 4: GROUP BY and HAVING Summary
**SQL Query:**
```
mysql> SELECT
    ->     ticket_category,
    ->     SUM(tickets_booked) AS total_tickets_booked,
    ->     SUM(tickets_booked * ticket_price) AS gross_revenue
    -> FROM booking_sessions
    -> GROUP BY ticket_category
    -> HAVING SUM(tickets_booked) >= 5;
```
**Output:**
```
+-----------------+----------------------+---------------+
| ticket_category | total_tickets_booked | gross_revenue |
+-----------------+----------------------+---------------+
| Standard        |                   18 |       8960.00 |
| Student         |                   10 |       2500.00 |
+-----------------+----------------------+---------------+
```

### Reflection
Why does Query 4 filter with `HAVING` instead of `WHERE`?
Query 4 uses HAVING instead of WHERE because WHERE filters individual raw table rows before grouping occurs, so it cannot evaluate aggregate functions like SUM(tickets_booked). HAVING operates after the GROUP BY clause has aggregated the rows into summary groups.



---

## Task 5: Multi-Table Joins & Outer Join Diagnostics

### Approach
<!-- Explain which tables you joined, in what order, and which keys you joined on -->
I joined `events`, `organizers`, `venues`, and `booking_sessions` using primary and foreign key predicates to reconstruct the flat report losslessly. To locate unbooked venues, I used a `LEFT JOIN` from `venues` to `events` and filtered for unmatched rows with `WHERE e.booking_id IS NULL`. Lastly, I compared filtering outer joins in the `WHERE` clause versus the `ON` clause to demonstrate the "silent inner join" trap.



### 1. Multi-Table INNER JOIN
**SQL Query:**
```
mysql> SELECT
    ->     e.event_title,
    ->     o.organizer_name,
    ->     v.venue_name,
    ->     bs.ticket_category,
    ->     bs.tickets_booked,
    ->     (bs.tickets_booked * bs.ticket_price) AS total_price
    -> FROM events e
    -> JOIN organizers o ON e.organizer_id = o.organizer_id
    -> JOIN venues v ON e.venue_code = v.venue_code
    -> JOIN booking_sessions bs ON e.booking_id = bs.booking_id;
```
**Output:**
```
+-----------------------------+-------------------------+------------------------------+-----------------+----------------+-------------+
| event_title                 | organizer_name          | venue_name                   | ticket_category | tickets_booked | total_price |
+-----------------------------+-------------------------+------------------------------+-----------------+----------------+-------------+
| Modern Web & DB Summit      | Tech Forward PH         | Metro Tech Auditorium        | Standard        |              4 |     2200.00 |
| Modern Web & DB Summit      | Tech Forward PH         | Metro Tech Auditorium        | VIP             |              2 |     2640.00 |
| Urban Ecology Seminar       | Green Earth Initiative  | Bayview Convention Hall      | Standard        |              5 |     1750.00 |
| Community Climate Action    | Green Earth Initiative  | Bayview Convention Hall      | Standard        |              3 |     1050.00 |
| AI & Cloud Infrastructure   | Innovate Campus Lab     | Metro Tech Auditorium        | Student         |             10 |     2500.00 |
| Health Informatics 2025     | Digital Health Alliance | Greenfield Innovation Center | VIP             |              1 |     1650.00 |
| Telemedicine Implementation | Digital Health Alliance | Greenfield Innovation Center | Standard        |              6 |     3960.00 |
+-----------------------------+-------------------------+------------------------------+-----------------+----------------+-------------+
```

### 2. Finding Unbooked Venues (LEFT JOIN ... IS NULL)
**SQL Query:**
```
mysql> SELECT
    ->     v.venue_code,
    ->     v.venue_name,
    ->     v.venue_city,
    ->     v.venue_capacity
    -> FROM venues v
    -> LEFT JOIN events e ON v.venue_code = e.venue_code
    -> WHERE e.booking_id IS NULL;
```
**Output:**
```
+------------+-------------------------+-------------+----------------+
| venue_code | venue_name              | venue_city  | venue_capacity |
+------------+-------------------------+-------------+----------------+
| V-CAMPUS   | University Amphitheater | Quezon City |            500 |
+------------+-------------------------+-------------+----------------+
```

### 3. The "Silent Inner Join" Trap Comparison
- **Version A (Flawed WHERE filter):**
  ```
  mysql> SELECT
    ->     v.venue_code,
    ->     v.venue_name,
    ->     bs.ticket_category,
    ->     bs.ticket_price
    -> FROM venues v
    -> LEFT JOIN events e ON v.venue_code = e.venue_code
    -> LEFT JOIN booking_sessions bs ON e.booking_id = bs.booking_id
    -> WHERE bs.ticket_category = 'VIP';
  ```
  *Result / Behavior:*
  +------------+------------------------------+-----------------+--------------+
  | venue_code | venue_name                   | ticket_category | ticket_price |
  +------------+------------------------------+-----------------+--------------+
  | V-METRO    | Metro Tech Auditorium        | VIP             |      1320.00 |
  | V-PARK     | Greenfield Innovation Center | VIP             |      1650.00 |
  +------------+------------------------------+-----------------+--------------+
  
- **Version B (Correct ON condition):**
  ```
  mysql> SELECT
    ->     v.venue_code,
    ->     v.venue_name,
    ->     bs.ticket_category,
    ->     bs.ticket_price
    -> FROM venues v
    -> LEFT JOIN events e ON v.venue_code = e.venue_code
    -> LEFT JOIN booking_sessions bs ON e.booking_id = bs.booking_id AND bs.ticket_category = 'VIP';
  ```
  *Result / Behavior:*
  +------------+------------------------------+-----------------+--------------+
  | venue_code | venue_name                   | ticket_category | ticket_price |
  +------------+------------------------------+-----------------+--------------+
  | V-BAY      | Bayview Convention Hall      | NULL            |         NULL |
  | V-BAY      | Bayview Convention Hall      | NULL            |         NULL |
  | V-CAMPUS   | University Amphitheater      | NULL            |         NULL |
  | V-METRO    | Metro Tech Auditorium        | VIP             |      1320.00 |
  | V-METRO    | Metro Tech Auditorium        | NULL            |         NULL |
  | V-PARK     | Greenfield Innovation Center | VIP             |      1650.00 |
  | V-PARK     | Greenfield Innovation Center | NULL            |         NULL |
  +------------+------------------------------+-----------------+--------------+

- **Technical Explanation:**
  <!-- Why does moving the filter from ON to WHERE strip preserved NULL rows in an outer join? -->
  When a filter condition is placed in the WHERE clause, it evaluates after the LEFT JOIN generates its result set. The outer join creates rows with NULL for unbooked venues, but WHERE bs.ticket_category = 'VIP' evaluates NULL = 'VIP' as false and drops those preserved rows. This effectively turns the outer join back into an inner join. Placing the condition inside the ON clause ensures the condition is evaluated during the join process, allowing unmatched rows to stay preserved with NULLs.
  

### Reflection
Why is `= NULL` the wrong way to find unbooked venues, and what is the correct test?
= NULL is incorrect because NULL represents an unknown value in SQL, so any equality test using = returns UNKNOWN (false) instead of true. The correct test is IS NULL, which specifically checks for missing references or unmatched rows created by an outer join.



---

## Task 6: Schema Evolution & Cross-Week Synthesis

### Approach
<!-- Explain how you added venue_status and why you chose the CHECK values -->
I evolved the `venues` table using `ALTER TABLE` to add `venue_status` with a default value of `'ACTIVE'` and a `CHECK` constraint restricting values to `'ACTIVE'`, `'RENOVATION'`, or `'INACTIVE'`. I performed a targeted update on `V-PARK` using its primary key, tested constraint protection with an invalid status `'CLOSED'`, and wrote an integrated synthesis query linking venues, events, and booking sessions with aggregate functions, scalar/aggregate filtering, and ordering.



### 1. ALTER TABLE Statement & Status Constraint
```
mysql> ALTER TABLE venues
    -> ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    -> ADD CONSTRAINT chk_venue_status CHECK (venue_status IN ('ACTIVE', 'RENOVATION', 'INACTIVE'));
```

### 2. Targeted Primary-Key UPDATE
```
mysql> UPDATE venues
    -> SET venue_status = 'RENOVATION'
    -> WHERE venue_code = 'V-PARK';
```

### 3. Constraint Test (invalid status)
- **Invalid SQL Statement:**
  ```
  mysql> UPDATE venues
    -> SET venue_status = 'CLOSED'
    -> WHERE venue_code = 'V-PARK';
  ```
- **MySQL Error Message Received:**
  ```
  ERROR 3819 (HY000): Check constraint 'chk_venue_status' is violated.
  ```

### 4. Integrated Synthesis Report Query
**SQL Query:**
```
mysql> SELECT
    ->     v.venue_name,
    ->     v.venue_city,
    ->     COUNT(DISTINCT e.booking_id) AS total_bookings_count,
    ->     SUM(bs.tickets_booked) AS total_attendees,
    ->     ROUND(AVG(bs.ticket_price), 2) AS avg_ticket_price,
    ->     SUM(bs.tickets_booked * bs.ticket_price) AS total_revenue
    -> FROM venues v
    -> JOIN events e ON v.venue_code = e.venue_code
    -> JOIN booking_sessions bs ON e.booking_id = bs.booking_id
    -> WHERE v.venue_status = 'ACTIVE'
    -> GROUP BY v.venue_name, v.venue_city
    -> HAVING AVG(bs.ticket_price) > 300.00
    -> ORDER BY total_revenue DESC;
```
**Output:**
```
+-------------------------+-------------+----------------------+-----------------+------------------+---------------+
| venue_name              | venue_city  | total_bookings_count | total_attendees | avg_ticket_price | total_revenue |
+-------------------------+-------------+----------------------+-----------------+------------------+---------------+
| Metro Tech Auditorium   | Quezon City |                    2 |              16 |           706.67 |       7340.00 |
| Bayview Convention Hall | Manila      |                    2 |               8 |           350.00 |       2800.00 |
+-------------------------+-------------+----------------------+-----------------+------------------+---------------+
```

### Reflection
Why does adding `NOT NULL DEFAULT 'ACTIVE'` succeed on a table that already holds rows?
Adding NOT NULL DEFAULT 'ACTIVE' succeeds on an existing table with rows because MySQL automatically fills all existing rows in that column with the specified DEFAULT value ('ACTIVE') at the moment the column is added, avoiding any null constraint violations.



---

## Task 7: Self-Review & Reflection

### Self-Audit Checklist
- [x] All three anomalies (update, insert, delete) clearly explained with examples
- [x] Schema systematically normalized from flat table $\rightarrow$ 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF
- [x] Speakers modeled with a junction table
- [x] All primary keys underlined and foreign keys marked in schema notation
- [x] DDL created with `NOT NULL`, `UNIQUE`, `DEFAULT`, and `CHECK` constraints
- [x] 4-step Safe Change Loop followed for the `UPDATE` and the `DELETE`
- [x] Invalid insert correctly triggered and documented MySQL constraint error
- [x] Query 1 properly uses parentheses for `AND` / `OR` operator precedence
- [x] Query 4 properly uses `HAVING` instead of `WHERE` for aggregate filter
- [x] Outer join missing-record query uses `IS NULL` check
- [x] Silent inner join trap clearly explained with both query variations
- [x] `ALTER TABLE` successfully executed and invalid status rejected
- [x] Integrated synthesis report combines joins, aggregation, grouping, and ordering

### Concluding Reflection
1. What was the most significant challenge when decomposing the unnormalized flat table into 3NF, and how did separating entities improve data integrity?
The hardest part was spotting the difference between partial and transitive dependencies on the composite key (booking_id, session_code), as well as splitting the comma-separated speaker_list into a proper junction table. Separating the flat data into distinct entities cleaned up duplicate entries, stopped update/delete anomalies, and made sure details like venue capacities or organizer emails only ever need to be changed in a single place.
   
   

2. What are the practical performance tradeoffs between keeping a single flat table versus querying multiple normalized tables using `JOIN`s in a high-traffic production environment?
A flat table makes simple read queries faster because you don't need any JOINs, but it wastes disk space, causes data anomalies, and slows down updates since modifying repeated data locks multiple rows. On the other hand, normalized tables save space and keep data consistent for fast, safe inserts and updates, but they add CPU overhead when running multi-table JOINs during heavy read activity.