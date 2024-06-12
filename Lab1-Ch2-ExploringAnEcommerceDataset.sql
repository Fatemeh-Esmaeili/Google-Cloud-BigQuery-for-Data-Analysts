/*
Challenge 2: Track visitor checkout progress
Write a query that shows the eCommerceAction_type and the distinct count of fullVisitorId associated with each type.


*/

#standardSQL 1
SELECT
  COUNT(DISTINCT fullVisitorId) AS number_of_unique_visitors,
  eCommerceAction_type
FROM `data-to-insights.ecommerce.all_sessions`
GROUP BY eCommerceAction_type
ORDER BY eCommerceAction_type;
