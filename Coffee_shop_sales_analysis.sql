create database coffee_shop_sales_db

create table coffee_shop_sales("transaction_id" int PRIMARY KEY , "transaction_date" text ,"transaction_time" text , "transaction_qty" int,"store_id" int , "store_location" text , "product_id" int , "unit_price" double precision , "product_category" text , "product_type" text , "product_detail" text );

copy coffee_shop_sales(transaction_id , transaction_date , transaction_time , transaction_qty , store_id , store_location , product_id , unit_price , product_category , product_type , product_detail)
from 'D:\\Data Analyst\\Project\\Coffee Shop sales Analysis\\Coffee Shop Sales.csv'
delimiter ','
csv header;

select * from coffee_shop_sales 

UPDATE coffee_shop_sales
SET transaction_date = TO_DATE(transaction_date, 'DD-MM-YYYY');

ALTER TABLE coffee_shop_sales
ALTER COLUMN transaction_date TYPE DATE
USING transaction_date::DATE;

	-- To describe the table below query is used

SELECT
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM
    information_schema.columns
WHERE
    table_name = 'coffee_shop_sales';

-- Now we update transaction_time column

UPDATE coffee_shop_sales
SET transaction_time = TO_TIMESTAMP(transaction_time, 'HH24:MI:SS');

ALTER TABLE coffee_shop_sales
ALTER COLUMN transaction_time TYPE TIME
USING transaction_time::TIME;

	---Total Sales Analysis

select round(sum(unit_price * transaction_qty)) as Total_Sales 
from coffee_shop_sales
where extract(month from transaction_date) = 5   ---may month

	-- Below query gives total sales according to the month
select extract(month from transaction_date) as Month_no , round(sum(unit_price * transaction_qty)) as Total_Sales
from coffee_shop_sales 
group by Month_no order by Month_no  

	-- Below query gives Data about Month , total_sales , Percentage change Month on Month and Sales Difference

select extract(month from transaction_date) as Month_no ,
round(sum(unit_price * transaction_qty)) as Total_Sales ,
(sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty))
OVER(order by extract(month from transaction_date))) / LAG(sum(unit_price * transaction_qty)) 
OVER(order by extract(month from transaction_date)) * 100 as MoM_percent_change ,
sum(unit_price * transaction_qty) - LAG(sum(unit_price * transaction_qty))
OVER(order by extract(month from transaction_date)) as Sales_difference
from coffee_shop_sales
group by Month_no
order by Month_no;

	---Total Orders Analysis

select count(transaction_id) as Total_orders
from coffee_shop_sales
where extract(month from transaction_date) = 5 --May Month total orders

	-- Total order according to the month 

select extract(month from transaction_date) as month_no ,
count(transaction_id) as Total_orders
from coffee_shop_sales
group by month_no
order by month_no

	-- Total orders according to the month also a month on month percent change

select extract(month from transaction_date) as month_no ,
round(count(transaction_id)) as Total_orders ,
100.0 *(count(transaction_id) - LAG(count(transaction_id)) 
OVER(order by extract(month from transaction_date))) / NULLIF(LAG(count(transaction_id))
OVER(order by extract(month from transaction_date)), 0) as percent_change ,
count(transaction_id) - LAG(count(transaction_id))
OVER(order by extract(month from transaction_date)) as orders_difference
from coffee_shop_sales
group by extract(month from transaction_date)
order by extract(month from transaction_date);

	--Total quantity Analysis

select sum(transaction_qty) as Total_quantity_sold
from coffee_shop_sales
where extract(month from transaction_date) = 5 --May Month total orders

	--total quantity sold w.r.t month

select extract(month from transaction_date) as month_no ,
sum(transaction_qty) as Total_quantity_sold
from coffee_shop_sales
group by month_no
order by month_no

	--total quantity sold w.r.t month and mom increase with the difference of quantity sold

select extract(month from transaction_date) as Month_no ,
sum(transaction_qty) as Total_quantity_sold ,
100.0 *(sum(transaction_qty) - LAG(sum(transaction_qty)) 
OVER(order by extract(month from transaction_date))) / NULLIF(LAG(sum(transaction_qty))
OVER(order by extract(month from transaction_date)), 0) as qty_percent_change  ,
sum(transaction_qty) - LAG(sum(transaction_qty))
OVER(order by extract(month from transaction_date)) as qty_sold_difference
from coffee_shop_sales
group by Month_no
order by Month_no;

	-- to show detailed metrics

SELECT 
    CONCAT(ROUND(CAST(SUM(unit_price * transaction_qty) / 1000 AS numeric), 1), 'K') AS total_sales,
    CONCAT(ROUND(CAST(SUM(transaction_qty) / 1000 AS NUMERIC),1),'K')AS total_qty_sold,
    CONCAT(ROUND(CAST(COUNT(transaction_id) / 1000 AS NUMERIC) ,1),'K' ) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    transaction_date = '2023-06-18';

	--  weekends = sun , sat
	-- weekdays = mon to fri
0 is Sunday
1 is Monday
2 is Tuesday
3 is Wednesday
4 is Thursday
5 is Friday
6 is Saturday

	-- weekday and weekend total sales

Select 
	case when Extract(DOW FROM transaction_date) in (0,6) then 'Weekends'
	else 'Weekdays'
	end as day_type,
	concat(round(cast(sum(unit_price * transaction_qty)/1000 as numeric),1),'K') as Total_sales
from coffee_shop_sales
where extract(month from transaction_date)=5
group by day_type

	-- sales analysis by store location

select 
	store_location,
	concat(round(cast(sum(unit_price * transaction_qty)/1000 as numeric),2),'K') as Total_sales
from coffee_shop_sales
where extract(month from transaction_date)=5 -- may
group by store_location 
order by Total_sales desc 


	--Sales analysis by store location with month 

select 
	extract(month from transaction_date) as month,
	store_location,
	concat(round(cast(sum(unit_price * transaction_qty)/1000 as numeric),2),'K') as Total_sales
from coffee_shop_sales

group by store_location ,month  
order by month , total_sales

	--Average sales

select concat(round(cast(avg(total_sales) / 1000 as numeric) ,1 ) , 'K' ) as avg_sales
from 
(select sum(unit_price * transaction_qty) as total_sales
	from coffee_shop_sales
	where extract(month from transaction_date) = 5  -- may month
	group by transaction_date) 	
	
	--daily sales

select extract(day from transaction_date) as day_of_month ,
round(sum(unit_price * transaction_qty))  as total_sales
from coffee_shop_sales
where extract(month from transaction_date) = 5
group by transaction_date
order by transaction_date

	--daily sales comparing it with average sales 

select day_of_month , total_sales ,
case 
	when total_sales > average_sales then 'Above Average'
	when total_sales < average_sales then 'Below Average'
	else 'Equal to Average'
end as Sales_status 
from (
select extract(day from transaction_date) as day_of_month ,
sum(unit_price * transaction_qty)  as total_sales,
avg(sum(unit_price * transaction_qty)) over () as average_sales
from coffee_shop_sales
where extract(month from transaction_date) = 5
group by day_of_month
) as sales_data
order by day_of_month
	
	--Sales analysis by product category

SELECT 
    product_category, 
    ROUND(CAST(SUM(unit_price * transaction_qty) AS numeric), 2) AS total_sales
FROM 
    coffee_shop_sales
WHERE 
    EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY 
    product_category
ORDER BY 
    total_sales DESC;

	-- Top 10 Product by sales 

select 
	product_type,
	ROUND(CAST(SUM(unit_price * transaction_qty) AS numeric), 2) AS total_sales
FROM
	coffee_shop_sales
WHERE
	extract(month from transaction_date) = 5 
GROUP BY 
	product_type
ORDER BY
	total_sales desc 
limit 10;

	-- Top product by product category
select 
	product_type,
	ROUND(CAST(SUM(unit_price * transaction_qty) AS numeric), 2) AS total_sales
FROM
	coffee_shop_sales
WHERE
	extract(month from transaction_date) = 5 and product_category ='Coffee'
GROUP BY 
	product_type
ORDER BY
	total_sales desc 
limit 10;

	--Total sales by day of week and hours

SELECT 
	SUM(unit_price * transaction_qty) as total_sales ,
	SUM(transaction_qty) as total_qty_sold,
	COUNT(*) as total_orders
FROM
	coffee_shop_sales
WHERE
	extract(month from transaction_date) = 5 and --May
	extract(DOW from transaction_date) = 1 and --Monday 
	extract(hour from transaction_time) = 8 --8th Hour from 24hours

	--Total sales by hours 

SELECT 
EXTRACT(HOUR FROM transaction_time) as Hours,
SUM(unit_price * transaction_qty) as Total_sales
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY EXTRACT(HOUR FROM transaction_time)
ORDER BY EXTRACT(HOUR FROM transaction_time) 

	--Total sales by Days

SELECT 
CASE
WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
WHEN EXTRACT(DOW FROM transaction_date) = 6 THEN 'Saturday'
ELSE 'Sunday'
END AS DAYOFWEEK ,
SUM(unit_price * transaction_qty) as Total_sales
FROM coffee_shop_sales
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY DAYOFWEEK;

	--Total Sales by days in order from Monday to sunday

SELECT 
    day_of_week,
    total_sales
FROM (
    SELECT 
        CASE
            WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
            WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
            WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
            WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
            WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
            WHEN EXTRACT(DOW FROM transaction_date) = 6 THEN 'Saturday'
            ELSE 'Sunday'
        END AS day_of_week,
        SUM(unit_price * transaction_qty) AS total_sales,
        CASE
            WHEN EXTRACT(DOW FROM transaction_date) = 0 THEN 7
            ELSE EXTRACT(DOW FROM transaction_date)
        END AS dow_order
    FROM 
        coffee_shop_sales
    WHERE 
        EXTRACT(MONTH FROM transaction_date) = 5
    GROUP BY 
        day_of_week, dow_order
) AS ordered_sales
ORDER BY 
    dow_order;
