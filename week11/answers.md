# INFOMAN1 — Week 11 Lab Answers

Name: OBIEFULE DECLAN
Student ID: 2510223
GitHub repo: https://github.com/sochimaobiefule-ship-it/infoman1
Date submitted: 15/10/2026

## Task 1 — Diagnose the Anomalies

**Approach / explanation:**
I diagnosed the three anomalies by running SELECT, INSERT, and DELETE queries on the `student_enrollment` table. First, I ran a `SELECT` on department `D01` to check how many rows hold department data. Next, I inserted a new course (`IT103`) without an enrolled student to observe what missing data was forced into student fields. Finally, I deleted Ana Cruz's `IT102` row to see if any course information was lost as a result.

**Code / query used (if applicable):**
```sql
a. update anomaly 
mysql> SELECT student_id, student_name, dept_id, department_name
    -> FROM student_enrollment
    -> WHERE dept_id = 'D01';

b. insert anomaly
mysql> INSERT INTO student_enrollment (course_id, course_title, dept_id, department_name)
    -> VALUES ('IT103', 'Intro to Networks', 'D01', 'Computing Studies');

mysql> SELECT * FROM student_enrollment WHERE course_id = 'IT103';

c. delete anomaly
mysql> SELECT * FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';

mysql> DELETE FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';

mysql> SELECT * FROM student_enrollment WHERE course_id = 'IT102';
```

**Evidence (screenshot filename, output, or file reference in this folder):**
a. update anomaly
mysql> SELECT student_id, student_name, dept_id, department_name
    -> FROM student_enrollment
    -> WHERE dept_id = 'D01';
+------------+--------------+---------+-------------------+
| student_id | student_name | dept_id | department_name   |
+------------+--------------+---------+-------------------+
|        101 | Ana Cruz     | D01     | Computing Studies |
|        102 | Ben Lim      | D01     | Computing Studies |
|        101 | Ana Cruz     | D01     | Computing Studies |
+------------+--------------+---------+-------------------+
3 rows in set (0.074 sec)

b. insert anomaly
mysql> INSERT INTO student_enrollment (course_id, course_title, dept_id, department_name)
    -> VALUES ('IT103', 'Intro to Networks', 'D01', 'Computing Studies');
Query OK, 1 row affected (0.034 sec)

mysql> SELECT * FROM student_enrollment WHERE course_id = 'IT103';
+------------+--------------+------------------+-----------+-------------------+---------+-------------------+-------+
| student_id | student_name | enrolled_courses | course_id | course_title      | dept_id | department_name   | grade |
+------------+--------------+------------------+-----------+-------------------+---------+-------------------+-------+
|       NULL | NULL         | NULL             | IT103     | Intro to Networks | D01     | Computing Studies |  NULL |
+------------+--------------+------------------+-----------+-------------------+---------+-------------------+-------+
1 row in set (0.022 sec)

c. delete anomaly
mysql> SELECT * FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';
+------------+--------------+------------------+-----------+-----------------+---------+-------------------+-------+
| student_id | student_name | enrolled_courses | course_id | course_title    | dept_id | department_name   | grade |
+------------+--------------+------------------+-----------+-----------------+---------+-------------------+-------+
|        101 | Ana Cruz     | IT101, IT102     | IT102     | Web Development | D01     | Computing Studies |  1.25 |
+------------+--------------+------------------+-----------+-----------------+---------+-------------------+-------+
1 row in set (0.024 sec)

mysql> DELETE FROM student_enrollment WHERE student_id = 101 AND course_id = 'IT102';
Query OK, 1 row affected (0.063 sec)

mysql> SELECT * FROM student_enrollment WHERE course_id = 'IT102';
Empty set (0.005 sec)

**Reflection question:**
_[Which of the three anomalies surprised you most in the seed table, and what single structural fact causes all three?]_
Storing multiple distinct entities in a single table causes insertion anomalies by preventing you from adding a course without an enrolled student, deletion anomalies by erasing an entire course when its last enrolled student is removed, and update anomalies by requiring every duplicate student row to be changed whenever course details update.

## Task 2 — Reach First Normal Form

**Approach / explanation:**
To reach first normal form (1NF), I removed the `enrolled_courses` multi-valued column that contained comma-separated values. I restructured the table so that every row represents exactly one student-course pair with atomic values in every cell. Finally, I established a composite primary key using `(student_id, course_id)` to ensure each row has a dependable identity.

**Code / query used (if applicable):**
```sql
mysql> CREATE TABLE student_enrollment_1nf (
    -> student_id INT NOT NULL,
    -> student_name VARCHAR(100) NOT NULL,
    -> course_id VARCHAR(10) NOT NULL,
    -> course_title VARCHAR(100) NOT NULL,
    -> dept_id VARCHAR(10) NOT NULL,
    -> department_name VARCHAR(100) NOT NULL,
    -> grade DECIMAL(4,2),
    -> PRIMARY KEY (student_id, course_id)
    -> );

mysql> INSERT INTO student_enrollment_1nf VALUES

mysql> SELECT * FROM student_enrollment_1nf;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> CREATE TABLE student_enrollment_1nf (
    -> student_id INT NOT NULL,
    -> student_name VARCHAR(100) NOT NULL,
    -> course_id VARCHAR(10) NOT NULL,
    -> course_title VARCHAR(100) NOT NULL,
    -> dept_id VARCHAR(10) NOT NULL,
    -> department_name VARCHAR(100) NOT NULL,
    -> grade DECIMAL(4,2),
    -> PRIMARY KEY (student_id, course_id)
    -> );
Query OK, 0 rows affected (0.546 sec)

mysql> INSERT INTO student_enrollment_1nf VALUES
    -> (101, 'Ana Cruz', 'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.50),
    -> (101, 'Ana Cruz', 'IT102', 'Web Development',  'D01', 'Computing Studies', 1.25),
    -> (102, 'Ben Lim',  'IT101', 'Database Systems', 'D01', 'Computing Studies', 1.75);
Query OK, 3 rows affected (0.129 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM student_enrollment_1nf;
+------------+--------------+-----------+------------------+---------+-------------------+-------+
| student_id | student_name | course_id | course_title     | dept_id | department_name   | grade |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
|        101 | Ana Cruz     | IT101     | Database Systems | D01     | Computing Studies |  1.50 |
|        101 | Ana Cruz     | IT102     | Web Development  | D01     | Computing Studies |  1.25 |
|        102 | Ben Lim      | IT101     | Database Systems | D01     | Computing Studies |  1.75 |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
3 rows in set (0.011 sec)

**Reflection question:**
_[Why does splitting the multi-valued cell still leave student names repeating, and which normal form removes that next?]_
Splitting the multi-valued cell leaves student names repeating because student_name depends only on student_id, not the entire primary key (student_id, course_id).

## Task 3 — Reach Second Normal Form

**Approach / explanation:**
To reach second normal form (2NF), I identified the composite primary key `(student_id, course_id)` from 1NF and listed all functional dependencies. I then eliminated partial dependencies by creating `students` (for student attributes) and `courses_stage` (for course attributes). The remaining `enrollments` table retains the composite primary key and stores `grade`, which depends on both `student_id` and `course_id`.

**Code / query used (if applicable):**
```sql
mysql> CREATE TABLE courses_stage (
    -> course_id VARCHAR(10) PRIMARY KEY,
    -> course_title VARCHAR(100) NOT NULL,
    -> dept_id VARCHAR(10) NOT NULL,
    -> department_name VARCHAR(100) NOT NULL
    -> );

mysql> CREATE TABLE enrollments (
    -> student_id INT,
    -> course_id VARCHAR(10),
    -> grade DECIMAL(4,2),
    -> PRIMARY KEY (student_id, course_id),
    -> FOREIGN KEY (student_id) REFERENCES students(student_id),
    -> FOREIGN KEY (course_id) REFERENCES courses_stage(course_id)
    -> );

mysql> INSERT INTO students VALUES
    -> (101, 'Ana Cruz'),
    -> (102, 'Ben Lim');

mysql> INSERT INTO courses_stage VALUES
    -> ('IT101', 'Database Systems', 'D01', 'Computing Studies'),
    -> ('IT102', 'Web Development',  'D01', 'Computing Studies');

mysql> INSERT INTO enrollments VALUES
    -> (101, 'IT101', 1.50),
    -> (101, 'IT102', 1.25),
    -> (102, 'IT101', 1.75);

mysql> SELECT
    -> s.student_id,
    -> s.student_name,
    -> c.course_id,
    -> c.course_title,
    -> c.dept_id,
    -> c.department_name,
    -> e.grade
    -> FROM enrollments e
    -> JOIN students s ON e.student_id = s.student_id
    -> JOIN courses_stage c ON e.course_id = c.course_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> CREATE TABLE courses_stage (
    -> course_id VARCHAR(10) PRIMARY KEY,
    -> course_title VARCHAR(100) NOT NULL,
    -> dept_id VARCHAR(10) NOT NULL,
    -> department_name VARCHAR(100) NOT NULL
    -> );
Query OK, 0 rows affected (0.336 sec)

mysql> CREATE TABLE enrollments (
    -> student_id INT,
    -> course_id VARCHAR(10),
    -> grade DECIMAL(4,2),
    -> PRIMARY KEY (student_id, course_id),
    -> FOREIGN KEY (student_id) REFERENCES students(student_id),
    -> FOREIGN KEY (course_id) REFERENCES courses_stage(course_id)
    -> );
Query OK, 0 rows affected (0.483 sec)

mysql> INSERT INTO students VALUES
    -> (101, 'Ana Cruz'),
    -> (102, 'Ben Lim');
Query OK, 2 rows affected (0.106 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> INSERT INTO courses_stage VALUES
    -> ('IT101', 'Database Systems', 'D01', 'Computing Studies'),
    -> ('IT102', 'Web Development',  'D01', 'Computing Studies');
Query OK, 2 rows affected (0.056 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> INSERT INTO enrollments VALUES
    -> (101, 'IT101', 1.50),
    -> (101, 'IT102', 1.25),
    -> (102, 'IT101', 1.75);
Query OK, 3 rows affected (0.105 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> SELECT
    -> s.student_id,
    -> s.student_name,
    -> c.course_id,
    -> c.course_title,
    -> c.dept_id,
    -> c.department_name,
    -> e.grade
    -> FROM enrollments e
    -> JOIN students s ON e.student_id = s.student_id
    -> JOIN courses_stage c ON e.course_id = c.course_id;
+------------+--------------+-----------+------------------+---------+-------------------+-------+
| student_id | student_name | course_id | course_title     | dept_id | department_name   | grade |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
|        101 | Ana Cruz     | IT101     | Database Systems | D01     | Computing Studies |  1.50 |
|        101 | Ana Cruz     | IT102     | Web Development  | D01     | Computing Studies |  1.25 |
|        102 | Ben Lim      | IT101     | Database Systems | D01     | Computing Studies |  1.75 |
+------------+--------------+-----------+------------------+---------+-------------------+-------+
3 rows in set (0.115 sec)

**Reflection question:**
_[How do you tell that student name depends on part of the key while grade depends on the whole key?]_
Reflection question:
Student name depends only on student_id because a student's name remains constant regardless of which course they take. Grade depends on the whole key because a grade represents an outcome earned by a specific student in a specific course.

## Task 4 — Reach Third Normal Form

**Approach / explanation:**
To achieve third normal form (3NF), I eliminated the transitive dependency found in the stage table (`course_id -> dept_id -> department_name`). I extracted department information into a separate `departments` table and kept `dept_id` in `courses` as a foreign key. Finally, I evaluated every final table against the normalization decision path and ran a four-table `JOIN` query to confirm complete data preservation.

**Code / query used (if applicable):**
```sql
mysql> CREATE TABLE departments (
    ->   dept_id VARCHAR(10) PRIMARY KEY,
    ->   department_name VARCHAR(100) NOT NULL
    -> );

mysql> INSERT INTO departments VALUES
    ->   ('D01', 'Computing Studies');

mysql> ALTER TABLE enrollments DROP FOREIGN KEY enrollments_ibfk_2;

msql> DROP TABLE courses_stage;

mysql> CREATE TABLE courses (
    ->   course_id VARCHAR(10) PRIMARY KEY,
    ->   course_title VARCHAR(100) NOT NULL,
    ->   dept_id VARCHAR(10) NOT NULL,
    ->   FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    -> );

mysql> INSERT INTO courses VALUES
    ->   ('IT101', 'Database Systems', 'D01'),
    ->   ('IT102', 'Web Development',  'D01');

mysql> ALTER TABLE enrollments
    ->   ADD CONSTRAINT fk_enrollments_courses
    ->   FOREIGN KEY (course_id) REFERENCES courses(course_id);

mysql> SELECT
    ->   s.student_name,
    ->   c.course_title,
    ->   d.department_name,
    ->   e.grade
    -> FROM enrollments e
    -> JOIN students s ON e.student_id = s.student_id
    -> JOIN courses c ON e.course_id = c.course_id
    -> JOIN departments d ON c.dept_id = d.dept_id;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> CREATE TABLE departments (
    ->   dept_id VARCHAR(10) PRIMARY KEY,
    ->   department_name VARCHAR(100) NOT NULL
    -> );
Query OK, 0 rows affected (0.301 sec)

mysql> INSERT INTO departments VALUES
    ->   ('D01', 'Computing Studies');
Query OK, 1 row affected (0.030 sec)

mysql> ALTER TABLE enrollments DROP FOREIGN KEY enrollments_ibfk_2;
Query OK, 0 rows affected (0.331 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> DROP TABLE courses_stage;
Query OK, 0 rows affected (0.196 sec)

mysql> CREATE TABLE courses (
    ->   course_id VARCHAR(10) PRIMARY KEY,
    ->   course_title VARCHAR(100) NOT NULL,
    ->   dept_id VARCHAR(10) NOT NULL,
    ->   FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
    -> );
Query OK, 0 rows affected (0.265 sec)

mysql> INSERT INTO courses VALUES
    ->   ('IT101', 'Database Systems', 'D01'),
    ->   ('IT102', 'Web Development',  'D01');
Query OK, 2 rows affected (0.046 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE enrollments
    ->   ADD CONSTRAINT fk_enrollments_courses
    ->   FOREIGN KEY (course_id) REFERENCES courses(course_id);
Query OK, 3 rows affected (0.553 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> SELECT
    ->   s.student_name,
    ->   c.course_title,
    ->   d.department_name,
    ->   e.grade
    -> FROM enrollments e
    -> JOIN students s ON e.student_id = s.student_id
    -> JOIN courses c ON e.course_id = c.course_id
    -> JOIN departments d ON c.dept_id = d.dept_id;
+--------------+------------------+-------------------+-------+
| student_name | course_title     | department_name   | grade |
+--------------+------------------+-------------------+-------+
| Ana Cruz     | Database Systems | Computing Studies |  1.50 |
| Ana Cruz     | Web Development  | Computing Studies |  1.25 |
| Ben Lim      | Database Systems | Computing Studies |  1.75 |
+--------------+------------------+-------------------+-------+
3 rows in set (0.115 sec)

**Reflection question:**
_[What makes the department name indirectly dependent, and how does the final four-table join prove nothing was lost?]_
Department name is indirectly dependent because it depends on dept_id, which in turn depends on course_id. The final four-table JOIN proves nothing was lost because joining all four tables across their primary key–foreign key relationships completely reconstructs the student name, course title, department name, and grade for every record.

## Task 5 — Reflection

**Approach / explanation:**
_[Write 2–4 sentences describing how you solved this task.]_

**Code / query used (if applicable):**
```sql
-- paste your SQL (or Java/JDBC, for Week 13+) here
```

**Evidence (screenshot filename, output, or file reference in this folder):**
_[e.g. `task5_reflection.txt`, or paste your 150–200 word reflection here.]_
In a university enrollment system, I’d keep core database operations in 3NF to avoid update bugs and keep data accurate. In Task 1, changing 'Computing Studies' meant updating 3 rows at once, but in 3NF you only update 1 row in the departments table. On the other hand, I’d intentionally leave some denormalization in place for student portal grade view pages or end-of-term reporting. Doing a 4-table JOIN every time thousands of students log in to check grades slows down the database, so having a simplified reporting table saves system performance.

While working on Task 4, I tried dropping `courses_stage` and got an error because `enrollments` was still linked to it as a foreign key. MySQL blocked the drop command immediately. I fixed it by running ALTER TABLE to drop `enrollments_ibfk_2` first, dropping `courses_stage`, and then linking the new 3NF `courses` table back to `enrollments` with a new foreign key.

**Reflection question:**
_[When would you keep some denormalized repetition on purpose, and what single symptom tells you a split dropped a key?]_
You deliberately keep denormalized data in read-heavy systems like analytics dashboards to skip running heavy JOINs every time someone loads a page. You know a split dropped a key when your JOIN query throws a syntax/missing column error or returns a mess of unmatched row combinations.

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [ ] All files placed inside `week11/`
- [ ] This file completed and renamed `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)
