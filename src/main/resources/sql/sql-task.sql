-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса.
SELECT aircrafts.model AS aircraft, seats.fare_conditions AS service_class,
       COUNT(seats.seat_no) AS seats_quantity
FROM aircrafts, seats
WHERE aircrafts.aircraft_code = seats.aircraft_code
GROUP BY aircraft, service_class
ORDER BY aircraft ASC, seats_quantity ASC;
-- OR
SELECT aircrafts.model AS aircraft, seats.fare_conditions AS service_class,
       COUNT(seats.seat_no) AS seats_quantity
FROM aircrafts INNER JOIN seats ON aircrafts.aircraft_code = seats.aircraft_code
GROUP BY aircraft, service_class
ORDER BY aircraft ASC, seats_quantity ASC;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест).
SELECT aircrafts.model, COUNT(seats.seat_no) AS seats_quantity
FROM aircrafts, seats
WHERE aircrafts.aircraft_code = seats.aircraft_code
GROUP BY model
ORDER BY seats_quantity DESC
LIMIT 3;
-- OR
SELECT aircrafts.model, COUNT(seats.seat_no) AS seats_quantity
FROM aircrafts INNER JOIN seats ON aircrafts.aircraft_code = seats.aircraft_code
GROUP BY model
ORDER BY seats_quantity DESC
LIMIT(3);

--3. Найти все рейсы, которые задерживались более 2 часов
SELECT flight_id, flight_no, scheduled_departure, scheduled_arrival,
       departure_airport, arrival_airport, status, aircraft_code,
       actual_departure, actual_arrival
FROM flights
WHERE date_part('hour', actual_departure - scheduled_departure) > 2 OR
      date_part('hour', actual_arrival - scheduled_arrival) > 2
ORDER BY scheduled_departure;

--4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'),
-- с указанием имени пассажира и контактных данных
SELECT tickets.ticket_no, tickets.passenger_name, tickets.contact_data,
       ticket_flights.flight_id, ticket_flights.fare_conditions,
       ticket_flights.amount, bookings.total_amount AS ticket_total_amount,
       bookings.book_date
FROM tickets
         INNER JOIN ticket_flights ON tickets.ticket_no = ticket_flights.ticket_no
         INNER JOIN bookings ON tickets.book_ref = bookings.book_ref
WHERE ticket_flights.fare_conditions = 'Business'
ORDER BY bookings.book_date DESC
LIMIT 10;

-- 5.	Найти все рейсы, у которых нет забронированных мест
-- в бизнес-классе (fare_conditions = 'Business')
SELECT flight_id, flight_no, scheduled_departure, scheduled_arrival,
       departure_airport, arrival_airport, status, aircraft_code,
       actual_departure, actual_arrival
FROM flights WHERE flight_id NOT IN(SELECT flight_id
                                    FROM ticket_flights
                                    WHERE fare_conditions = 'Business'
                                    GROUP BY flight_id);

-- 6. Получить список аэропортов (airport_name) и городов (city),
-- в которых есть рейсы с задержкой
SELECT airports.airport_name, airports.city
FROM airports
         INNER JOIN flights ON airports.airport_code = flights.departure_airport
    OR airports.airport_code = flights.arrival_airport
WHERE flights.status = 'Delayed' OR flights.actual_departure > flights.scheduled_departure
                                 OR flights.actual_arrival > flights.scheduled_arrival
GROUP BY airports.airport_name, airports.city
ORDER BY airports.city;
