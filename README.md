SQL Data Analysis Report — Roll Orders Dataset

Tools Used: SQL Server, SQL Queries

Dataset Components:
- Customer Orders (`customer_order`)
- Rolls (`rolls`)
- Roll Recipes (`rolls_recipes`)
- Ingredients (`ingredients`)
- Drivers (`drivers`)

Objective
To extract meaningful insights from roll-based order data using SQL queries in SQL Server. The analysis includes:
- Ingredient usage
- Roll popularity
- Customer behavior
- Delivery patterns
- Recipe compositions

✅EASY LEVEL
1. List all rolls with their ingredients (names, not IDs).
2. Get the total number of ingredients used in each roll.
3. Show each roll’s name with the number of ingredients used.
4. List all drivers and their registration dates.
5. Which ingredients are used in both rolls?
6. Which ingredients are used only in Veg Roll?

⚡️INTERMEDIATE LEVEL
1. Find which rolls include “Mushrooms” as an ingredient.
2. Get a list of ingredients that are used in more than one roll.
3. Show all orders along with the roll name and the ingredients included (expanded).
4. Which rolls include more than 5 ingredients?
5. For each roll, show the count of veg and non-veg ingredients (assume: id 1–6 are non-veg, rest veg).
6. Get a list of all unique ingredients ever ordered (based on customer_order > roll > ingredients).
7. Which ingredients have never been used in any roll?

🔥 HARD LEVEL 
1. Which ingredient has been included in the highest number of customer orders?
2. Rank ingredients by frequency of appearance in orders (most used first).
3. Which customer has ordered the roll that contains the maximum number of ingredients the most number of times?
4. Get the top 3 most frequently used ingredients across all orders.
5. For each driver, assume delivery started on their registration date — how many orders were placed after they registered (assuming delivery system)?
6. Build a report: Roll name | Ingredients count | Ingredients list (comma separated).
7. Get a date-wise trend of total ingredients used (by flattening orders → rolls → ingredients).

😎 Real-world type:
1. Suggest a “most popular ingredients combo” used across orders.
2. If you had to remove one ingredient (used least), which would it be?
3. Which roll would be affected the most if "Cheese" is removed from the recipe?

Conclusion
This SQL-based analysis provides a comprehensive view of how ingredients, rolls, and customer behavior interact in a food delivery system. 
Insights like popular items, usage trends, and delivery efficiency can drive business decisions.
