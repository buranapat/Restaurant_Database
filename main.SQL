
/*
Design Table
Fact Table
  - Order
    -Order ID # Primary key
    -Transaction ID # FK
    -menu #FK
    -quantities 
Dimension Table
  - Transaction
    - Transaction ID #Primary key
    - Transaction Date
    - Customer ID  # FK
    - Serviceman ID # FK
    - Channel # FK
  - Menu
    -Menu ID  #Primary key
    -Menu name 
    -Type (orderve,meat,dessert)
    -Price
  - Order
    -Order ID # Primary key
    -Transaction ID # FK
    -menu #FK
    -quantities 
  - Customer
    -Customer ID #Primary key
    -Name 
    -Point
  - Servicemans
    - Serviceman ID #Primary key
    - Name
    - rating
  - Channel
    -Channel ID #Primary key
    -Channel (reservation, Walk-in, Delivery)
*/

-- Create Menu Table
CREATE TABLE menu (
  id INT PRIMARY KEY ,
  name VARCHAR,
  type VARCHAR,
  price REAL 
);

INSERT INTO menu values
  (1,'Soup','Orderve',39),
  (2,'Steak','Meat',129),
  (3,'IceCream','Dessert',20);



-- Create Order Table
CREATE TABLE order_of_transaction (
  id INT PRIMARY KEY,
  trans_id INT,
  menu_id INT,
  qty INT,
  FOREIGN KEY (menu_id)
  REFERENCES menu(id)
);

INSERT INTO order_of_transaction values
  (1,1,1,2),
  (2,1,2,2),
  (3,1,3,2),
  (4,2,1,2),
  (5,2,2,1),
  (7,3,1,1),
  (8,3,3,1),
  (9,4,1,2),
  (10,4,2,4),
  (11,4,3,2),
  (12,5,1,1),
  (13,5,2,1),
  (14,6,2,1),
  (15,7,1,3),
  (16,7,2,3),
  (17,7,3,1),
  (18,8,1,1),
  (19,8,2,1),
  (20,8,3,1),
  (21,9,1,8),
  (22,9,2,8);
  
-- Create Customers Table
CREATE TABLE customers (
  id INT PRIMARY KEY ,
  name VARCHAR,
  point REAL 
);

INSERT INTO customers values
  (1,'A',1221.5),
  (2,'B',2000),
  (3,'C',500),
  (4,'D',9999),
  (5,'E',0);

-- Create Servicemans Table
CREATE TABLE servicemans (
  id INT PRIMARY KEY ,
  name VARCHAR,
  rating REAL 
);

INSERT INTO servicemans values
  (1,'a',4.5),
  (2,'b',4.8),
  (3,'c',3.9),
  (4,'d',2);

-- Create Channels Table
CREATE TABLE channels (
  id INT PRIMARY KEY,
  channel VARCHAR
);

INSERT INTO channels values
  (1,'Reservation'),
  (2,'Walk-in'),
  (3,'Delivery');

-- Create Transactions Table
CREATE TABLE transactions (
  id INT PRIMARY KEY,
  transaction_Date VARCHAR,
  customer_id INT,
  serviceman_id INT,
  channel INT
);

INSERT INTO transactions values
  (1,'2022-09-01',1,4,1),
  (2,'2022-09-01',2,NULL,3),
  (3,'2022-09-01',3,2,2),
  (4,'2022-09-01',4,1,2),
  (5,'2022-09-01',5,3,2),
  (6,'2022-09-02',2,NULL,3),
  (7,'2022-09-02',4,2,1),
  (8,'2022-09-03',1,1,2),
  (9,'2022-09-03',4,4,1);

------------------Create Table Part -------------------



WITH sub AS(
  SELECT m.name AS menu,
         ch.channel AS channel,
         o.qty AS qty,
         o.qty * m.price AS Total_price
  FROM transactions AS t
  INNER JOIN order_of_transaction AS o
    ON t.id = o.trans_id
  INNER JOIN customers AS c
    ON t.customer_id = c.id
  INNER JOIN menu AS m
    ON o.menu_id = m.id
  INNER JOIN channels AS ch
    ON t.channel = ch.id
  LEFT JOIN servicemans AS s
    ON s.id = t.serviceman_id
)
  
-- quantity and total sell group by menu
  
SELECT menu, 
       SUM(qty) AS qty, 
       SUM(Total_Price) AS total_Sell
FROM sub
GROUP BY menu
ORDER BY total_Price DESC;

-- total sell group by channel

SELECT channel, SUM(total_sell) AS total_sell
FROM(
  SELECT ch.channel AS channel,
         o.qty * m.price AS total_sell
  FROM transactions AS t
  INNER JOIN order_of_transaction AS o
    ON t.id = o.trans_id
  INNER JOIN customers AS c
    ON t.customer_id = c.id
  INNER JOIN menu AS m
    ON o.menu_id = m.id
  INNER JOIN channels AS ch
    ON t.channel = ch.id
  LEFT JOIN servicemans AS s
    ON s.id = t.serviceman_id
)
GROUP BY channel 
ORDER BY SUM(total_sell) DESC;

-- menu group by customer name
SELECT c.name AS name,
       m.name AS menu,
       SUM(o.qty) AS qty
FROM transactions AS t
INNER JOIN order_of_transaction AS o
  ON t.id = o.trans_id
INNER JOIN customers AS c
  ON t.customer_id = c.id
INNER JOIN menu AS m
  ON o.menu_id = m.id
INNER JOIN channels AS ch
  ON t.channel = ch.id
GROUP BY c.name, m.name;

-- total sell group by serviceman
WITH sub AS (
  SELECT s.rating AS rating,
         o.qty * m.price AS total_sell,
  CASE 
    WHEN s.name IS NULL THEN 'Delivery'
    ELSE s.name
  END AS service_name
  FROM transactions AS t
  INNER JOIN order_of_transaction AS o
    ON t.id = o.trans_id
  INNER JOIN menu AS m
    ON o.menu_id = m.id
  LEFT JOIN servicemans AS s
    ON s.id = t.serviceman_id
  
)

SELECT service_name,
       rating,
       SUM(total_sell) AS total_sell
FROM sub
GROUP BY service_name;
