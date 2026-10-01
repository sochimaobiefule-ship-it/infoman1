# INFOMAN1 — Week 8 Lab Answers

Name: OBIEFULE DECLAN
Student ID: 2510223
GitHub repo: https://github.com/sochimaobiefule-ship-it/infoman1
Date submitted: 01/10/2026

**Dataset check:** `SELECT COUNT(*) FROM employee;` returned: _[must be 500]_

## Task 1 — Pattern Matching Basics

**Approach / explanation:**
For Task 1, I used LIKE with wildcards to find specific text patterns in the employee table. I used % to match last names ending in "ez" and first names starting with "Ma", and _ to check specific character positions for the employee codes.

**Code / query used (if applicable):**
```sql
i. 
mysql> SELECT emp_id, first_name, last_name
    -> FROM employee
    -> WHERE last_name LIKE '%ez';

ii. 
mysql> SELECT emp_id, first_name, department
    -> FROM employee
    -> WHERE first_name LIKE 'Ma%';

iii.  
mysql> SELECT COUNT(*)
    -> FROM employee
    -> WHERE emp_code LIKE 'E____';

mysql> SELECT emp_code, first_name, last_name
    -> FROM employee
    -> WHERE emp_code LIKE 'E_0__';    
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> SELECT emp_id, first_name, last_name
    -> FROM employee
    -> WHERE last_name LIKE '%ez';
+--------+------------+-----------+
| emp_id | first_name | last_name |
+--------+------------+-----------+
|      1 | Mario      | Gutierrez |
|      2 | Rico       | Jimenez   |
|     16 | Bianca     | Velasquez |
|     17 | Ana        | Gomez     |
|     21 | Mavis      | Perez     |
|     27 | Kevin      | Gomez     |
|     28 | Felix      | Gomez     |
|     29 | Gabriel    | Gomez     |
|     30 | Manuel     | Fernandez |
|     34 | Anna       | Gonzalez  |
|     38 | Matthew    | Jimenez   |
|     39 | Lara       | Ramirez   |
|     41 | Oscar      | Fernandez |
|     42 | Karen      | Velasquez |
|     45 | Mateo      | Gutierrez |
|     48 | Vanessa    | Gutierrez |
|     52 | Paolo      | Velasquez |
|     56 | Emma       | Lopez     |
|     57 | Karen      | Martinez  |
|     58 | Grace      | Gonzalez  |
|     59 | Emma       | Gonzalez  |
|     61 | Sara       | Fernandez |
|     63 | Daniel     | Martinez  |
|     69 | Daniel     | Jimenez   |
|     77 | Manuel     | Gomez     |
|     79 | Rafael     | Martinez  |
|     80 | John       | Gutierrez |
|     82 | Mae        | Gonzalez  |
|     84 | Leo        | Velasquez |
|     86 | Tomas      | Lopez     |
|     88 | Marco      | Gutierrez |
|     91 | Helen      | Ramirez   |
|     96 | Marisol    | Lopez     |
|     97 | Olivia     | Jimenez   |
|    101 | Daniel     | Martinez  |
|    103 | Trisha     | Hernandez |
|    106 | Nathan     | Gonzalez  |
|    107 | Leo        | Gutierrez |
|    108 | Emma       | Perez     |
|    110 | Oscar      | Perez     |
|    112 | Dennis     | Hernandez |
|    114 | Ivan       | Gonzalez  |
|    118 | Lucia      | Velasquez |
|    124 | John       | Gonzalez  |
|    131 | Lara       | Perez     |
|    137 | Marisol    | Sanchez   |
|    142 | Kevin      | Hernandez |
|    143 | Dennis     | Perez     |
|    150 | Yna        | Velasquez |
|    151 | Sofia      | Gonzalez  |
|    153 | Marlon     | Velasquez |
|    154 | Lara       | Perez     |
|    157 | Rafael     | Gutierrez |
|    160 | Walter     | Perez     |
|    168 | Oscar      | Gutierrez |
|    169 | Jose       | Hernandez |
|    173 | Hannah     | Lopez     |
|    174 | Mae        | Fernandez |
|    186 | Daniel     | Jimenez   |
|    190 | Liam       | Perez     |
|    194 | Jose       | Ramirez   |
|    202 | Nathan     | Alvarez   |
|    204 | Mateo      | Lopez     |
|    207 | Manuel     | Gomez     |
|    208 | Mario      | Gutierrez |
|    212 | Marisol    | Rodriguez |
|    213 | Yna        | Rodriguez |
|    216 | Carmen     | Martinez  |
|    218 | Ivan       | Perez     |
|    219 | Isabel     | Gomez     |
|    221 | Leo        | Ramirez   |
|    222 | Helen      | Gonzalez  |
|    224 | Mateo      | Jimenez   |
|    225 | Walter     | Lopez     |
|    231 | Walter     | Gutierrez |
|    237 | Hannah     | Fernandez |
|    238 | Lara       | Sanchez   |
|    243 | Jacob      | Gonzalez  |
|    244 | Diego      | Ramirez   |
|    249 | Daniel     | Gomez     |
|    250 | Liam       | Hernandez |
|    251 | Carmen     | Lopez     |
|    255 | Karen      | Lopez     |
|    262 | Ivan       | Ramirez   |
|    265 | Oscar      | Rodriguez |
|    266 | Marcus     | Sanchez   |
|    268 | Manuel     | Gutierrez |
|    276 | Lara       | Alvarez   |
|    277 | Walter     | Rodriguez |
|    284 | Karen      | Sanchez   |
|    286 | Noel       | Gonzalez  |
|    288 | Jose       | Fernandez |
|    293 | Rafael     | Fernandez |
|    299 | Noel       | Gutierrez |
|    305 | Grace      | Fernandez |
|    307 | Mae        | Gutierrez |
|    310 | Jacob      | Martinez  |
|    311 | Liam       | Hernandez |
|    316 | Olivia     | Gomez     |
|    318 | Noel       | Fernandez |
|    319 | Hannah     | Ramirez   |
|    326 | Liam       | Jimenez   |
|    327 | John       | Gomez     |
|    330 | Victor     | Gutierrez |
|    335 | Manuel     | Lopez     |
|    336 | Hannah     | Gutierrez |
|    337 | Paolo      | Lopez     |
|    344 | Hannah     | Velasquez |
|    345 | Carmen     | Hernandez |
|    349 | Maria      | Hernandez |
|    351 | Ana        | Gonzalez  |
|    352 | Patricia   | Martinez  |
|    356 | Mae        | Ramirez   |
|    358 | Tomas      | Gutierrez |
|    361 | Jose       | Alvarez   |
|    366 | Victor     | Ramirez   |
|    367 | Elena      | Gonzalez  |
|    369 | Ivan       | Velasquez |
|    372 | Dennis     | Martinez  |
|    375 | Sara       | Perez     |
|    376 | John       | Fernandez |
|    383 | Vanessa    | Fernandez |
|    388 | Lucia      | Gonzalez  |
|    389 | Trisha     | Hernandez |
|    391 | Nathan     | Fernandez |
|    397 | Carmen     | Rodriguez |
|    398 | Manuel     | Perez     |
|    401 | Anna       | Gonzalez  |
|    409 | Tomas      | Lopez     |
|    417 | Manuel     | Ramirez   |
|    420 | Helen      | Gomez     |
|    421 | Daniel     | Lopez     |
|    426 | Yna        | Hernandez |
|    427 | Sofia      | Jimenez   |
|    428 | Victor     | Rodriguez |
|    430 | Ana        | Hernandez |
|    433 | Paolo      | Rodriguez |
|    437 | Maria      | Jimenez   |
|    444 | Tomas      | Hernandez |
|    446 | Maricel    | Lopez     |
|    451 | Sara       | Hernandez |
|    453 | Ana        | Sanchez   |
|    459 | Rafael     | Lopez     |
|    460 | Zack       | Sanchez   |
|    463 | Grace      | Rodriguez |
|    466 | Victor     | Sanchez   |
|    474 | Liam       | Sanchez   |
|    476 | Nina       | Lopez     |
|    478 | Manuel     | Gonzalez  |
|    481 | Olivia     | Perez     |
|    482 | Elena      | Gutierrez |
|    483 | Patricia   | Perez     |
|    484 | Matthew    | Gutierrez |
|    486 | Maria      | Rodriguez |
|    489 | Rosa       | Martinez  |
|    491 | Isabel     | Velasquez |
|    493 | Samuel     | Jimenez   |
|    495 | Trisha     | Gonzalez  |
|    496 | Zack       | Martinez  |
|    497 | Mario      | Sanchez   |
|    500 | Jose       | Martinez  |
+--------+------------+-----------+
161 rows in set (0.058 sec)

mysql> SELECT emp_id, first_name, department
    -> FROM employee
    -> WHERE first_name LIKE 'Ma%';
+--------+------------+-------------+
| emp_id | first_name | department  |
+--------+------------+-------------+
|      1 | Mario      | Sales       |
|      3 | Mavis      | Sales       |
|      5 | Manuel     | Sales       |
|      7 | Marlon     | Engineering |
|     13 | Marisol    | Finance     |
|     20 | Mae        | HR          |
|     21 | Mavis      | Support     |
|     22 | Mavis      | Finance     |
|     23 | Mario      | Sales       |
|     24 | Marlon     | Support     |
|     30 | Manuel     | Engineering |
|     31 | Marlon     | Engineering |
|     38 | Matthew    | Engineering |
|     43 | Mae        | Engineering |
|     45 | Mateo      | HR          |
|     46 | Maria      | Support     |
|     62 | Matthew    | Engineering |
|     65 | Mateo      | Engineering |
|     68 | Maricel    | Finance     |
|     70 | Marco      | Sales       |
|     76 | Matthew    | Engineering |
|     77 | Manuel     | Engineering |
|     78 | Maricel    | HR          |
|     81 | Marlon     | Engineering |
|     82 | Mae        | Support     |
|     88 | Marco      | Support     |
|     96 | Marisol    | Support     |
|     99 | Mateo      | Engineering |
|    102 | Mateo      | Support     |
|    115 | Mario      | Support     |
|    122 | Manuel     | Sales       |
|    127 | Mavis      | Finance     |
|    128 | Marco      | Finance     |
|    136 | Mae        | Support     |
|    137 | Marisol    | Support     |
|    138 | Marco      | Support     |
|    140 | Mavis      | Sales       |
|    147 | Manuel     | Support     |
|    153 | Marlon     | Finance     |
|    159 | Mavis      | Finance     |
|    167 | Matthew    | Support     |
|    171 | Marcus     | Support     |
|    174 | Mae        | Engineering |
|    176 | Matthew    | Engineering |
|    180 | Mario      | Engineering |
|    184 | Mario      | Engineering |
|    189 | Maria      | Support     |
|    192 | Marlon     | HR          |
|    195 | Marcus     | Support     |
|    199 | Marcus     | HR          |
|    200 | Marcus     | Engineering |
|    201 | Marlon     | Finance     |
|    204 | Mateo      | Engineering |
|    206 | Mario      | HR          |
|    207 | Manuel     | Sales       |
|    208 | Mario      | Support     |
|    212 | Marisol    | Engineering |
|    224 | Mateo      | Support     |
|    239 | Mateo      | Engineering |
|    246 | Matthew    | Sales       |
|    247 | Manuel     | Support     |
|    252 | Mae        | Sales       |
|    266 | Marcus     | Finance     |
|    268 | Manuel     | Sales       |
|    271 | Matthew    | Engineering |
|    273 | Maricel    | Engineering |
|    274 | Maricel    | Sales       |
|    278 | Marcus     | Sales       |
|    287 | Mavis      | Support     |
|    306 | Mario      | Engineering |
|    307 | Mae        | Sales       |
|    312 | Manuel     | Engineering |
|    315 | Mateo      | Sales       |
|    317 | Mae        | Support     |
|    333 | Manuel     | Engineering |
|    335 | Manuel     | Engineering |
|    338 | Mario      | HR          |
|    342 | Mario      | Sales       |
|    347 | Maricel    | Finance     |
|    349 | Maria      | Engineering |
|    354 | Mavis      | Support     |
|    356 | Mae        | Sales       |
|    370 | Mae        | Finance     |
|    390 | Marco      | Finance     |
|    393 | Marcus     | Support     |
|    398 | Manuel     | HR          |
|    405 | Marcus     | Support     |
|    412 | Marcus     | Engineering |
|    413 | Matthew    | Support     |
|    414 | Marco      | Sales       |
|    416 | Maria      | HR          |
|    417 | Manuel     | Engineering |
|    431 | Marlon     | Support     |
|    437 | Maria      | Engineering |
|    440 | Mavis      | Sales       |
|    441 | Marisol    | Finance     |
|    442 | Marco      | Sales       |
|    443 | Mae        | Sales       |
|    446 | Maricel    | Sales       |
|    450 | Maria      | Sales       |
|    452 | Mateo      | Support     |
|    455 | Matthew    | Finance     |
|    458 | Manuel     | Engineering |
|    461 | Marisol    | HR          |
|    465 | Marcus     | Support     |
|    477 | Mateo      | Support     |
|    478 | Manuel     | Sales       |
|    480 | Mavis      | Support     |
|    484 | Matthew    | Finance     |
|    486 | Maria      | Sales       |
|    488 | Marcus     | Sales       |
|    497 | Mario      | Support     |
+--------+------------+-------------+
112 rows in set (0.007 sec)

mysql> SELECT COUNT(*)
    -> FROM employee
    -> WHERE emp_code LIKE 'E____';
+----------+
| COUNT(*) |
+----------+
|      500 |
+----------+
1 row in set (0.036 sec)

mysql> SELECT emp_code, first_name, last_name
    -> FROM employee
    -> WHERE emp_code LIKE 'E_0__';
+----------+------------+------------+
| emp_code | first_name | last_name  |
+----------+------------+------------+
| E9042    | Isabel     | Cruz       |
| E1041    | John       | Navarro    |
| E9032    | Leo        | Tolentino  |
| E6062    | Jacob      | Morales    |
| E7043    | Matthew    | Jimenez    |
| E9045    | Vanessa    | Gutierrez  |
| E8035    | Matthew    | Soriano    |
| E6040    | Liam       | Mendoza    |
| E8095    | Maricel    | Dela Cruz  |
| E9020    | Olivia     | Pascual    |
| E2053    | Emma       | Perez      |
| E7064    | Oscar      | Perez      |
| E1003    | Lucia      | Velasquez  |
| E5060    | Oscar      | Castillo   |
| E1084    | Liam       | Salazar    |
| E9060    | Rico       | Rivera     |
| E6013    | Bianca     | Tan        |
| E4088    | Isabel     | Morales    |
| E4047    | Helen      | Pascual    |
| E4067    | Mario      | Lim        |
| E1080    | Yna        | Salazar    |
| E4039    | Hannah     | Navarro    |
| E2047    | Walter     | Ramos      |
| E2030    | Gabriel    | Morales    |
| E6077    | Maricel    | Villanueva |
| E3015    | Sara       | Aquino     |
| E3004    | Noel       | Gutierrez  |
| E3010    | Jacob      | Martinez   |
| E3059    | John       | Cruz       |
| E3069    | Hannah     | Ramirez    |
| E3051    | John       | Gomez      |
| E4005    | Carmen     | Tolentino  |
| E4078    | Dennis     | Martinez   |
| E1087    | Olivia     | Bautista   |
| E6025    | Carmen     | Mendoza    |
| E6085    | Lara       | Villanueva |
| E4091    | Maria      | Ortiz      |
| E1032    | Victor     | Domingo    |
| E2042    | Liam       | Navarro    |
| E7029    | Liam       | Mendoza    |
| E5065    | Mavis      | Santos     |
| E3072    | Marisol    | Mendoza    |
| E5047    | Matthew    | Reyes      |
| E8087    | Karen      | Chua       |
| E9080    | Victor     | Morales    |
| E3090    | Maria      | Rodriguez  |
| E8066    | Olivia     | Chua       |
| E3019    | Jose       | Martinez   |
+----------+------------+------------+
48 rows in set (0.015 sec)

**Reflection question:**
_[Why do we use the `%` wildcard instead of the `_` wildcard when searching for fields containing a specific keyword?]_
We use % for keywords because it matches any number of characters, so we don't need to know the exact word length. The _ wildcard only matches a single character, which only works if we know the exact length and letter position.

## Task 2 — Basic Aggregation

**Approach / explanation:**
For Task 2, I used basic aggregate functions to calculate whole-table metrics like headcount, salary totals, and hire dates. I applied COALESCE to commission so that employees with NULL values wouldn't break the total compensation calculation.

**Code / query used (if applicable):**
```sql
mysql> SELECT
    ->     COUNT(*) AS total_employees,
    ->     COUNT(commission) AS employees_with_commission,
    ->     SUM(salary) AS total_monthly_payroll,
    ->     AVG(salary) AS average_salary,
    ->     MIN(hire_date) AS earliest_hire_date,
    ->     MAX(hire_date) AS latest_hire_date,
    ->     SUM(salary + COALESCE(commission, 0)) AS total_compensation_with_commission
    -> FROM employee;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
+-----------------+---------------------------+-----------------------+----------------+--------------------+------------------+------------------------------------+
| total_employees | employees_with_commission | total_monthly_payroll | average_salary | earliest_hire_date | latest_hire_date | total_compensation_with_commission |
+-----------------+---------------------------+-----------------------+----------------+--------------------+------------------+------------------------------------+
|             500 |                       352 |           33282250.00 |   66564.500000 | 2015-01-03         | 2026-09-14       |                        35387750.00 |
+-----------------+---------------------------+-----------------------+----------------+--------------------+------------------+------------------------------------+
1 row in set (0.121 sec)

**Reflection question:**
_[What is the difference between `COUNT(*)` and `COUNT(column_name)`?]_
COUNT(*) counts every row in the result set regardless of NULLs. COUNT(column_name) only counts non-NULL values inside that specific column.

## Task 3 — Grouping Data

**Approach / explanation:**
For Task 3, I used GROUP BY to organize employee metrics by department, job title, status, and hire year. I used the YEAR() function to extract the year from hire dates and added ORDER BY to make the results easier to read.

**Code / query used (if applicable):**
```sql
i. 
mysql> SELECT
    ->     department,
    ->     COUNT(*) AS employee_count,
    ->     ROUND(AVG(salary), 2) AS avg_salary,
    ->     SUM(salary) AS total_payroll
    -> FROM employee
    -> GROUP BY department
    -> ORDER BY total_payroll DESC;

ii.
mysql> SELECT
    ->     job_title,
    ->     COUNT(*) AS headcount,
    ->     MIN(salary) AS min_salary,
    ->     MAX(salary) AS max_salary
    -> FROM employee
    -> GROUP BY job_title
    -> ORDER BY headcount DESC;

iii.
mysql> SELECT
    ->     status,
    ->     COUNT(*) AS employee_count,
    ->     ROUND(AVG(salary), 2) AS avg_salary
    -> FROM employee
    -> GROUP BY status;

iv.
mysql> SELECT
    ->     YEAR(hire_date) AS hire_year,
    ->     COUNT(*) AS total_hired
    -> FROM employee
    -> GROUP BY YEAR(hire_date)
    -> ORDER BY hire_year ASC;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> SELECT
    ->     department,
    ->     COUNT(*) AS employee_count,
    ->     ROUND(AVG(salary), 2) AS avg_salary,
    ->     SUM(salary) AS total_payroll
    -> FROM employee
    -> GROUP BY department
    -> ORDER BY total_payroll DESC;
+-------------+----------------+------------+---------------+
| department  | employee_count | avg_salary | total_payroll |
+-------------+----------------+------------+---------------+
| Sales       |            144 |   71799.65 |   10339150.00 |
| Engineering |            125 |   75160.00 |    9395000.00 |
| Finance     |             69 |   79513.04 |    5486400.00 |
| Support     |            112 |   44028.57 |    4931200.00 |
| HR          |             50 |   62610.00 |    3130500.00 |
+-------------+----------------+------------+---------------+
5 rows in set (0.025 sec)

mysql> SELECT
    ->     job_title,
    ->     COUNT(*) AS headcount,
    ->     MIN(salary) AS min_salary,
    ->     MAX(salary) AS max_salary
    -> FROM employee
    -> GROUP BY job_title
    -> ORDER BY headcount DESC;
+----------------------+-----------+------------+------------+
| job_title            | headcount | min_salary | max_salary |
+----------------------+-----------+------------+------------+
| Account Manager      |        50 |   47100.00 |   84500.00 |
| Sales Manager        |        49 |   81350.00 |  139400.00 |
| Sales Representative |        45 |   28300.00 |   54700.00 |
| Software Engineer    |        44 |   56750.00 |  109850.00 |
| Support Specialist   |        43 |   30450.00 |   51750.00 |
| DevOps Engineer      |        42 |   60650.00 |  114950.00 |
| Support Agent        |        40 |   22550.00 |   39800.00 |
| QA Analyst           |        39 |   39000.00 |   69850.00 |
| Support Lead         |        29 |   50100.00 |   78850.00 |
| Financial Analyst    |        24 |   50850.00 |   89600.00 |
| Finance Manager      |        24 |   89000.00 |  148650.00 |
| Accountant           |        21 |   37100.00 |   67350.00 |
| HR Specialist        |        20 |   32050.00 |   58550.00 |
| HR Manager           |        18 |   76000.00 |  118950.00 |
| Recruiter            |        12 |   30400.00 |   57550.00 |
+----------------------+-----------+------------+------------+
15 rows in set (0.012 sec)

mysql> SELECT
    ->     status,
    ->     COUNT(*) AS employee_count,
    ->     ROUND(AVG(salary), 2) AS avg_salary
    -> FROM employee
    -> GROUP BY status;
+----------+----------------+------------+
| status   | employee_count | avg_salary |
+----------+----------------+------------+
| Active   |            411 |   66430.90 |
| Inactive |             54 |   66979.63 |
| On Leave |             35 |   67492.86 |
+----------+----------------+------------+
3 rows in set (0.018 sec)

mysql> SELECT
    ->     YEAR(hire_date) AS hire_year,
    ->     COUNT(*) AS total_hired
    -> FROM employee
    -> GROUP BY YEAR(hire_date)
    -> ORDER BY hire_year ASC;
+-----------+-------------+
| hire_year | total_hired |
+-----------+-------------+
|      2015 |          35 |
|      2016 |          37 |
|      2017 |          32 |
|      2018 |          42 |
|      2019 |          50 |
|      2020 |          53 |
|      2021 |          47 |
|      2022 |          48 |
|      2023 |          45 |
|      2024 |          45 |
|      2025 |          35 |
|      2026 |          31 |
+-----------+-------------+
12 rows in set (0.048 sec)

**Reflection question:**
_[Why is it generally invalid to include columns in the `SELECT` list that are not in the `GROUP BY` clause, unless they are inside an aggregate function?]_
Any column in the SELECT clause that isn't inside an aggregate function must be in the GROUP BY clause. Without it, SQL doesn't know which row's value to pick for the grouped results.

## Task 4 — Advanced Filtering with HAVING

**Approach / explanation:**
For Task 4, I used HAVING to filter grouped data using aggregate metrics like headcount and average salary. This allowed me to only show departments and job titles that met specific salary and staff count conditions.

**Code / query used (if applicable):**
```sql
i.
mysql> SELECT
    ->     department,
    ->     COUNT(*) AS employee_count,
    ->     ROUND(AVG(salary), 2) AS avg_salary
    -> FROM employee
    -> GROUP BY department
    -> HAVING AVG(salary) > 65000;

ii.
mysql> SELECT
    ->     job_title,
    ->     COUNT(*) AS headcount,
    ->     ROUND(AVG(salary), 2) AS avg_salary
    -> FROM employee
    -> GROUP BY job_title
    -> HAVING COUNT(*) >= 10 AND AVG(salary) > 60000;
```

**Evidence (screenshot filename, output, or file reference in this folder):**
mysql> SELECT
    ->     department,
    ->     COUNT(*) AS employee_count,
    ->     ROUND(AVG(salary), 2) AS avg_salary
    -> FROM employee
    -> GROUP BY department
    -> HAVING AVG(salary) > 65000;
+-------------+----------------+------------+
| department  | employee_count | avg_salary |
+-------------+----------------+------------+
| Sales       |            144 |   71799.65 |
| Engineering |            125 |   75160.00 |
| Finance     |             69 |   79513.04 |
+-------------+----------------+------------+
3 rows in set (0.072 sec)

mysql> SELECT
    ->     job_title,
    ->     COUNT(*) AS headcount,
    ->     ROUND(AVG(salary), 2) AS avg_salary
    -> FROM employee
    -> GROUP BY job_title
    -> HAVING COUNT(*) >= 10 AND AVG(salary) > 60000;
+-------------------+-----------+------------+
| job_title         | headcount | avg_salary |
+-------------------+-----------+------------+
| Sales Manager     |        49 |  109664.29 |
| Account Manager   |        50 |   60663.00 |
| Software Engineer |        44 |   85061.36 |
| DevOps Engineer   |        42 |   84686.90 |
| Financial Analyst |        24 |   66275.00 |
| Finance Manager   |        24 |  119745.83 |
| Support Lead      |        29 |   65175.86 |
| HR Manager        |        18 |   97602.78 |
+-------------------+-----------+------------+
8 rows in set (0.050 sec)

**Reflection question:**
_[Why must we use the `HAVING` clause here instead of the `WHERE` clause to filter by the average value?]_
WHERE filters individual rows before grouping, while HAVING filters the grouped results after aggregate functions are calculated.

## Self-Check

- [ ] All tasks committed with individual, meaningful commit messages
- [ ] All files placed inside `week08/`
- [ ] This file completed and renamed `answers.md`
- [ ] Repository link pasted into Moodle (no files uploaded)
