-- task5_joins.sql
-- INFOMAN1 Midterm Lab Exam: Task 5 Multi-Table Joins & Outer Join Diagnostics

USE eventhub_midterm;

-- =====================================================================
-- 1. Lossless Multi-Table INNER JOIN
-- Reconstruct complete event booking view across normalized tables
-- =====================================================================
SELECT 
    e.event_title,
    o.organizer_name,
    v.venue_name,
    bs.ticket_category,
    bs.tickets_booked,
    (bs.tickets_booked * bs.ticket_price) AS total_price
FROM events e
JOIN organizers o ON e.organizer_id = o.organizer_id
JOIN venues v ON e.venue_code = v.venue_code
JOIN booking_sessions bs ON e.booking_id = bs.booking_id;


-- =====================================================================
-- 2. Outer Join Missing-Record Diagnostic
-- Detect idle venues with zero scheduled bookings (e.g., V-CAMPUS)
-- =====================================================================
SELECT 
    v.venue_code,
    v.venue_name,
    v.venue_city,
    v.venue_capacity
FROM venues v
LEFT JOIN events e ON v.venue_code = e.venue_code
WHERE e.booking_id IS NULL;


-- =====================================================================
-- 3. The "Silent Inner Join" Trap Demonstration
-- =====================================================================

-- Version A (Flawed): WHERE clause strips NULL rows (drops idle venues)
SELECT 
    v.venue_code,
    v.venue_name,
    bs.ticket_category,
    bs.ticket_price
FROM venues v
LEFT JOIN events e ON v.venue_code = e.venue_code
LEFT JOIN booking_sessions bs ON e.booking_id = bs.booking_id
WHERE bs.ticket_category = 'VIP';

-- Version B (Correct): Filter placed directly in ON clause (preserves all venues)
SELECT 
    v.venue_code,
    v.venue_name,
    bs.ticket_category,
    bs.ticket_price
FROM venues v
LEFT JOIN events e ON v.venue_code = e.venue_code
LEFT JOIN booking_sessions bs ON e.booking_id = bs.booking_id AND bs.ticket_category = 'VIP';