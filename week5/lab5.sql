USE infoman1_vetclinic;

SELECT * 
FROM pet;

SELECT name, species 
FROM pet;

SELECT name, species 
FROM pet 
WHERE species = 'Dog';

SELECT name, species, birth_date 
FROM pet 
WHERE birth_date > '2020-01-01';

SELECT appointment_id, pet_id, appointment_datetime, reason_for_visit 
FROM appointment 
WHERE appointment_datetime >= '2024-03-15';

SELECT name, species, birth_date 
FROM pet 
WHERE species = 'Cat';

SELECT name, species, birth_date 
FROM pet 
WHERE species = 'Feline';