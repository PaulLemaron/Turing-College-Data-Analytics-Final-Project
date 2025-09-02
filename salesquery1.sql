-- Query 1: Sales Details with Revenue, Cost, and Profit Calculation
-- This query combines sales order details with product information to calculate the revenue, 
-- cost, and profit for each sales order. It also associates sales data with geographic 
-- information, including the province and country.

WITH sales_details AS (
  SELECT
    salesorderid,
    salesorderdetailid,
    orderqty,
    details.productid,
    linetotal,
    product.standardcost,
    ROUND(details.orderqty * product.standardcost, 2) AS cost
  FROM
    tc-da-1.adwentureworks_db.salesorderdetail details
  JOIN
    tc-da-1.adwentureworks_db.product product
    ON product.productid = details.productid
)
SELECT
  sales.*,
  ROUND(SUM(sales_details.linetotal), 2) AS revenue,
  ROUND(SUM(sales_details.cost), 2) AS cost,
  ROUND(SUM(sales_details.linetotal) - SUM(sales_details.cost), 2) AS profit,
  province.stateprovincecode AS ship_province,
  province.CountryRegionCode AS country_code,
  province.name AS country_state_name
FROM
  sales_details
JOIN
  tc-da-1.adwentureworks_db.salesorderheader sales
    ON sales.salesorderid = sales_details.salesorderid
LEFT JOIN
  `tc-da-1.adwentureworks_db.address` AS address
    ON sales.ShipToAddressID = address.AddressID
LEFT JOIN 
  `tc-da-1.adwentureworks_db.stateprovince` AS province
    ON address.stateprovinceid = province.stateprovinceid
GROUP BY
  all
  
-- Query 2: Product Sales and Profit Analysis
-- This query provides a detailed analysis of product performance by calculating the quantity sold, 
-- total cost, revenue, and profit for each product.
--  It also associates products with their respective categories and subcategories.

WITH sold AS (
  SELECT
    details.productid,
    SUM(details.orderqty) qty,
    SUM(details.orderqty * product.standardcost) AS total_cost,
    SUM (details.linetotal) AS revenue
  FROM
    tc-da-1.adwentureworks_db.salesorderdetail details
  JOIN
    tc-da-1.adwentureworks_db.product product
  ON
    product.productid = details.productid
  GROUP BY
    all
)
SELECT
  product.*,
  COUNT(sales.salesorderid) AS orders,
  sold.qty qty,
  ROUND(sold.total_cost, 2) AS cost,
  ROUND(sold.revenue, 2) AS revenue,
  ROUND ((sold.revenue-sold.total_cost),2) AS profit,
  subcategory.name AS subcategory,
  category.name AS category
FROM
  tc-da-1.adwentureworks_db.salesorderdetail details
LEFT JOIN
  tc-da-1.adwentureworks_db.salesorderheader sales
    ON sales.salesorderid = details.salesorderid
LEFT JOIN
  tc-da-1.adwentureworks_db.product product
    ON product.productid = details.productid
LEFT JOIN
  tc-da-1.adwentureworks_db.productsubcategory subcategory
    ON product.productsubcategoryid = subcategory.productsubcategoryid
LEFT JOIN
  tc-da-1.adwentureworks_db.productcategory category
    ON subcategory.productcategoryid = category.productcategoryid
LEFT JOIN
  sold
    ON details.productid = sold.productid
GROUP BY
  all