-- task3_dml_operations.sql
-- INFOMAN1 Midterm Lab Exam: Task 3 Data Migration & DML Operations

USE eventhub_midterm;

-- =====================================================================
-- 1. DATA MIGRATION FROM FLAT TABLE
-- =====================================================================

-- Populate venues
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
SELECT DISTINCT venue_code, venue_name, venue_city, venue_capacity
FROM event_booking_flat;

-- Populate organizers
INSERT INTO organizers (organizer_id, organizer_name, organizer_email)
SELECT DISTINCT organizer_id, organizer_name, organizer_email
FROM event_booking_flat;

-- Populate events
INSERT INTO events (booking_id, booking_date, event_title, organizer_id, venue_code)
SELECT DISTINCT booking_id, booking_date, event_title, organizer_id, venue_code
FROM event_booking_flat;

-- Populate booking_sessions
INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
SELECT DISTINCT booking_id, session_code, ticket_category, ticket_price, tickets_booked
FROM event_booking_flat;

-- Populate speakers (extracting atomic names from seed data)
INSERT INTO speakers (speaker_id, speaker_name) VALUES
(1, 'Dr. Perez'),
(2, 'Engr. Cruz'),
(3, 'Prof. Santos'),
(4, 'Ms. Lim'),
(5, 'Dr. Reyes'),
(6, 'Dr. Aquino'),
(7, 'Engr. Tan');

-- Populate session_speakers junction table
INSERT INTO session_speakers (booking_id, session_code, speaker_id) VALUES
(101, 'SESS-A1', 1), -- Dr. Perez
(101, 'SESS-A1', 2), -- Engr. Cruz
(101, 'SESS-A2', 2), -- Engr. Cruz
(102, 'SESS-B1', 3), -- Prof. Santos
(103, 'SESS-A1', 1), -- Dr. Perez
(103, 'SESS-A1', 4), -- Ms. Lim
(104, 'SESS-C1', 3), -- Prof. Santos
(104, 'SESS-C1', 5), -- Dr. Reyes
(105, 'SESS-D1', 6), -- Dr. Aquino
(106, 'SESS-D2', 6), -- Dr. Aquino
(106, 'SESS-D2', 7); -- Engr. Tan

-- =====================================================================
-- 2. INSERT NEW VENUE V-CAMPUS
-- =====================================================================
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-CAMPUS', 'University Amphitheater', 'Quezon City', 500);


-- =====================================================================
-- 3. SAFE CHANGE LOOP: 10% TICKET PRICE INCREASE
-- =====================================================================

-- Step 1 & 2: Preview target rows & count
SELECT booking_id, session_code, ticket_category, ticket_price
FROM booking_sessions
WHERE ticket_price > 400.00;

SELECT COUNT(*) AS target_rows
FROM booking_sessions
WHERE ticket_price > 400.00;

-- Step 3: Execute targeted UPDATE
UPDATE booking_sessions
SET ticket_price = ticket_price * 1.10
WHERE ticket_price > 400.00;

-- Step 4: Verify modifications
SELECT booking_id, session_code, ticket_category, ticket_price
FROM booking_sessions
WHERE ticket_price > 400.00;


-- =====================================================================
-- 4. SAFE CHANGE LOOP: DELETE TEMPORARY VENUE V-TEMP
-- =====================================================================

-- Insert V-TEMP
INSERT INTO venues (venue_code, venue_name, venue_city, venue_capacity)
VALUES ('V-TEMP', 'Temporary Pop-up Venue', 'Manila', 50);

-- Step 1 & 2: Preview target row & count
SELECT * FROM venues WHERE venue_code = 'V-TEMP';

SELECT COUNT(*) AS target_rows FROM venues WHERE venue_code = 'V-TEMP';

-- Step 3: Execute targeted DELETE by primary key
DELETE FROM venues WHERE venue_code = 'V-TEMP';

-- Step 4: Verify deletion
SELECT * FROM venues WHERE venue_code = 'V-TEMP';


-- =====================================================================
-- 5. CONSTRAINT PROTECTION TEST
-- =====================================================================

-- Attempting invalid INSERT with negative ticket price
INSERT INTO booking_sessions (booking_id, session_code, ticket_category, ticket_price, tickets_booked)
VALUES (101, 'SESS-TEST', 'Standard', -100.00, 1);