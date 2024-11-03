SELECT * FROM gdb023.dim_product AS dim_product;
SELECT * FROM gdb023.dim_customer AS dim_cutomer;
SELECT * FROM gdb023.fact_manufacturing_cost AS manufacturing_cost;
SELECT * FROM gdb023.fact_sales_monthly AS monthly_sales;
SELECT * FROM gdb023.fact_gross_price AS gross_price;
SELECT * FROM gdb023.fact_pre_invoice_deductions AS invoice_deduction;

#Request1 - Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
SELECT market as List_of_markets
FROM gdb023.dim_customer as customer
WHERE customer = 'Atliq Exclusive' AND region = 'APAC';

#Request2 - What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields, unique_products_2020 unique_products_2021 percentage_chg
#Provide the final output with percentage change calculation
SELECT *, ROUND(((unique_products_2021 - unique_products_2020)/unique_products_2020)*100, 2) AS percentage_chg  
FROM
(
	SELECT 
	# To convert the calculated table data into the desired table data(previous table will return unique product count for 2020 and 2021 in two rows but we want that in two columns)
		SUM(CASE 
		WHEN fiscal_year = '2020' THEN total_unique_products
		END) AS unique_products_2020,
		SUM(CASE 
		WHEN fiscal_year = '2021' THEN total_unique_products
		END) AS unique_products_2021
	FROM
    #Return the count of unique product for fiscal year 2020 and 2021
		(SELECT fiscal_year, COUNT(DISTINCT(product_code)) as total_unique_products
		FROM  gdb023.fact_sales_monthly
		WHERE fiscal_year IN('2020', '2021')
		GROUP BY fiscal_year) as calculated_table) as final_table; 

#Request3: Provide a report with all the unique product counts for each segment and sort them in descending order of product counts.
#The final output contains 2 fields, segment product_count
SELECT segment, COUNT(DISTINCT product) AS product_count
FROM gdb023.dim_product as product
GROUP BY segment;

#############################################################################################################################################

#Request 4: Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields, segment product_count_2020 product_count_2021 differe

 WITH cte4 AS(SELECT p.segment,COUNT(DISTINCT p.product_code) AS product_count_2020 FROM dim_product p
      INNER JOIN fact_sales_monthly s ON p.product_code=s.product_code WHERE fiscal_year=2020 
      GROUP BY segment ORDER BY product_count_2020 DESC ),
  cte5 AS(SELECT p.segment,COUNT(DISTINCT p.product_code) AS product_count_2021 FROM dim_product p
  INNER JOIN fact_sales_monthly s ON p.product_code=s.product_code WHERE fiscal_year=2021 GROUP BY segment
  ORDER BY product_count_2021 DESC )
 SELECT cte4.segment,product_count_2020,product_count_2021,(product_count_2021-product_count_2020)
 AS Difference FROM cte4 INNER JOIN cte5 ON cte4.segment=cte5.segment ORDER BY Difference DESC;

##USING CASE
SELECT 
    dp.segment,
    COUNT(DISTINCT CASE WHEN fs.fiscal_year = 2020 THEN dp.product_code END) AS product_count_2020,
    COUNT(DISTINCT CASE WHEN fs.fiscal_year = 2021 THEN dp.product_code END) AS product_count_2021,
    (COUNT(DISTINCT CASE WHEN fs.fiscal_year = 2021 THEN dp.product_code END) - 
     COUNT(DISTINCT CASE WHEN fs.fiscal_year = 2020 THEN dp.product_code END)) AS difference
FROM 
    dim_product dp
JOIN 
    fact_sales_monthly fs ON dp.product_code = fs.product_code
GROUP BY 
    dp.segment
ORDER BY 
    difference DESC;


#############################################################################################################################################
#Request 5: Get the products that have the highest and lowest manufacturing costs. 
#	The final output should contain these fields, product_code product manufacturing_cost.

SELECT 
    fmc.product_code,
    dp.product,
    fmc.manufacturing_cost
FROM 
    fact_manufacturing_cost fmc
JOIN 
    dim_product dp ON fmc.product_code = dp.product_code
WHERE 
    fmc.manufacturing_cost = (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost)
    OR
    fmc.manufacturing_cost = (SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost);

#################################################################################################################################
#Request 6: Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market.
#The final output contains these fields, customer_code customer average_discount_percentage

#USING SUBQUERIES
SELECT  customer_code, customer, ROUND(AVG(pre_invoice_discount_pct*100), 2) AS average_discount_percentage
FROM
(
SELECT *
FROM gdb023.dim_customer as dim_customer
INNER JOIN gdb023.fact_pre_invoice_deductions as pre_invoice_deductions
USING(customer_code)
WHERE fiscal_year = '2021' and market = 'India'
) as joint_table
GROUP BY customer, customer_code
ORDER BY average_discount_percentage DESC
LIMIT 5;

#USING CTE
WITH cte13 AS
(WITH cte6 AS
(SELECT C.customer_code,C.customer,D.pre_invoice_discount_pct 
FROM dim_customer C 
INNER JOIN fact_pre_invoice_deductions D 
ON C.customer_code=D.customer_code 
WHERE C.market="India" AND D.fiscal_year=2021) 
SELECT cte6.*,(SELECT avg(pre_invoice_discount_pct) FROM cte6) AS average_value 
FROM cte6) 
SELECT customer_code,customer,ROUND(pre_invoice_discount_pct*100,2) AS average_discount_pct 
FROM cte13 
WHERE pre_invoice_discount_pct >average_value 
ORDER BY average_discount_pct DESC 
LIMIT 5 ;

#####################################################################################################################################
#Request 7
#Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month .
# This analysis helps to get an idea of low and high-performing months and take strategic decisions. 
# The final report contains these columns: Month Year Gross sales Amount

#Final
SELECT Month, Year, ROUND(SUM(gross_sales_peritem_monthwise)) AS "Gross Sales Amount"
FROM
	(# Joins peritem_totalsales_monthwise and gross price table to get the gross price of individual item for individual fiscal year
     # calculate the gross sales per product per month
    SELECT peritem_totalsales_monthwise.product_code, date, Month, Year(date) AS Year,gross_price, peritem_totalsales_monthwise.fiscal_year, total_sold_quantity_monthwise, (total_sold_quantity_monthwise*gross_price) AS gross_sales_peritem_monthwise
	FROM
		(#Combines data fact_sales_monthly and dim_customer table and presents on data for Atliq Exclusive customer 
		 #Total sold quantity per product per month from joined table
        SELECT product_code, date, Month(date) AS Month, fiscal_year, SUM(sold_quantity) AS total_sold_quantity_monthwise
		FROM gdb023.dim_customer AS dim_customer
		INNER JOIN gdb023.fact_sales_monthly AS monthly_sales
		USING(customer_code)
		WHERE customer='Atliq Exclusive'
		GROUP BY product_code, date, month, fiscal_year
		ORDER BY product_code, date) AS peritem_totalsales_monthwise
	INNER JOIN gdb023.fact_gross_price AS gross_price
	ON peritem_totalsales_monthwise.product_code = gross_price.product_code AND  peritem_totalsales_monthwise.fiscal_year = gross_price.fiscal_year) AS final_table
GROUP BY date;

#######################################################################################################################
#Request 8
#In which quarter of 2020, got the maximum total_sold_quantity? 
#The final output contains these fields sorted by the total_sold_quantity, Quarter total_sold_quantity

#By using CTE
 WITH cte7 AS (SELECT date,MONTH(date) AS Month,sold_quantity FROM gdb023.fact_sales_monthly 
 WHERE fiscal_year=2020 )SELECT  CASE WHEN Month IN (9,10,11) THEN '1' 
					WHEN Month IN (12,1,2) THEN '2' 
                                       WHEN Month IN (3,4,5) THEN '3 '
                                       WHEN Month IN (6,7,8) THEN '4' 
                                   END AS Quarter ,SUM(sold_quantity) AS total_sold_quantity   
                       FROM cte7  GROUP BY Quarter ORDER BY total_sold_quantity DESC  ;
#By using subqueries
SELECT Quarter, SUM(sold_quantity) AS total_sold_quantity
FROM 
(
	SELECT *,
		(CASE
			WHEN MONTH(date) IN ('9', '10', '11') THEN 1
			WHEN MONTH(date) IN ('12', '1', '2') THEN 2
			WHEN MONTH(date) IN ('3', '4', '5') THEN 3
			WHEN MONTH(date) IN ('6', '7', '8') THEN 4
		END) AS Quarter
	FROM gdb023.fact_sales_monthly AS monthly_sales
    WHERE fiscal_year = '2020'
) AS table_with_quarter_data
GROUP BY Quarter
ORDER BY Quarter ASC;

#Request 9: Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? 
#The final output contains these fields, channel gross_sales_mln percentage

#tables used : dim customer(channel), fact_gross_price(gross_price), fact_sales_monthly(sold_quantity)
SELECT * FROM gdb023.fact_gross_price
WHERE fiscal_year = '2021';

SELECT * FROM gdb023.fact_sales_monthly
WHERE fiscal_year = '2021';

SELECT * FROM gdb023.dim_customer
WHERE fiscal_year = 2021;

SELECT channel, SUM(sold_quantity) as total_sold_perchannel
FROM
(
SELECT product_code,channel, sold_quantity, fiscal_year as fiscal_year_old
FROM gdb023.dim_customer as dim_customer
INNER JOIN gdb023.fact_sales_monthly as monthly_sales
USING(customer_code)
WHERE fiscal_year = '2021'
) AS first_join
INNER JOIN gdb023.fact_gross_price as gross_price
USING(product_code)
WHERE gross_price.fiscal_year = '2021'
GROUP BY channel
ORDER BY total_sold_perchannel DESC;

WITH cte16 AS(SELECT C.channel,ROUND(SUM(A.sold_quantity*B.gross_price)/1000000,2) AS gross_sales_mln
  FROM fact_sales_monthly A 
  LEFT JOIN fact_gross_price B ON A.product_code=B.product_code
  LEFT JOIN dim_customer C ON A.customer_code=C.customer_code 
  WHERE A.fiscal_year=2021 GROUP BY C.channel  ORDER BY 2 DESC)
  SELECT *,ROUND(gross_sales_mln*100/SUM(gross_sales_mln) OVER(),2) AS percentage FROM cte16;



SELECT product_code,channel, sold_quantity, fiscal_year as fiscal_year_old
FROM gdb023.fact_sales_monthly as monthly_sales
INNER JOIN gdb023.dim_customer as dim_customer
USING(customer_code)
WHERE fiscal_year = '2021';
