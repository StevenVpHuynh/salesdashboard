USE datasales;

-- Exploratory Data Analysis (EDA)

-- Tables and their Columns
SELECT * FROM customers; -- Customer ID, Customer Name
SELECT * FROM location; -- Postal Code, City, State, Region, Country/Region
SELECT * FROM orders; -- Row ID, Order ID, Order Date, Ship Date, Ship Mode Customer ID, Segment, Postal Code, Product ID, Sales, Quantity, Discount, Profit
SELECT * FROM products; -- Product ID, Category, Sub-Category, Product Name

-- How many customers, orders, products, and location within these tables?
SELECT 
  (SELECT COUNT(*) FROM Customers) AS total_customers, -- 341 records
  (SELECT COUNT(*) FROM Orders) AS total_orders, -- 9994 records
  (SELECT COUNT(*) FROM Products) AS total_products, -- 1894 records
  (SELECT COUNT(*) FROM Location) AS total_locations; -- 631 records

-- =======================================================================================================================================================================================================================================
-- Questions and Problems to Solve to Support Business Decisions:
-- =======================================================================================================================================================================================================================================

-- Worst performing product/segment category?
SELECT 
    p.category,
    ROUND(SUM(o.sales),2) AS sum_sales
FROM products p
JOIN orders o
    ON p.`Product ID` = o.`Product ID`
GROUP BY p.category
ORDER BY sum_sales DESC;
-- Sales: Technology has the highest sales 893633.28, Furniture has 764284.65, and Office Supplies has 736748.59

SELECT 
    p.category,
    ROUND(SUM(o.profit),2) AS sum_profit
FROM products p
JOIN orders o
    ON p.`Product ID` = o.`Product ID`
GROUP BY p.category
ORDER BY sum_profit DESC;
-- Profit: Technology highest performer with 153,415 in Profit, Office Supplies is 126,113 in Profit, Furniture is 20,098 in Profit

-- Interesting to point out that Office supplies has more profit earned than Furniture, even though Furniture has more sales.
	-- This is a indicator that offices supplies have a higher profit-margin, and it may be ideal to priortize selling more units of products in office supplies rather than furniture.

-- To check this, lets check the profit margin per category through performing aggregation and calculation in Query: profit margin is big indicator in see performance and viability of selling products
SELECT
	p.category,
    ROUND(SUM(o.profit)/SUM(o.sales),2) AS proft_margin
FROM products p
JOIN orders o
	ON p.`Product ID` = o.`Product ID`
GROUP BY p.category
ORDER BY proft_margin DESC;
-- Profit Margin: Office Supplies and Technology = .17 and Furniture .03
-- This confirms that furniture is a poor-performing category and is not as profitable compared to all the other products

-- Now to analyze more in-depth, we will categoryize by Segments as well for the report:
SELECT
    o.Segment,
    p.Category,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN products p
    ON o.`Product ID` = p.`Product ID`
GROUP BY o.Segment, p.Category
ORDER BY o.Segment, profit_margin DESC;


-- Location analysis: how each location is performing profit margin: then identifying weak points
SELECT 
    l.state,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
	ON o.`Postal Code`= l.`Postal Code`
GROUP BY l.state
ORDER BY total_profit DESC
LIMIT 5;
-- Best performing: California, New-York, Washington, Michigan, Virgina With high profits

-- Now to see the worst performing:
SELECT 
    l.state,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
	ON o.`Postal Code`= l.`Postal Code`
GROUP BY l.state
ORDER BY total_profit ASC
LIMIT 5;
-- There is concerning amount of negative profitability: lets dive deeper into this matter

WITH state_profit AS
(
SELECT 
    l.state,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
	ON o.`Postal Code`= l.`Postal Code`
GROUP BY l.state
ORDER BY total_profit ASC
)
SELECT * FROM state_profit
WHERE total_profit < 0
ORDER BY total_profit ASC;

-- There are a total of 9 states where profits are negative! This includes:
-- Texas, Ohio, Pennsylvania, Illinois, North Carolina ,Colorado, Tennessee, Arizona, Florida, Oregon

SELECT 
    l.state,
    o.`Ship Mode`, 
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
    ON o.`Postal Code` = l.`Postal Code`
GROUP BY l.state, o.`Ship Mode`
ORDER BY total_profit ASC;

SELECT 
    `Ship Mode`, 
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / SUM(sales), 2) AS profit_margin
FROM orders
GROUP BY state, `Ship Mode`
ORDER BY profit_margin ASC;

-- What is causing these states to underperform? 

SELECT 
		l.`State`, 
       SUM(o.Profit) AS Total_Loss, 
       COUNT(*) AS Order_Count,
       AVG(o.Profit) AS Avg_Loss_Per_Order,
       AVG(o.Discount) AS Avg_Discount
FROM orders o
JOIN location l 
ON o.`Postal Code` = l.`Postal Code`
WHERE o.Profit < 0;


SELECT l.`State`, 
		SUM(o.quantity),
       SUM(o.Profit) AS Total_Profit, 
       AVG(o.Discount) AS Avg_Discount
FROM orders o
JOIN location l ON o.`Postal Code` = l.`Postal Code`
WHERE o.Profit >= 0
GROUP BY l.`State`
ORDER BY Total_Profit DESC
LIMIT 10;








