CREATE DATABASE IF NOT EXISTS infoman1_vetclinic;
USE infoman1_vetclinic;

SHOW DATABASES;

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

SHOW TABLES;

DESCRIBE owner;
DESCRIBE pet;
DESCRIBE veterinarian;
DESCRIBE appointment;
DESCRIBE vaccination_record;

ALTER TABLE owner MODIFY COLUMN phone_number INT;

DESCRIBE owner;

ALTER TABLE owner MODIFY COLUMN phone_number VARCHAR(15) NOT NULL;

DESCRIBE owner;