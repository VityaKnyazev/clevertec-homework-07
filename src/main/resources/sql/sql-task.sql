-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса.
SELECT aircrafts.model AS aircraft, seats.fare_conditions AS service_class, COUNT(seats.seat_no) AS seats_quantity FROM aircrafts, seats WHERE aircrafts.aircraft_code=seats.aircraft_code GROUP BY aircraft, service_class ORDER BY aircraft ASC, seats_quantity ASC;
-- OR
SELECT aircrafts.model AS aircraft, seats.fare_conditions AS service_class, COUNT(seats.seat_no) AS seats_quantity FROM aircrafts INNER JOIN seats ON aircrafts.aircraft_code=seats.aircraft_code GROUP BY aircraft, service_class ORDER BY aircraft ASC, seats_quantity ASC;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест).
SELECT aircrafts.model, COUNT(seats.seat_no) AS seats_quantity FROM aircrafts, seats WHERE aircrafts.aircraft_code=seats.aircraft_code GROUP BY model ORDER BY seats_quantity DESC LIMIT(3);
-- OR
SELECT aircrafts.model, COUNT(seats.seat_no) AS seats_quantity FROM aircrafts INNER JOIN seats ON aircrafts.aircraft_code=seats.aircraft_code GROUP BY model ORDER BY seats_quantity DESC LIMIT(3);

-- 3. Вывести код, модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам.
SELECT aircrafts.aircraft_code AS code, aircrafts.model, seats.seat_no FROM aircrafts INNER JOIN seats ON aircrafts.aircraft_code=seats.aircraft_code WHERE aircrafts.model='Аэробус A321-200' AND seats.fare_conditions != 'Economy' ORDER BY seats.seat_no ASC;

-- 4. Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город).
SELECT airport_code, airport_name AS airport, city FROM airports WHERE city = ANY(SELECT city FROM airports GROUP BY city HAVING COUNT(city) > 1);

-- 5. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация.
SELECT flight_id, flight_no, scheduled_departure, scheduled_arrival, departure_airport, arrival_airport, status, aircraft_code, actual_departure, actual_arrival FROM flights WHERE departure_airport = ANY(SELECT airport_code FROM airports WHERE city = 'Екатеринбург') AND arrival_airport=ANY(SELECT airport_code FROM airports WHERE city = 'Москва') AND (status='On Time' OR status='Scheduled' OR status='Delayed') ORDER BY scheduled_departure ASC LIMIT(1);

-- 6. Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе).
SELECT tickets.ticket_no, tickets.book_ref, tickets.passenger_id, tickets.passenger_name, SUM(ticket_flights.amount) as ticket_total_amount FROM tickets INNER JOIN ticket_flights ON tickets.ticket_no=ticket_flights.ticket_no GROUP BY tickets.ticket_no HAVING SUM(ticket_flights.amount)=ALL(SELECT MIN(total) FROM (SELECT ticket_no, SUM(amount) as total FROM ticket_flights GROUP BY ticket_no) AS t1) OR SUM(ticket_flights.amount)=ALL(SELECT MAX(total) FROM (SELECT ticket_no, SUM(amount) as total FROM ticket_flights GROUP BY ticket_no) AS t2) ORDER BY ticket_total_amount ASC, tickets.ticket_no ASC;

/*
 * 7. Написать DDL таблицы Customers, должны быть поля 
 * id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints).
*/
CREATE TABLE IF NOT EXISTS customers (
id SERIAL NOT NULL,
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

/*
 * 8. Написать DDL таблицы Orders, должен быть id, customerId, quantity. 
 * Должен быть внешний ключ на таблицу customers + ограничения
*/
CREATE TABLE IF NOT EXISTS orders(
id SERIAL NOT NULL,
customer_id INT NOT NULL,
quantity NUMERIC(9, 3) NOT NULL,

CHECK(quantity >= 0),

PRIMARY KEY(id),

CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES customers(id)
ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- 9. Написать 5 insert в эти таблицы.
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

-- 10. Удалить таблицы
ALTER TABLE IF EXISTS orders DROP CONSTRAINT fk_customer;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS orders;
-- OR
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 11. Написать свой кастомный запрос (rus + sql).
/*
 * Посчитать количество билетов на рейсы из Казани в Москву на которые доступно бронирование, где стоимость рейса больше 20 000, но меньшее 50 000, 
 * отсортировать по стоимости и запланированной дате отбытия. Вывести информацию о рейсах, стоимости полета и количестве билетов на рейс.
*/
SELECT flights.flight_id, flights.flight_no, flights.scheduled_departure, flights.scheduled_arrival, flights.departure_airport, flights.arrival_airport, flights.status, flights.aircraft_code, flights.actual_departure, flights.actual_arrival, ticket_flights.amount AS flight_price, COUNT(ticket_flights.ticket_no) AS tickets_quantity FROM flights INNER JOIN ticket_flights ON flights.flight_id=ticket_flights.flight_id WHERE (ticket_flights.amount BETWEEN 20000 AND 50000) AND flights.departure_airport=ANY(SELECT airport_code FROM airports WHERE city = 'Казань') AND flights.arrival_airport=ANY(SELECT airport_code FROM airports WHERE city = 'Москва') AND flights.status='Scheduled' GROUP BY flights.flight_id, ticket_flights.amount ORDER BY ticket_flights.amount ASC, flights.scheduled_departure ASC;