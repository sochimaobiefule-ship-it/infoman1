# Relational Schema — Neighborhood Tool Library

storage_location(<u>location_code</u>, description)

member(<u>member_id</u>, member_name, phone, join_date)

certification(<u>cert_id</u>, cert_name)

tool(<u>tool_id</u>, tool_name, category, purchase_date, location_code [FK])

borrowing(<u>borrow_id</u>, member_id [FK], tool_id [FK], borrow_date, return_date)

member_certification(<u>member_id</u> [FK], <u>cert_id</u> [FK], completion_date)

tool_requirement(<u>tool_id</u> [FK], <u>cert_id</u> [FK])