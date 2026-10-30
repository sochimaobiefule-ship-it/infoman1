-- task4_analytics.sql
-- INFOMAN1 Midterm Lab Exam: Task 4 Filtering, Functions & Aggregate Analytics

USE eventhub_midterm;

-- 1. Logical Filtering & Precedence
-- Retrieve bookings between 2025-04-10 and 2025-04-20 AND (VIP category OR price > 500)
SELECT 
    e.booking_id,
    e.booking_date,
    e.event_title,
    bs.session_code,
    bs.ticket_category,
    bs.ticket_price
FROM events e
JOIN booking_sessions bs ON e.booking_id = bs.booking_id
WHERE e.booking_date BETWEEN '2025-04-10' AND '2025-04-20'
  AND (bs.ticket_category = 'VIP' OR bs.ticket_price > 500.00);


-- 2. Text & Date Functions
-- Formatted contact card and days elapsed since booking date relative to '2025-05-01'
SELECT 
    e.booking_id,
    e.event_title,
    CONCAT(o.organizer_name, ' <', o.organizer_email, '>') AS contact_card,
    e.booking_date,
    DATEDIFF('2025-05-01', e.booking_date) AS days_elapsed
FROM events e
JOIN organizers o ON e.organizer_id = o.organizer_id;


-- 3. Pattern Matching with Wildcards
-- Venues ending in 'City' or starting with 'M'
SELECT 
    venue_code,
    venue_name,
    venue_city,
    venue_capacity
FROM venues
WHERE venue_city LIKE '%City' OR venue_city LIKE 'M%';


-- 4. Grouping & HAVING
-- Total tickets booked and gross revenue grouped by ticket category (at least 5 tickets booked)
SELECT 
    ticket_category,
    SUM(tickets_booked) AS total_tickets_booked,
    SUM(tickets_booked * ticket_price) AS gross_revenue
FROM booking_sessions
GROUP BY ticket_category
HAVING SUM(tickets_booked) >= 5;