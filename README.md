# AtliQ_consumer_sales
 
##Introduction
This project aims to provide insights related to the customer sales and revenue of AtliQ Hardware company. This will help the company to make quick and smart data-informed decisions. The insights are provided in response to the 10 business needs ad-hoc requests and also some additional analysis. 
The analysis is represented in the form of tableau dashboard which is simple yet detailed hence easy to understand for non-tech peoples.
Task:  

Imagine yourself as the applicant for this role and perform the following task

1.    Check ‘ad-hoc-requests.pdf’ - there are 10 ad hoc requests for which the business needs insights.
2.    You need to run a SQL query to answer these requests. 
3.    The target audience of this dashboard is top-level management - hence you need to create a presentation to show the insights.
4.    Be creative with your presentation, audio/video presentation will have more weightage.
 
##Technologies
1. SQL (MySQLWorkbench 8.0.30.CE)
2. Tableau 2022.1

##Database
MySqL database used for this project:
[atliq_hardware_db.sql](https://github.com/santosh5906/AtliQ_consumer_sales/blob/26d7e89f2b115613e9bdf14f5480f94b291224e1/Atliq-Input%20for%20participants/atliq_hardware_db.sql)


##Requests
1. Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region.
2. What is the percentage of unique product increase in 2021 vs. 2020? The final output contains these fields:
 unique_products_2020, unique_products_2021 and percentage_chg.
3. Provide a report with all the unique product counts for each segment and sort them in descending order of product counts. The final output contains 2 fields:
  segment and product_count.
4. Follow-up: Which segment had the most increase in unique products in 2021 vs 2020? The final output contains these fields:
 segment, product_count_2020, product_count_2021 and difference.
5. Get the products that have the highest and lowest manufacturing costs. The final output should contain these fields:
 product_code, product and manufacturing_cost.
6. Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. The final output contains these fields:
 customer_code, customer and average_discount_percentage
7. Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month . This analysis helps to get an idea of low and high-performing months and take strategic decisions. The final report contains these columns: 
Month, Year and Gross sales Amount.
8. In which quarter of 2020, got the maximum total_sold_quantity? The final output contains these fields:
 total_sold_quantity and Quarter total_sold_quantity 
9. Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution? The final output contains these fields:
 channel, gross_sales_mln and percentage
10. Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021? The final output contains these fields, division, product_code, product, total_sold_quantity and rank_order

##Inspiration
This project is based on the resume project challenge - 4 from codebasic
[Provide Insights to Management in Consumer Goods Domain](https://codebasics.io/challenge/codebasics-resume-project-challenge#)
