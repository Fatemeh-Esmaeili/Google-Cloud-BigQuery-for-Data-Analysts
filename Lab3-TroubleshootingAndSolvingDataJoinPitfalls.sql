/* 
Task 4. Identify a key field in your ecommerce dataset

Examine the records
In this section you find how many product names and product
SKUs are on your website and whether either one of those 
fields is unique.

Find how many product names and product SKUs are on the website. 
*/

/*
#standardSQL
# how many products are on the website?
SELECT DISTINCT
  productSKU,
  v2ProductName
FROM `data-to-insights.ecommerce.all_sessions_raw`;
*/


/*
Related to the above query! 
But...do the results mean that there are that many unique 
product SKUs? One of the first queries you will run as a 
data analyst is looking at the uniqueness of your data values.
*/


/*
Clear the previous query and list 
the number of distinct SKUs are listed 
using DISTINCT:
*/


/*
#standardSQL
# find the count of unique SKUs
SELECT DISTINCT
  productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`;
*/


/*
There are fewer DISTINCT SKUs than the SKU & Product 
Name query had before. Why do you think that is?
he first query also returned Product Name. 
It appears multiple Product Names can have the same SKU.
*/


/*
Examine the relationship between SKU & Name

Now determine which products have more than one
SKU and which SKUs have more than one Product Name.

The use of the STRING_AGG() function to aggregate
all the product SKUs that are associated with one 
product name into comma separated values.
*/


/*
SELECT
  v2ProductName,
  COUNT(DISTINCT productSKU) AS SKU_count,
  STRING_AGG(DISTINCT productSKU LIMIT 5) AS SKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
  WHERE productSKU IS NOT NULL
  GROUP BY v2ProductName
  HAVING SKU_count > 1
  ORDER BY SKU_count DESC;
*/


/*
So you have seen that 1 Product can have 12 SKUs. 
What about 1 SKU? Should it be allowed to belong 
to more than 1 product?
*/

/*
SELECT
  productSKU,
  COUNT(DISTINCT v2ProductName) AS product_count,
  STRING_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name
FROM `data-to-insights.ecommerce.all_sessions_raw`
  WHERE v2ProductName IS NOT NULL
  GROUP BY productSKU
  HAVING product_count > 1
  ORDER BY product_count DESC
*/



/*
Try replacing STRING_AGG() with ARRAY_AGG() instead. Pretty cool, right?
*/



/*
SELECT
  productSKU,
  COUNT(DISTINCT v2ProductName) AS product_count,
  ARRAY_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name
FROM `data-to-insights.ecommerce.all_sessions_raw`
  WHERE v2ProductName IS NOT NULL
  GROUP BY productSKU
  HAVING product_count > 1
  ORDER BY product_count DESC
*/



/*
Task 5. Pitfall: non-unique key

In inventory tracking, a SKU is designed to uniquely identify 
one and only one product. For us, it will be the basis of your 
JOIN condition when you lookup information from other tables. 
Having a non-unique key can cause serious data issues as you will see.

Write a query to identify all the product names for the SKU 'GGOEGPJC019099'

The results are mostly the same except for a few characters.
From the query results, it looks like there are three different 
names for the same product. In this example, there is a special 
character in one name and a slightly different name for another
*/


/*
SELECT DISTINCT
  v2ProductName,
  productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE productSKU = 'GGOEGPJC019099'
*/

/*
Joining website data against your product inventory list

Now see the impact of joining on a dataset with multiple products 
for a single SKU. First explore the product inventory dataset 
(the products table) to see if this SKU is unique there.



- Is the SKU unique in the product inventory dataset?
Yes, just one record is returned.

- How many dog frisbees do you have in inventory? 154
*/

/*
SELECT
  SKU,
  name,
  stockLevel
FROM `data-to-insights.ecommerce.products`
WHERE SKU = 'GGOEGPJC019099';
*/


/*
Join pitfall: Unintentional many-to-one SKU relationship

You now have two datasets: one for inventory stock level and the other for our website analytics. JOIN the inventory dataset against your website product names and SKUs so you can have the inventory stock level associated with each product for sale on the website.


  Q: What happens when you join the website table and the product inventory table on SKU? Do you now have inventory stock levels for the product?

  A: Yes, there are inventory levels but the stockLevel is showing three times (one for each record).
*/

/*
SELECT DISTINCT
  website.v2ProductName,
  website.productSKU,
  inventory.stockLevel
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
  ON website.productSKU = inventory.SKU
  WHERE productSKU = 'GGOEGPJC019099';
*/

/*
Next, expand our previous query to simply SUM the inventory available by product.

  Q: Is the dog Frisbee properly showing a stock level of 154?
  A: No, it is now at 462 showing three times (one for each record!)
*/

/*
WITH inventory_per_sku AS (
  SELECT DISTINCT
    website.v2ProductName,
    website.productSKU,
    inventory.stockLevel
  FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
  JOIN `data-to-insights.ecommerce.products` AS inventory
    ON website.productSKU = inventory.SKU
    WHERE productSKU = 'GGOEGPJC019099'
)

SELECT
  productSKU,
  SUM(stockLevel) AS total_inventory
FROM inventory_per_sku
GROUP BY productSKU
*/

/*
Task 6. Join pitfall solution: use distinct SKUs before joining
What are the options to solve your triple counting dilemma? First you need to only select distinct SKUs from the website before joining on other datasets.


Gather all the possible names into an array

So, instead of having a row for every Product Name, you only have a row for each unique SKU.
*/



/*
SELECT
  productSKU,
  ARRAY_AGG(DISTINCT v2ProductName) AS push_all_names_into_array
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE productSKU = 'GGOEGAAX0098'
GROUP BY productSKU
*/

/*
If you wanted to deduplicate the product names, you could even LIMIT the array like so:
*/

/*
SELECT
  productSKU,
  ARRAY_AGG(DISTINCT v2ProductName LIMIT 1) AS push_all_names_into_array
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE productSKU = 'GGOEGAAX0098'
GROUP BY productSKU
*/

/*
Join pitfall: losing data records after a join

Now you're ready to join against your product inventory dataset again.

  Q: How many records were returned? All 1,909 distinct SKUs?
  A: No, just 1,090 records 
  It seems 819 SKUs were lost after joining the datasets Investigate by adding more specificity in your fields (one SKU column from each dataset):
*/

/*
#standardSQL
SELECT DISTINCT
  website.productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
*/


/*
#standardSQL
# pull ID fields from both tables
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
# IDs are present in both tables, how can you dig deeper?
*/

/*
Join pitfall solution: selecting the correct join type and filtering for NULL

The default JOIN type is an INNER JOIN which returns records only if there is a SKU match on both the left and the right tables that are joined.

  1- Rewrite the previous query to use a different join type to include all records from the website table, regardless of whether there is a match on a product inventory SKU record. 


 Q: True or False: Many inventory SKU values are NULL.True
*/







/*
#standardSQL
# the secret is in the JOIN type
# pull ID fields from both tables
SELECT DISTINCT
  website.productSKU AS website_SKU,
  inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
LEFT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
*/


/*
Q: How many SKUs are missing from your product inventory set?

Write a query to filter on NULL values from the inventory table.


Question: How many products are missing?

Answer: 819 products are missing (SKU IS NULL) from your product inventory dataset.
*/


/*
#standardSQL
# find product SKUs in website table but not in product inventory table
SELECT DISTINCT
  website.productSKU AS website_SKU,
  inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
LEFT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE inventory.SKU IS NULL

*/


/*
run the below query to confirm using one of the specific SKUs from the website dataset:

Q: Why might the product inventory dataset be missing SKUs?
A: Some SKUs could be digital products that you do not store in warehouse inventory
*/

/*
#standardSQL
# you can even pick one and confirm
SELECT * FROM `data-to-insights.ecommerce.products`
WHERE SKU = 'GGOEGATJ060517'
# query returns zero results
*/

/*
Now, what about the reverse situation? Are there any products in the product inventory dataset but missing from the website?

Write a query using a different join type to investigate.

Answer: Yes. There are two product SKUs missing from the website dataset
*/


/*
#standardSQL
# reverse the join
# find records in website but not in inventory
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
RIGHT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL
*/



/*
Next, add more fields from the product inventory dataset for more details.

Why would the below products be missing from the ecommerce website dataset?

Possible answers:

One new product (no orders, no sentimentScore) and one product that is "in store only"
Another is a new product with 0 orders
Why would the new product not show up on your website dataset?

The website dataset is past order transactions by customers brand new products which have never been sold won't show up in web analytics until they're viewed or purchased.
Note: You typically will not see RIGHT JOINs in production queries. You would simply just do a LEFT JOIN and switch the ordering of the tables.
*/


/*
#standardSQL
# what are these products?
# add more fields in the SELECT STATEMENT
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.*
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
RIGHT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL
*/


/*
What if you wanted one query that listed all products missing from either the website or inventory?

Write a query using a different join type.
Possible solution:


You have your 819 + 2 = 821 product SKUs.

LEFT JOIN + RIGHT JOIN = FULL JOIN which returns all records from both tables regardless of matching join keys. You then filter out where you have mismatches on either side
*/

/*
#standardSQL
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
FULL JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL OR inventory.SKU IS NULL
*/ 


/
/*
Join pitfall: unintentional cross join
Not knowing the relationship between data table keys (1:1, 1:N, N:N) can return unexpected results and also significantly reduce query performance.

The last join type is the CROSS JOIN.

Create a new table with a site-wide discount percent that you want applied across products in the Clearance category.

*/

/*
#standardSQL
CREATE OR REPLACE TABLE ecommerce.site_wide_promotion AS
SELECT .05 AS discount;
*/

/*
In the left pane, site_wide_promotion is now listed in the Resource section under your project and dataset.

Clear the previous query and run the below query to find out how many products are in clearance: 82


Note: For a CROSS JOIN you will notice there is no join condition (e.g. ON or USING). The field is simply multiplied against the first dataset or .05 discount across all items.
*/


/*
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
*/

/*
See the impact of unintentionally adding more than one record in the discount table.

*/


/*
INSERT INTO ecommerce.site_wide_promotion (discount)
VALUES (.04),
       (.03);
*/

/*
Next, view the data values in the promotion table.
How many records were returned?

Answer: 3 by Runnig the below query
*/

/*
SELECT discount FROM ecommerce.site_wide_promotion
*/

/*
What happens when you apply the discount again across all 82 clearance products?


How many products are returned?

Answer: Instead of 82, you now have 246 returned which is more records than your original table started with.

*/

/*
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
*/

/*
Now investigate the underlying cause by examining one product SKU.

What was the impact of the CROSS JOIN?

Answer: Since there are 3 discount codes to cross join on, you are multiplying the original dataset by 3.

Note: This behavior isn't limited to cross joins, with a normal join you can unintentionally cross join when the data relationships are many-to-many this can easily result in returning millions or even billions of records unintentionally.
*/

#standardSQL
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'
AND productSKU = 'GGOEGOLC013299'

