-- task6_synthesis.sql
-- INFOMAN1 Midterm Lab Exam: Task 6 Schema Evolution & Cross-Week Synthesis

USE eventhub_midterm;

-- =====================================================================
-- 1. SCHEMA EVOLUTION (ALTER TABLE)
-- Add venue_status column with DEFAULT 'ACTIVE' and CHECK constraint
-- =====================================================================
ALTER TABLE venues 
ADD COLUMN venue_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
ADD CONSTRAINT chk_venue_status CHECK (venue_status IN ('ACTIVE', 'RENOVATION', 'INACTIVE'));


-- =====================================================================
-- 2. TARGETED PRIMARY-KEY UPDATE
-- Update V-PARK status to RENOVATION
-- =====================================================================
UPDATE venues
SET venue_status = 'RENOVATION'
WHERE venue_code = 'V-PARK';


-- =====================================================================
-- 3. CONSTRAINT TEST (INVALID STATUS)
-- Attempt setting status outside allowed CHECK values ('CLOSED')
-- =====================================================================
UPDATE venues
SET venue_status = 'CLOSED'
WHERE venue_code = 'V-PARK';


-- =====================================================================
-- 4. INTEGRATED SYNTHESIS REPORT QUERY
-- Joins venues, events, and sessions for ACTIVE venues with AVG price > 300
-- =====================================================================
SELECT 
    v.venue_name,
    v.venue_city,
    COUNT(DISTINCT e.booking_id) AS total_bookings_count,
    SUM(bs.tickets_booked) AS total_attendees,
    ROUND(AVG(bs.ticket_price), 2) AS avg_ticket_price,
    SUM(bs.tickets_booked * bs.ticket_price) AS total_revenue
FROM venues v
JOIN events e ON v.venue_code = e.venue_code
JOIN booking_sessions bs ON e.booking_id = bs.booking_id
WHERE v.venue_status = 'ACTIVE'
GROUP BY v.venue_name, v.venue_city
HAVING AVG(bs.ticket_price) > 300.00
ORDER BY total_revenue DESC;