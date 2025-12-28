-- VALIDATION
SELECT COUNT(*) FROM customers_clean;
SELECT COUNT(*) FROM orders_clean;
SELECT COUNT(*) FROM order_details_clean;



SELECT COUNT(*) AS total_rows,
COUNT(DISTINCT order_id) AS total_orders
FROM order_details_clean;

-- KPI- ELIGIBLE DATA COUNT
SELECT COUNT(*) AS eligible_rows
FROM order_details_clean
WHERE kpi_eligible='YES'

-- TOTAL NET REVENUE 
SELECT ROUND(SUM(net_sales_final),2)AS total_net_revenue
FROM order_details_clean
WHERE kpi_eligible = 'YES';

-- Total Orders only kpi_eligible order
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM order_details_clean 
WHERE kpi_eligible = 'YES';

-- average order value (AOV)
SELECT ROUND(SUM(net_sales_final)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM order_details_clean 
WHERE kpi_eligible='YES';

-- product-wise sales (top 10 product)
SELECT product,ROUND(SUM(net_sales_final),2) AS product_sales
FROM order_details_clean
WHERE kpi_eligible = 'YES'
GROUP BY product
ORDER BY product_sales DESC LIMIT 10;

-- region-wise revenue
SELECT o.region,
ROUND(SUM(od.net_sales_final),2)AS region_sales
FROM order_details_clean od
JOIN orders_clean o ON od.order_id=o.order_id
WHERE od.kpi_eligible= 'YES'
GROUP BY o.region
ORDER BY region_sales DESC;

--TOP 10 CUSTOMER-WISE REVENUE
SELECT c.customer_name,
ROUND(SUM(od.net_sales_final),2) AS customer_sales
FROM order_details_clean od
JOIN orders_clean o ON od.order_id = o.order_id
JOIN customers_clean c ON o.customer_id = c.customer_id
WHERE od.kpi_eligible = 'YES'
GROUP BY c.customer_name
ORDER BY customer_sales DESC LIMIT 10;

-- DATA QUALITY INSIGHT
SELECT discount_flag, COUNT(*) AS record_count
FROM order_details_clean
GROUP BY discount_flag;

SELECT outlier_status,COUNT(*)AS record_count
FROM order_details_clean
GROUP BY outlier_status;

-- Total Sales of Unknown customers with Count 
SELECT c.customer_name,COUNT(*),SUM(od.net_sales_final) as total_sales
FROM customers_clean c
JOIN orders_clean o ON c.customer_id = o.customer_id
JOIN order_details_clean od ON o.order_id=od.order_id
WHERE customer_name='Unknown Customer'
GROUP BY c.customer_name;

-- RAW vs CLEAN Revenue
SELECT 'Raw Revenue'AS revenue_type,
ROUND(SUM(net_sales_final),2)AS revenue
FROM order_details_clean

UNION

SELECT 'Clean Revenue (KPI Eligible)'AS revenue_type,
ROUND(SUM(net_sales_final),2)
FROM order_details_clean
WHERE kpi_eligible='YES';


--EXCLUDED DATA REASON BREAKDOWN
SELECT kpi_eligible,COUNT(*)AS records
FROM order_details_clean
GROUP BY kpi_eligible;

SELECT discount_flag,COUNT(*) AS records
FROM order_details_clean
WHERE kpi_eligible ='NO'
GROUP BY discount_flag;

SELECT outlier_status,COUNT(*)AS records
FROM order_details_clean
WHERE kpi_eligible = 'NO'
GROUP BY outlier_status;



CREATE VIEW kpi_sales_view AS
SELECT o.order_date,
o.region,
c.customer_name,
od.product,
od.net_sales_final
FROM order_details_clean od
JOIN orders_clean o ON od.order_id=o.order_id
JOIN customers_clean c ON o.customer_id = c.customer_id
WHERE od.kpi_eligible = 'YES';
