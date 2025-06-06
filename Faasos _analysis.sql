USE [Faasos]
GO
/****** Object:  StoredProcedure [dbo].[Faasos_analysis]    Script Date: 25-05-2025 15:51:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[Faasos_analysis]
as
begin

--how many rolls were ordered
select count(roll_id) as no_of_ordered_roll from customer_order; --10

--which customer has given maximum orders
select top 2 customer_id,count(*) as total_roll from customer_order 
group by customer_id
order by total_roll desc; --- 101 and 103 both have max order with same number of order

--In how many rolls extra items included
select order_id ,count(*) as extra_items_included_Inroll from customer_order 
where extra_items_included is not null
group by order_id
order by extra_items_included_Inroll desc;  -- total 2,order_id 5 and 7

--On which date max order has done by customer 
select cast(order_date as date),count(*) as max_order_date from customer_order
group by cast(order_date as date)
order by max_order_date desc;  --order date 4 and 8  has max orders i.e 3

--duplicate order done by the customer
select [order_id]
      ,[customer_id]
      ,[roll_id]    
      ,[order_date]
	  ,count(*) as duplicate_order
	  from customer_order
group by [order_id],[customer_id],[roll_id],[order_date]
having count(*)>1;    --duplicate_order 2 i.e order_id 4


--Unique customer who has done order
select count(distinct [customer_id]) from customer_order; --5

--no. of rolls has ordered by each customer
select customer_id, count(roll_id) as no_of_rollId from customer_order
group by customer_id
order by no_of_rollId desc;

--How many times roll_id=2 has ordered 
select count(*) from customer_order
where roll_id=2;

--In which roll_id, not included item is not null
select count(roll_id) from customer_order
where not_include_items is not null; --3

--Total orders per day according to order_date
select cast(order_date AS DATE), count(*) as total_order from customer_order
group by CAST(order_date AS DATE)
order by total_order desc;

--On which date most extra items are included
select cast(order_date AS DATE),count(extra_items_included) as more_extra_items_included_date from customer_order
group by cast(order_date AS DATE)
order by more_extra_items_included_date desc  --2021-01-08 

--in which order extra items included and not_included_items both are not present 
select distinct order_id from customer_order
where extra_items_included is null and not_include_items is null

--which customer has done the first order
select top 1 order_id, customer_id from customer_order
order by order_date asc;

--what are the last 3 orders
select top 3 * from customer_order
order by cast(order_date as date) desc;

end














