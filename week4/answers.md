Markdown
# Lab 4: Performance Task Using SQL 1 (DDL & Table Creation)
**Course:** Information Management 1 (INFOMAN1)  
**Database Name:** `infoman1_vetclinic`

---

Task 1: Create the Database
The database `infoman1_vetclinic` was created and selected using MySQL CLI:

```sql
CREATE DATABASE IF NOT EXISTS infoman1_vetclinic;
USE infoman1_vetclinic;
SHOW DATABASES;

Verification
SHOW DATABASES; verified that infoman1_vetclinic exists on the MySQL server.
![Conceptual ERD](task1_show_databases.png)

Task 2: Create the Core Tables
Three core entities were implemented as tables with defined primary keys, auto-incrementing surrogate keys, non-null constraints, and foreign key rules.

SQL DDL Executed:
SQL
CREATE TABLE owner (
    owner_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255),
    CONSTRAINT pk_owner PRIMARY KEY (owner_id)
);

CREATE TABLE pet (
    pet_id INT AUTO_INCREMENT,
    owner_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(30) NOT NULL,
    breed VARCHAR(50),
    birth_date DATE,
    gender ENUM('Male', 'Female', 'Unknown') DEFAULT 'Unknown',
    CONSTRAINT pk_pet PRIMARY KEY (pet_id),
    CONSTRAINT fk_pet_owner FOREIGN KEY (owner_id) 
        REFERENCES owner(owner_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE veterinarian (
    vet_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    specialization VARCHAR(100),
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT pk_veterinarian PRIMARY KEY (vet_id)
);

Verification
Creation confirmed via CLI output.
![Conceptual ERD](task2_core_tables.png)

Task 3: Create the Relationship Tables
Two relationship tables were created to resolve many-to-many relationships and weak entity associations from the Week 3 design.
appointment: Resolves the many-to-many relationship between pet and veterinarian.
vaccination_record: Resolves the weak entity dependent on pet.

SQL DDL Executed:
SQL
CREATE TABLE appointment (
    appointment_id INT AUTO_INCREMENT,
    pet_id INT NOT NULL,
    vet_id INT NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    reason_for_visit VARCHAR(255) NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    CONSTRAINT pk_appointment PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_pet FOREIGN KEY (pet_id) 
        REFERENCES pet(pet_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_appointment_vet FOREIGN KEY (vet_id) 
        REFERENCES veterinarian(vet_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE TABLE vaccination_record (
    vaccination_id INT AUTO_INCREMENT,
    pet_id INT NOT NULL,
    vaccine_name VARCHAR(100) NOT NULL,
    date_administered DATE NOT NULL,
    next_due_date DATE,
    administered_by_vet_id INT,
    CONSTRAINT pk_vaccination PRIMARY KEY (vaccination_id),
    CONSTRAINT fk_vaccination_pet FOREIGN KEY (pet_id) 
        REFERENCES pet(pet_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_vaccination_vet FOREIGN KEY (administered_by_vet_id) 
        REFERENCES veterinarian(vet_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

Verification
Creation confirmed via CLI output.
![Conceptual ERD](task3_relationship_tables.png)

Task 4: Verify the Schema
1. Verification of Table Existence (SHOW TABLES;)
Running SHOW TABLES; produced all 5 expected tables:
appointment
owner
pet
vaccination_record
veterinarian

![Conceptual ERD](task4_show_tables.png)

2. Table Inspection Output (DESCRIBE)
Field	Type	Null	Key	Default	Extra
owner_id	int	NO	PRI	NULL	auto_increment
first_name	varchar(50)	NO		NULL	
last_name	varchar(50)	NO		NULL	
phone_number	varchar(15)	NO		NULL	
email	varchar(100)	YES	UNI	NULL	
address	varchar(255)	YES		NULL
Table: owner
![Conceptual ERD](task4_describe_owner.png)

Field	Type	Null	Key	Default	Extra
pet_id	int	NO	PRI	NULL	auto_increment
owner_id	int	NO	MUL	NULL	
name	varchar(50)	NO		NULL	
species	varchar(30)	NO		NULL	
breed	varchar(50)	YES		NULL	
birth_date	date	YES		NULL	
gender	enum('Male','Female','Unknown')	YES		'Unknown'	
Table: pet
![Conceptual ERD](task4_describe_pet.png)

Field	Type	Null	Key	Default	Extra
vet_id	int	NO	PRI	NULL	auto_increment
first_name	varchar(50)	NO		NULL	
last_name	varchar(50)	NO		NULL	
specialization	varchar(100)	YES		NULL	
phone_number	varchar(15)	NO		NULL	
email	varchar(100)	NO	UNI	NULL
Table: veterinarian
![Conceptual ERD](task4_describe_veterinarian.png)

Field	Type	Null	Key	Default	Extra
appointment_id	int	NO	PRI	NULL	auto_increment
pet_id	int	NO	MUL	NULL	
vet_id	int	NO	MUL	NULL	
appointment_datetime	datetime	NO		NULL	
reason_for_visit	varchar(255)	NO		NULL	
status	enum('Scheduled','Completed','Cancelled')	YES		'Scheduled'	
Table: appointment
![Conceptual ERD](task4_describe_appointment.png)

Field	Type	Null	Key	Default	Extra
vaccination_id	int	NO	PRI	NULL	auto_increment
pet_id	int	NO	MUL	NULL	
vaccine_name	varchar(100)	NO		NULL	
date_administered	date	NO		NULL	
next_due_date	date	YES		NULL	
administered_by_vet_id	int	YES	MUL	NULL	
Table: vaccination_record
![Conceptual ERD](task4_describe_vaccination_record.png)

Task 5: Deliberate Mistake, Diagnosis & Correction
1. Description of Deliberate Mistake
The phone_number column in the owner table was intentionally modified to the INT data type using:

SQL
ALTER TABLE owner MODIFY COLUMN phone_number INT;

2. How DESCRIBE Revealed the Problem
Running DESCRIBE owner; after modifying the column showed that phone_number had its data type changed to int and dropped its NOT NULL constraint:

![Conceptual ERD](task5_describe_before_fix.png)

3. Corrective DDL Action (ALTER TABLE)
To correct the data type, the following DDL statement was executed:

SQL
ALTER TABLE owner MODIFY COLUMN phone_number VARCHAR(15) NOT NULL;

4. Verification After Fix
Running DESCRIBE owner; confirmed that the column definition was successfully restored:

![Conceptual ERD](task5_describe_after_fix.png)

---