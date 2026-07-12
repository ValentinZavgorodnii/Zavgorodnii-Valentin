DROP TABLE IF EXISTS online_retail_raw;

CREATE TABLE online_retail_raw (
    invoice_no TEXT,
    stock_code TEXT,
    description TEXT,
    quantity TEXT,
    invoice_date TEXT,
    unit_price TEXT,
    customer_id TEXT,
    country TEXT
);

COPY online_retail_raw 
FROM '/Users/valentinzavgorodnii/Data Analyst/Zavgorodnii-Valentin/eda_online_retail/OnlineRetail.csv'
(
    FORMAT CSV,
    HEADER true,
    DELIMITER ',',
    ENCODING 'WIN1252'
);




DROP TABLE IF EXISTS online_retail_core;

CREATE TABLE online_retail_core AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity::INTEGER AS quantity,
    TO_TIMESTAMP(invoice_date, 'MM/DD/YYYY HH24:MI') AS invoice_date,
    unit_price::NUMERIC AS unit_price,
    customer_id::INTEGER AS customer_id,
    country
FROM online_retail_raw
WHERE invoice_no IS NOT NULL
    AND customer_id != '';

SELECT * FROM online_retail_core LIMIT 5;





SELECT
    customer_id,
    MIN(invoice_date) AS first_purchase_date,
    MAX(invoice_date) AS last_purchase_date,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity * unit_price) AS total_spent
FROM online_retail_core
WHERE quantity > 0
GROUP BY customer_id;




DROP TABLE IF EXISTS customer_data_mart;

CREATE TABLE customer_data_mart AS
SELECT
    customer_id,
    MIN(invoice_date) AS first_purchase_date,
    MAX(invoice_date) AS last_purchase_date,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity * unit_price) AS total_spent
FROM online_retail_core
WHERE quantity > 0
GROUP BY customer_id;






WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', invoice_date) AS month,
        SUM(quantity * unit_price) AS total_revenue
    FROM online_retail_core
    WHERE quantity > 0
    GROUP BY DATE_TRUNC('month', invoice_date))


SELECT
    month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        100.0 * (total_revenue - LAG(total_revenue) 
        OVER (ORDER BY month)) / LAG(total_revenue) OVER (ORDER BY month), 2
    ) AS growth_percentage
FROM monthly_sales
ORDER BY month;




SELECT
    customer_id,
    total_spent,
    total_orders,
    CASE
        WHEN total_spent > 5000 THEN 'VIP'
        WHEN total_spent > 1000 THEN 'Loyal'
        WHEN total_spent > 100 THEN 'Regular'
        ELSE 'Low Value'
    END AS customer_segment
FROM customer_data_mart
ORDER BY total_spent DESC;





WITH sales_stats AS (
    SELECT 
        AVG(quantity * unit_price) AS mean_value,
        STDDEV(quantity * unit_price) AS stddev_value
    FROM online_retail_core
    WHERE quantity > 0
)
SELECT
    invoice_no,
    customer_id,
    quantity * unit_price AS order_value,
    ROUND(mean_value, 2) AS gross_average,
    CASE
        WHEN ABS(quantity * unit_price - mean_value) > 3 * stddev_value THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_flag
FROM online_retail_core, sales_stats
WHERE quantity > 0
ORDER BY order_value DESC;




DROP TABLE IF EXISTS rfm_data_mart;


CREATE TABLE rfm_data_mart AS
WITH rfm_base AS (
    SELECT
        customer_id,
        EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM online_retail_core) - MAX(invoice_date)) AS recency,
        COUNT(DISTINCT invoice_no) AS frequency,
        SUM(quantity * unit_price) AS monetary
    FROM online_retail_core
    WHERE quantity > 0
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM rfm_base
)
SELECT
    customer_id,
    recency AS days_since_last_order,
    frequency AS total_orders,
    ROUND(monetary, 2) AS total_money,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_segment
FROM rfm_scores
ORDER BY total_money DESC;



SELECT * FROM rfm_data_mart



EXPLAIN ANALYZE
SELECT customer_id, SUM(quantity * unit_price)
FROM online_retail_core
WHERE quantity > 0
GROUP BY customer_id;


CREATE INDEX IF NOT EXISTS idx_customer_id ON online_retail_core(customer_id);


EXPLAIN ANALYZE
SELECT customer_id, SUM(quantity * unit_price)
FROM online_retail_core
WHERE quantity > 0 AND customer_id = 12346
GROUP BY customer_id;




COPY rfm_data_mart
TO '/Users/valentinzavgorodnii/Data Analyst/Zavgorodnii-Valentin/sql-retail-elt-pipeline/rfm_segments_output.csv'
WITH (
    FORMAT CSV, 
    HEADER true, 
    DELIMITER ','
);

