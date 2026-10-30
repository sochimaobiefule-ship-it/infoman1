-- task2_schema_ddl.sql
-- INFOMAN1 Midterm Lab Exam: Task 2 DDL Implementation

USE eventhub_midterm;

DROP TABLE IF EXISTS venues;
DROP TABLE IF EXISTS organizers;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS booking_sessions;
DROP TABLE IF EXISTS speakers;
DROP TABLE IF EXISTS session_speakers;

-- 1. Venues Table
CREATE TABLE venues (
    venue_code VARCHAR(20) NOT NULL,
    venue_name VARCHAR(100) NOT NULL,
    venue_city VARCHAR(50) NOT NULL,
    venue_capacity INT NOT NULL,
    CONSTRAINT pk_venues PRIMARY KEY (venue_code),
    CONSTRAINT chk_venue_capacity CHECK (venue_capacity > 0)
);

-- 2. Organizers Table
CREATE TABLE organizers (
    organizer_id INT NOT NULL,
    organizer_name VARCHAR(100) NOT NULL,
    organizer_email VARCHAR(100) NOT NULL,
    CONSTRAINT pk_organizers PRIMARY KEY (organizer_id),
    CONSTRAINT uq_organizer_email UNIQUE (organizer_email)
);

-- 3. Events Table
CREATE TABLE events (
    booking_id INT NOT NULL,
    booking_date DATE NOT NULL,
    event_title VARCHAR(150) NOT NULL,
    organizer_id INT NOT NULL,
    venue_code VARCHAR(20) NOT NULL,
    CONSTRAINT pk_events PRIMARY KEY (booking_id),
    CONSTRAINT fk_events_organizer FOREIGN KEY (organizer_id) REFERENCES organizers(organizer_id),
    CONSTRAINT fk_events_venue FOREIGN KEY (venue_code) REFERENCES venues(venue_code)
);

-- 4. Booking Sessions Table
CREATE TABLE booking_sessions (
    booking_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    ticket_category VARCHAR(50) NOT NULL DEFAULT 'Standard',
    ticket_price DECIMAL(8,2) NOT NULL,
    tickets_booked INT NOT NULL DEFAULT 1,
    CONSTRAINT pk_booking_sessions PRIMARY KEY (booking_id, session_code),
    CONSTRAINT fk_bs_booking FOREIGN KEY (booking_id) REFERENCES events(booking_id),
    CONSTRAINT chk_ticket_price CHECK (ticket_price >= 0.00)
);

-- 5. Speakers Table
CREATE TABLE speakers (
    speaker_id INT AUTO_INCREMENT NOT NULL,
    speaker_name VARCHAR(100) NOT NULL,
    CONSTRAINT pk_speakers PRIMARY KEY (speaker_id)
);

-- 6. Session Speakers Junction Table
CREATE TABLE session_speakers (
    booking_id INT NOT NULL,
    session_code VARCHAR(20) NOT NULL,
    speaker_id INT NOT NULL,
    CONSTRAINT pk_session_speakers PRIMARY KEY (booking_id, session_code, speaker_id),
    CONSTRAINT fk_ss_session FOREIGN KEY (booking_id, session_code) REFERENCES booking_sessions(booking_id, session_code),
    CONSTRAINT fk_ss_speaker FOREIGN KEY (speaker_id) REFERENCES speakers(speaker_id)
);

-- To verify
SHOW TABLES;

DESCRIBE venues;
DESCRIBE organizers;
DESCRIBE events;
DESCRIBE booking_sessions;
DESCRIBE speakers;
DESCRIBE session_speakers;