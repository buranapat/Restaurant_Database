-- quantity and total sell group by menu
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
