USE [Faasos]
GO
/****** Object:  StoredProcedure [dbo].[Faasos_analysis_more]    Script Date: 25-05-2025 15:53:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[Faasos_analysis_more]
as
begin

--List all rolls with their ingredients (names, not IDs).

Select r.Rolls_Name, ig.Ingredients_name from Rolls_Recipes as rs
inner join Rolls as r on r.Rolls_id=rs.Roll_id
Cross Apply 
string_split(rs.Ingredients,',') as i
inner join Ingredients as ig on  ig.Ingredients_id=cast(i.value as int)
Order by Rolls_Name

--Get the total number of ingredients used in each roll.
Select r.Rolls_Name,count(i.value) as no_of_ingredients from Rolls_Recipes rs
inner join Rolls r on r.Rolls_id=rs.Roll_id
Cross Apply
string_split(rs.Ingredients,',') as i
Group by Rolls_Name

--Which ingredients are used in both rolls?
Select i.Ingredients_name from Ingredients as i
where i.Ingredients_id in(
			select value from Rolls_Recipes rr
			cross apply string_split(Ingredients,',') 
			where Roll_id=1
Intersect 
Select value from Rolls_Recipes
Cross apply string_split(Ingredients,',')
where Roll_id=2
);

--Which ingredients are used only in Veg Roll?
Select i.Ingredients_name from Ingredients i
where Ingredients_name='Mushroom' AND Ingredients_id in (
Select value from Rolls_Recipes
cross apply string_split(Ingredients,',')
where Roll_id=2
);
--Find which rolls include “Mushrooms” as an ingredient.
SELECT r.Rolls_name, i.Ingredients_name
FROM Rolls r
INNER JOIN Rolls_recepie rr ON rr.Rolls_id = r.Roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS sr
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(sr.value AS INT)
WHERE i.Ingredients_name = 'Mushrooms';

--Get a list of ingredients that are used in more than one roll.
Select i.Ingredients_name from Ingredients i where i.Ingredients_id in(select value from(select rr.Roll_id,
cast(value as int)as value from Rolls_Recipes rr
cross apply string_split(rr.Ingredients,','))as sub
Group by value
having count(distinct roll_id)>1);

--Show all orders along with the roll name and the ingredients included (expanded).
SELECT 
    cr.order_id,
    cr.customer_id,
    cr.roll_id,
    rr.Rolls_Name AS Roll_Name,
    i.Ingredients_name AS Ingredient
FROM customer_order AS cr
INNER JOIN Rolls_Recipes r ON r.Roll_id = cr.roll_id
CROSS APPLY STRING_SPLIT(r.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
INNER JOIN Rolls rr ON rr.Rolls_id = r.Roll_id
ORDER BY cr.order_id;

--Which rolls include more than 5 ingredients?
SELECT 
    r.Rolls_Name,
    COUNT(i.Ingredients_name) AS Total_Ingredients
FROM Rolls r
INNER JOIN Rolls_Recipes rr ON r.Rolls_id = rr.Roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY r.Rolls_Name
HAVING COUNT(i.Ingredients_name) > 5;

--For each roll, show the count of veg and non-veg ingredients.
--Assumption: Ingredients with Ingredients_id 1–6 are Non-Veg, and 7–12 are Veg.
SELECT 
    r.Rolls_Name,
    SUM(CASE WHEN i.Ingredients_id BETWEEN 1 AND 6 THEN 1 ELSE 0 END) AS Non_Veg_Count,
    SUM(CASE WHEN i.Ingredients_id BETWEEN 7 AND 12 THEN 1 ELSE 0 END) AS Veg_Count
FROM Rolls r
INNER JOIN Rolls_Recipes rr ON r.Rolls_id = rr.Roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY r.Rolls_Name;

--Which ingredients have never been used in any roll?
SELECT Ingredients_name 
FROM Ingredients 
WHERE Ingredients_id NOT IN (
    SELECT DISTINCT CAST(value AS INT)
    FROM Rolls_Recipes
    CROSS APPLY STRING_SPLIT(Ingredients, ',')
);

--Which ingredient has been included in the highest number of customer orders?
SELECT TOP 1 
    i.Ingredients_name,
    COUNT(DISTINCT cr.order_id) AS total_orders
FROM customer_order AS cr
INNER JOIN Rolls_Recipes r ON r.Roll_id = cr.roll_id
CROSS APPLY STRING_SPLIT(r.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY i.Ingredients_name
ORDER BY total_orders DESC;


--Rank ingredients by frequency of appearance in orders (most used first).
SELECT 
    i.Ingredients_name,
    COUNT(DISTINCT cr.order_id) AS total_orders,
    RANK() OVER (ORDER BY COUNT(DISTINCT cr.order_id) DESC) AS ingredient_rank
FROM customer_order AS cr
INNER JOIN Rolls_Recipes r ON r.Roll_id = cr.roll_id
CROSS APPLY STRING_SPLIT(r.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY i.Ingredients_name
ORDER BY ingredient_rank;

--Which customer has ordered the roll that contains the maximum number of ingredients the most number of times?
WITH MaxIngredientRoll AS (
    SELECT TOP 1 Roll_id
    FROM Rolls_Recipes
    CROSS APPLY STRING_SPLIT(Ingredients, ',')
    GROUP BY Roll_id
    ORDER BY COUNT(*) DESC
),
CustomerOrderCounts AS (
    SELECT customer_id, COUNT(*) AS order_count
    FROM customer_order
    WHERE roll_id = (SELECT Roll_id FROM MaxIngredientRoll)
    GROUP BY customer_id
)
SELECT TOP 1 customer_id, order_count
FROM CustomerOrderCounts
ORDER BY order_count DESC

--Get the top 3 most frequently used ingredients across all orders.
SELECT TOP 3 
    i.Ingredients_name, 
    COUNT(*) AS frequency
FROM customer_order c
INNER JOIN Rolls_Recipes rr ON c.roll_id = rr.Roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY i.Ingredients_name
ORDER BY frequency DESC;


--Date-wise Trend of Total Ingredients Used
SELECT 
    CAST(c.order_date AS DATE) AS Order_Date,
    COUNT(s.value) AS Total_Ingredients_Used
FROM customer_order c
INNER JOIN Rolls_Recipes rr ON rr.Roll_id = c.roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
GROUP BY CAST(c.order_date AS DATE)
ORDER BY Order_Date;

--For Each Driver: How Many Orders Were Placed After They Registered
select d.Reg_date,d.driver_id,count(c.order_id) AS orders_after_registeration from driver d
left join customer_order c on
c.order_date>d.Reg_date
Group by d.Reg_date,d.driver_id

--Report: Roll Name | Ingredients Count | Ingredients List (comma-separated)
SELECT 
    r.Rolls_Name,
    COUNT(s.value) AS Ingredient_Count,
    STRING_AGG(i.Ingredients_name, ', ') AS Ingredient_List
FROM Rolls r
INNER JOIN Rolls_Recipes rr ON r.Rolls_id = rr.Roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY r.Rolls_Name;

--Suggest a “most popular ingredients combo” used across orders
SELECT top 1
    rr.Ingredients,
    COUNT(*) AS combo_frequency
FROM customer_order c
INNER JOIN Rolls_Recipes rr ON c.roll_id = rr.Roll_id
GROUP BY rr.Ingredients
ORDER BY combo_frequency DESC

--If you had to remove one ingredient (used least), which would it be?
SELECT TOP 1 
    i.Ingredients_name,
    COUNT(*) AS usage_count
FROM customer_order c
INNER JOIN Rolls_Recipes rr ON c.roll_id = rr.Roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
INNER JOIN Ingredients i ON i.Ingredients_id = CAST(s.value AS INT)
GROUP BY i.Ingredients_name
ORDER BY usage_count ASC;


--Which roll would be affected the most if "Cheese" is removed from the recipe?

-- Step 1: Get the ID of "Cheese"
-- Assume Cheese = ID 4 (from your Ingredients table) then use order by in descending order and select top 1

SELECT TOP 1 
    r.Rolls_Name,
    COUNT(*) AS order_count_with_cheese
FROM customer_order c
INNER JOIN Rolls_Recipes rr ON rr.Roll_id = c.roll_id
CROSS APPLY STRING_SPLIT(rr.Ingredients, ',') AS s
INNER JOIN Rolls r ON r.Rolls_id = rr.Roll_id
WHERE CAST(s.value AS INT) = 4  -- 4 = Cheese
GROUP BY r.Rolls_Name
ORDER BY order_count_with_cheese DESC;


end