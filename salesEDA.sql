-- =======================================================================================================================================================================================================================================
-- Exploratory Data Analysis (EDA)
-- =======================================================================================================================================================================================================================================
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
-- Interesting to point out that Office supplies has more profit earned than Furniture, even though Furniture has more sales. This is a indicator that offices supplies have a higher profit-margin, and it may be ideal to priortize selling more units of products in office supplies rather than furniture.

-- Profit margin is big indicator in see performance and viability of selling products:
SELECT
	p.category,
    ROUND(SUM(o.profit)/SUM(o.sales),2) AS proft_margin
FROM products p
JOIN orders o
	ON p.`Product ID` = o.`Product ID`
GROUP BY p.category
ORDER BY proft_margin DESC;
-- Profit Margin: Office Supplies and Technology = .17 and Furniture .03: This confirms that furniture is a poor-performing category and is not as profitable compared to all the other products

WITH category_segment AS
(
SELECT
	o.segment,
    p.category,
    ROUND(SUM(o.profit)/SUM(o.sales),2) AS profit_margin
FROM orders o
JOIN products p
	ON p.`Product ID` = o.`Product ID`
GROUP BY o.segment, p.category
)
SELECT 
  segment,
  category,
  profit_margin
FROM category_segment
ORDER BY segment, profit_margin DESC;


-- Now to analyze more in-depth, we will categorize by Segments as well for the report:
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
WHERE total_profit < 0;


SELECT 
    l.state,
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
	ON o.`Postal Code`= l.`Postal Code`
GROUP BY l.state

ORDER BY total_profit ASC;

-- There is concerning amount of negative: lets dive deeper into this matter and see why there is difference between performance
-- There are a total of 9 states where profits are negative! This includes: Texas, Ohio, Pennsylvania, Illinois, North Carolina ,Colorado, Tennessee, Arizona, Florida, Oregon

-- Checking to see if Ship Mode has any effect on the sales

SELECT 
    l.state,
    o.`Ship Mode`, 
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
    ON o.`Postal Code` = l.`Postal Code`
WHERE state = 'Texas'
GROUP BY l.state, o.`Ship Mode`
ORDER BY state ASC;

-- Comparing poor performing states' ship mode to best performing states: 
SELECT 
    l.state,
    o.`Ship Mode`, 
    ROUND(SUM(o.sales), 2) AS total_sales,
    ROUND(SUM(o.profit), 2) AS total_profit,
    ROUND(SUM(o.profit) / SUM(o.sales), 2) AS profit_margin
FROM orders o
JOIN location l 
    ON o.`Postal Code` = l.`Postal Code`
WHERE state = 'California'
GROUP BY l.state, o.`Ship Mode`
ORDER BY state ASC;
-- There doesn't seem to have a lot of connection between ship mode and performance. As a e-commerce business, they should see if there shipping costs has changed.

-- What is causing these states to underperform? Could it be the amount of discount rates?

WITH negative_profit_discount AS
(
SELECT 	
	l.State,
	ROUND(SUM(o.Profit),2) AS total_profit,
    ROUND(AVG(o.Profit),2) AS Avg_Profit_Per_Order,
    ROUND(AVG(o.Discount),2) AS Avg_Discount_Per_Order
FROM orders o
JOIN location l
    ON o.`Postal Code` = l.`Postal Code`
GROUP BY l.State
)
SELECT 
	AVG(total_profit),
    AVG(Avg_discount_per_order)
FROM negative_profit_discount
WHERE total_profit < 0;


-- There seems to be an issue as there could be connection between excessive discounting and profit loss. Lets check with high performers

WITH profit_discount AS
(
SELECT 	
	l.State,
	ROUND(SUM(o.Profit),2) AS total_profit,
    ROUND(AVG(o.Profit),2) AS Avg_Profit_Per_Order,
    ROUND(AVG(o.Discount),2) AS Avg_Discount_Per_Order
FROM orders o
JOIN location l
    ON o.`Postal Code` = l.`Postal Code`
GROUP BY l.State
ORDER BY total_profit DESC
)
SELECT
	AVG(total_profit),
	AVG(Avg_discount_per_order)
FROM profit_discount
WHERE total_profit > 0;

-- Profitable states seem to have a discount rate between 0 to 10%, and it shows that excessive discount rates are the main driving factor to lower profits



