-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса.
SELECT aircrafts.model AS aircraft, seats.fare_conditions AS service_class,
       count(seats.seat_no) AS seats_quantity
FROM aircrafts, seats
WHERE aircrafts.aircraft_code = seats.aircraft_code
GROUP BY aircraft, service_class
ORDER BY aircraft ASC, seats_quantity ASC;
-- ИЛИ
SELECT aircrafts.model AS aircraft, seats.fare_conditions AS service_class,
       count(seats.seat_no) AS seats_quantity
FROM aircrafts INNER JOIN seats ON aircrafts.aircraft_code = seats.aircraft_code
GROUP BY aircraft, service_class
ORDER BY aircraft ASC, seats_quantity ASC;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест).
SELECT aircrafts.model, count(seats.seat_no) AS seats_quantity
FROM aircrafts, seats
WHERE aircrafts.aircraft_code = seats.aircraft_code
GROUP BY model
ORDER BY seats_quantity DESC
LIMIT 3;
-- ИЛИ
SELECT aircrafts.model, count(seats.seat_no) AS seats_quantity
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

--7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта,
-- отсортированный по убыванию количества рейсов
SELECT airports.airport_name, count(flights.flight_id) AS count_flights
FROM airports
    INNER JOIN flights ON airports.airport_code = flights.departure_airport
GROUP BY airports.airport_name
ORDER BY count_flights DESC;

--8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival)
-- было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT flight_id, flight_no, scheduled_departure, scheduled_arrival,
       departure_airport, arrival_airport, status, aircraft_code,
       actual_departure, actual_arrival
FROM flights WHERE actual_arrival != scheduled_arrival
ORDER BY flight_id;

--9.	Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200"
-- с сортировкой по местам
SELECT aircrafts.aircraft_code AS code, aircrafts.model, seats.seat_no
FROM aircrafts
    INNER JOIN seats ON aircrafts.aircraft_code=seats.aircraft_code
WHERE aircrafts.model='Аэробус A321-200' AND seats.fare_conditions != 'Economy'
ORDER BY seats.seat_no ASC;

--10. Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT airport_code, airport_name AS airport, city
FROM airports
WHERE city = ANY(SELECT city
                 FROM airports
                 GROUP BY city
                 HAVING count(city) > 1);

--11. Найти пассажиров, у которых суммарная стоимость бронирований
-- превышает среднюю сумму всех бронирований
SELECT tickets.passenger_id, tickets.passenger_name,
       tickets.contact_data, sum(bookings.total_amount) AS tickets_amount
FROM tickets
         INNER JOIN bookings ON tickets.book_ref = bookings.book_ref
GROUP BY tickets.passenger_id, tickets.passenger_name,
         tickets.contact_data
HAVING sum(bookings.total_amount) > (SELECT avg(total_amount) FROM bookings)
ORDER BY tickets_amount;

--12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву,
-- на который еще не завершилась регистрация
SELECT flight_id, flight_no, scheduled_departure, scheduled_arrival,
       departure_airport, arrival_airport, status, aircraft_code,
       actual_departure, actual_arrival
FROM flights
WHERE departure_airport = ANY(SELECT airport_code
                              FROM airports
                              WHERE city = 'Екатеринбург') AND arrival_airport=ANY(SELECT airport_code
                                                                                   FROM airports
                                                                                   WHERE city = 'Москва')
                              AND (status='On Time' OR status='Scheduled' OR status='Delayed')
ORDER BY scheduled_departure ASC LIMIT(1);

--13. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе).
(SELECT ticket_no, SUM(amount) as total
 FROM ticket_flights
 GROUP BY ticket_no
 ORDER BY TOTAL DESC
 LIMIT(1))
UNION
(SELECT ticket_no, SUM(amount) as total
 FROM ticket_flights
 GROUP BY ticket_no
 ORDER BY TOTAL ASC
 LIMIT(1));
--ИЛИ все самые дешевые и самые дорогие
SELECT tickets.ticket_no, tickets.book_ref, tickets.passenger_id,
       tickets.passenger_name, SUM(ticket_flights.amount) as ticket_total_amount
FROM tickets
    INNER JOIN ticket_flights ON tickets.ticket_no=ticket_flights.ticket_no
GROUP BY tickets.ticket_no
HAVING SUM(ticket_flights.amount) = ALL(SELECT MIN(total)
                                        FROM (SELECT ticket_no, SUM(amount) as total
                                              FROM ticket_flights
                                              GROUP BY ticket_no) AS t1)
    OR SUM(ticket_flights.amount) = ALL(SELECT MAX(total)
                                        FROM (SELECT ticket_no, SUM(amount) as total
                                              FROM ticket_flights GROUP BY ticket_no) AS t2)
ORDER BY ticket_total_amount ASC, tickets.ticket_no ASC;

-- 14. 14.	Написать DDL таблицы Customers, должны быть поля
-- id, firstName, LastName, email, phone.
-- Добавить ограничения на поля (constraints)
CREATE TABLE IF NOT EXISTS customers (
    id BIGSERIAL NOT NULL,
    first_name CHARACTER VARYING(30) NOT NULL,
    last_name CHARACTER VARYING(40) NOT NULL,
    email CHARACTER VARYING(30) NOT NULL,
    phone CHARACTER VARYING(30) NOT NULL,

    CHECK(email ~* '^[\w-_]{0,}@[a-z]+\.\w+$'),
    CHECK(phone ~* '^\+375\d{9}$'),

    PRIMARY KEY(id),
    UNIQUE(email),
    UNIQUE(phone)
);

--15.	Написать DDL таблицы Orders, должен быть
-- id, customerId, quantity.
-- Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE IF NOT EXISTS orders(
    id BIGSERIAL NOT NULL,
    customer_id BIGINT NOT NULL,
    quantity NUMERIC(9, 3) NOT NULL,

    CHECK(quantity >= 0),

    PRIMARY KEY(id),

    CONSTRAINT fk_customer
    FOREIGN KEY (customer_id)
    REFERENCES customers(id)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

--16. Написать 5 insert в эти таблицы
INSERT INTO customers(first_name, last_name, email, phone) VALUES('Alik', 'Skvartsov', 'hasimo@yandex.by', '+375295689654');
INSERT INTO customers(first_name, last_name, email, phone) VALUES('Yana', 'Andreeva', 'yana@gmail.com', '+375445586932');
INSERT INTO customers(first_name, last_name, email, phone) VALUES('Vladimir', 'Belokonev', 'konevbel@mail.ru', '+375334561473');
INSERT INTO customers(first_name, last_name, email, phone) VALUES('Nikolay', 'Krasnov', 'kolya@tut.by', '+375297563216');
INSERT INTO customers(first_name, last_name, email, phone) VALUES('Anton', 'Efremov', 'efrem@gmail.com', '+375251568452');

INSERT INTO orders(customer_id, quantity) VALUES(1, 6);
INSERT INTO orders(customer_id, quantity) VALUES(2, 9.254);
INSERT INTO orders(customer_id, quantity) VALUES(3, 1.2);
INSERT INTO orders(customer_id, quantity) VALUES(4, 125);
INSERT INTO orders(customer_id, quantity) VALUES(5, 312.56);

--17.	Удалить таблицы
ALTER TABLE IF EXISTS orders DROP CONSTRAINT fk_customer;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;
-- OR
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
