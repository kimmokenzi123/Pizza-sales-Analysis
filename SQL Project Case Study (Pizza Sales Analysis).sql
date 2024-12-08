-- Create database Pizza_project,

-- import file csv files

SELECT * FROM order_details;
SELECT * FROM pizzas;
SELECT * FROM orders;
SELECT * FROM pizza_types;

--A--Basic:
--Retrieve the total number of orders placed.
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- what are the diddferents tyoes of piza availables ? -- This query will list all unique pizza types.

SELECT name, category, ingredients
FROM pizza_types;
-- What is the total quantity of pizzas ordered? -- This query will give the total quantity of pizzas ordered across all orders.

SELECT SUM(quantity) AS total_pizzas_ordered
FROM order_details;
-- What is the total revenue from pizza sales? -- By joining the order_details and pizzas tables, you can calculate the total revenue.

SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

-- How many orders were placed on each day? -- This query will show the number of orders per day.

SELECT date, COUNT(order_id) AS orders_per_day
FROM orders
GROUP BY date
ORDER BY date;


--Calculate the total revenue generated from pizza sales.
SELECT SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;

--Identify the highest-priced pizza.

SELECT TOP 1 pt.name, p.size, p.price
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC;


--Identify the most common pizza size ordered.

SELECT TOP 1 p.size, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_ordered DESC;

--List the top 5 most ordered pizza types along with their quantities.

SELECT TOP 5 pt.name, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_ordered DESC;

--Intermediate:
--Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).
SELECT pt.category, SUM(od.quantity) AS total_ordered
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_ordered DESC;

--Determine the distribution of orders by hour of the day (at which time the orders are maximum (for inventory management and resource allocation).

SELECT DATEPART(HOUR, o.time) AS order_hour, COUNT(o.order_id) AS total_orders
FROM orders o
GROUP BY DATEPART(HOUR, o.time)
ORDER BY total_orders DESC;

--Find the category-wise distribution of pizzas (to understand customer behaviour).

select category, count(distinct pizza_type_id) as [No of pizzas]
from pizza_types
group by category
order by [No of pizzas]


--Group the orders by date and calculate the average number of pizzas ordered per day.

with cte as(
select orders.date as 'Date', sum(order_details.quantity) as 'Total Pizza Ordered that day'
from order_details
join orders on order_details.order_id = orders.order_id
group by orders.date
)
select avg([Total Pizza Ordered that day]) as [Avg Number of pizzas ordered per day]  from cte

-- alternate using subquery
select avg([Total Pizza Ordered that day]) as [Avg Number of pizzas ordered per day] from 
(
	select orders.date as 'Date', sum(order_details.quantity) as 'Total Pizza Ordered that day'
	from order_details
	join orders on order_details.order_id = orders.order_id
	group by orders.date
) as pizzas_ordered

--Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)

select top 3 pizza_types.name, sum(order_details.quantity*pizzas.price) as 'Revenue from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue from pizza] desc

--advanced:
--Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)

select pizza_types.category, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category

-- order by [Revenue from pizza] desc
-- revenue contribution from each pizza by pizza name

select pizza_types.name, 
concat(cast((sum(order_details.quantity*pizzas.price) /
(select sum(order_details.quantity*pizzas.price) 
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as 'Revenue contribution from pizza'
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue contribution from pizza] desc

--Analyze the cumulative revenue generated over time.

with cte as (
select date as 'Date', cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
-- order by [Revenue] desc
)
select Date, Revenue, sum(Revenue) over (order by date) as 'Cumulative Sum'
from cte 
group by date, Revenue

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


