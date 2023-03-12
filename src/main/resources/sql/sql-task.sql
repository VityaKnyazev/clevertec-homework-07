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
(SELECT ticket_no, SUM(amount) as total FROM ticket_flights GROUP BY ticket_no ORDER BY TOTAL DESC LIMIT(1)) UNION (SELECT ticket_no, SUM(amount) as total FROM ticket_flights GROUP BY ticket_no ORDER BY TOTAL ASC LIMIT(1));
-- OR
SELECT tickets.ticket_no, tickets.book_ref, tickets.passenger_id, tickets.passenger_name, SUM(ticket_flights.amount) as ticket_total_amount FROM tickets INNER JOIN ticket_flights ON tickets.ticket_no=ticket_flights.ticket_no GROUP BY tickets.ticket_no HAVING SUM(ticket_flights.amount)=ALL(SELECT total FROM (SELECT ticket_no, SUM(amount) as total FROM ticket_flights GROUP BY ticket_no ORDER BY TOTAL DESC LIMIT(1)) AS t1) OR SUM(ticket_flights.amount)=ALL(SELECT total FROM (SELECT ticket_no, SUM(amount) as total FROM ticket_flights GROUP BY ticket_no ORDER BY TOTAL ASC LIMIT(1)) AS t2) ORDER BY ticket_total_amount, tickets.ticket_no;

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



aircraft code 319, 320, 321, 733, 763, 773, CN1, CR2, SU9 | 9 самолетов

319 - 116, 320 - 140, 321 - 170, 733 - 130, 763 - 222, 773 - 402, CN1 - 12, CR2 - 50, SU9 - 97



 book_ref |       book_date        | total_amount
----------+------------------------+--------------
 3B54BB   | 2017-07-05 14:08:00+00 |   1204500.00

 

  ticket_no   | book_ref | passenger_id |  passenger_name  |                                contact_data
---------------+----------+--------------+------------------+-----------------------------------------------------------------------------
 0005432537033 | 3B54BB   | 5368 241076  | DARYA TIKHONOVA  | {"email": "tikhonova-d.08031967@postgrespro.ru", "phone": "+70821922130"}
 0005432537034 | 3B54BB   | 9994 168772  | TATYANA SOROKINA | {"phone": "+70510887624"}
 0005432537035 | 3B54BB   | 1406 902284  | DMITRIY KUZMIN   | {"email": "dmitriykuzmin.01041984@postgrespro.ru", "phone": "+70814458211"}
(3 rows)

   ticket_no   | flight_id | fare_conditions |  amount
---------------+-----------+-----------------+-----------
 0005432537033 |      6015 | Business        | 199300.00
 0005432537033 |      7726 | Business        |  42100.00
 0005432537033 |     18088 | Business        | 199300.00
 0005432537033 |     30619 | Economy         |  15400.00
(4 rows)