/*
Task 2. Find the total number of customers who went through 
	checkout
Goal: goal in this section is to construct a query that gives you 
	the number of unique visitors who successfully went through 
    the checkout process for your website.
    
    
    The following returns results, but are you sure visitors 
    aren't counted twice. 
    Also, returning only one row answers the question of how 
    many unique visitors reached checkout. 
    In the next section you find a way to aggregate your results.
*/

/* #standardSQL
SELECT
	fullVisitorId,
	hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions` 
LIMIT 1000;
*/

/* 
An aggregation function, COUNT(), was added, but it is 
missing a GROUP BY clause
*/

/* 
#standardSQL
SELECT
	COUNT(fullVisitorId) AS visitor_count,
	hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`;
*/

/* 
GROUP BY statements, and wildcard filters 
In this next query, GROUP BY and DISTINCT statements 
were added. The results are good, but they look strange.
*/

/*
SELECT
	COUNT(DISTINCT fullVisitorId) AS visitor_count,
	hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY hits_page_pageTitle;
*/

/* 
Filter to just "Checkout Confirmation" in the results
*/

/* 
#standardSQL
SELECT
	COUNT(DISTINCT fullVisitorId) AS visitor_count,
	hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_page_pageTitle = "Checkout Confirmation"
GROUP BY hits_page_pageTitle;
*/

/* Task 3. List the cities with the most transactions 
with your ecommerce site to order the top cities first.
*/

/*
SELECT
	geoNetwork_city,
	SUM(totals_transactions) AS totals_transactions,
	COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city;
*/

/* 
Update your previous query to order the top cities first.
*/

/* 
#standardSQL
SELECT
	geoNetwork_city,
	SUM(totals_transactions) AS totals_transactions,
	COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
ORDER BY distinct_visitors DESC;
*/


/* 
Update the query and create a new calculated field to return
the average number of products per order by city.
*/

/*#standardSQL
SELECT
	geoNetwork_city,
	SUM(totals_transactions) AS total_products_ordered,
	COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
	SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId)
    AS avg_products_ordered
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
ORDER BY avg_products_ordered DESC;
*/

/* 
Filter your aggregated results to only return cities with more than
20 avg_products_ordered.

1- Note that you cannot filter on aliased fields within the `WHERE` clause 
2- You cannot filter aggregated fields in the `WHERE` clause (use `HAVING` instead)
*/

/*
# This is wrong according to not considering the above mentioned notes.
#standardSQL
SELECT
	geoNetwork_city,
	SUM(totals_transactions) AS total_products_ordered,
	COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
	SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) 
    AS avg_products_ordered
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE avg_products_ordered > 20
GROUP BY geoNetwork_city
ORDER BY avg_products_ordered DESC;
*/

/*
# Possible Solution
#standardSQL
SELECT
	geoNetwork_city,
	SUM(totals_transactions) AS total_products_ordered,
	COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
	SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) 
    AS avg_products_ordered
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
HAVING avg_products_ordered > 20
ORDER BY avg_products_ordered DESC;
*/

/*
Task 4. Find the total number of products in each product category
Goal: Find the top selling products by filtering with NULL values
*/

/* This query is incorrect, because:
1- Large GROUP BYs really hurt performance 
(consider filtering first and/or using aggregation functions)
2- No aggregate functions are used
*/

/*
#standardSQL
SELECT 
	hits_product_v2ProductName, 
	hits_product_v2ProductCategory
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY 1,2;
*/

/*
The following query is not correct, because:
the COUNT() function is not the distinct number of products
in each category
*/

/*
#standardSQL
SELECT
	COUNT(hits_product_v2ProductName) as number_of_products,
	hits_product_v2ProductCategory
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC;
*/

/*
Update the previous query to only count distinct products in 
each product category.


Note that 
1- (not set) could indicate the product has no category
2- ${productitem.product.origCatName} is front-end code to 
render the category which may indicate the Google Analytics
tracking script is firing before the page is fully-rendered
*/

#standardSQL
SELECT
	COUNT(DISTINCT hits_product_v2ProductName) as number_of_products,
	hits_product_v2ProductCategory
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC
LIMIT 5;
