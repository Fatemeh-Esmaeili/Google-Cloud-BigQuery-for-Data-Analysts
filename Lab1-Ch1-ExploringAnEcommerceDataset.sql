/* Challenge 1: Calculate a conversion rate

Write a conversion rate query for products with these qualities:
More than 1000 units were added to a cart or ordered
AND are not frisbees
Answer these questions:
How many distinct times was the product part of an order (either complete or incomplete order)?
How many total units of the product were part of orders (either complete or incomplete)?
Which product had the highest conversion rate?
*/


#standardSQL
SELECT
  COUNT(*) AS product_views,
  COUNT(productQuantity) AS potential_orders,
  SUM(productQuantity) AS quantity_product_added,
  (COUNT(productQuantity) / COUNT(*)) AS conversion_rate,
  v2ProductName
FROM `data-to-insights.ecommerce.all_sessions`
WHERE LOWER(v2ProductName) NOT LIKE '%frisbee%'
GROUP BY v2ProductName
HAVING quantity_product_added > 1000
ORDER BY conversion_rate DESC
LIMIT 10;
