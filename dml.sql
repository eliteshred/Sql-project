select * from orders

aLTER TABLE orders
ADD COLUMN order_date text ;

UPDATE orders
SET order_date = CONCAT(day,'/' ,month,'/',year);

ALTER TABLE orders
DROP COLUMN day;

ALTER TABLE orders
DROP COLUMN month;

ALTER TABLE orders
DROP COLUMN year;

SELECT order_date
FROM orders
WHERE order_date IS NOT NULL
AND order_date::DATE IS NULL;

ALTER TABLE orders
ALTER COLUMN order_date TYPE DATE
USING order_date::DATE;

