-- 1)Retrieve the total number of orders placed

select count(order_id) as total_orders from orders

-- 2)calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.prize)::numeric, 2) AS total_sales
FROM 
    order_details 
JOIN 
    pizzas
ON 
    pizzas.pizza_id = order_details.pizza_id;

-- 3)identify the highest-priced pizza.

SELECT pizzas.prize, pizza_types.name
FROM pizzas 
JOIN pizza_types
ON pizzas.pizza_types_id = pizza_types.pizza_type_id
ORDER BY pizzas.prize DESC 
LIMIT 1;

-- 4)identify the mmost common pizza size ordered.

select pizzas.size, count(order_details.order_details_id)as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;

-- 5)List the top 5 most ordered pizza types along with their quantities.

SELECT pizza_types.name, SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_types_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY quantity DESC 
LIMIT 5;

-- 6)Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, 
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_types_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;

-- 7)Determine the distribution of orders by hour of the day.

SELECT EXTRACT(HOUR FROM time) AS hour, 
    COUNT(order_id) AS order_count
FROM orders GROUP BY EXTRACT(HOUR FROM time)
ORDER BY hour;

-- 8)Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, 
       COUNT(name) AS name_count
FROM pizza_types
GROUP BY category;

-- 9)Group the orders by date and calculate the average number of pizzas ordered per day

SELECT ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM (
    SELECT orders.order_date, 
           SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details
    ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS daily_totals;

-- 10)Determine the top 3 most ordered pizza types based on revenue.

SELECT pizza_types.name,
       SUM(order_details.quantity * pizzas.prize) AS revenue
FROM pizza_types JOIN pizzas
ON pizzas.pizza_types_id = pizza_types.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC LIMIT 3;

-- 11)Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
round(sum(order_details.quantity * pizzas.prize) / (select
(sum(order_details.quantity * pizzas.prize)
) as total_sales
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id) * 100) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_types_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc;

-- 12)Analyze the cumulative revenue generated over time.

SELECT order_date,
       SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date, 
           SUM(order_details.quantity * pizzas.prize) AS revenue
    FROM order_details
    JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
    JOIN orders 
    ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- 13)Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue
FROM (
    SELECT category, 
           name, 
           revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT pizza_types.category, 
               pizza_types.name,
               SUM(order_details.quantity * pizzas.prize) AS revenue
        FROM pizza_types
        JOIN pizzas
        ON pizza_types.pizza_type_id = pizzas.pizza_types_id
        JOIN order_details
        ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;


