create database ecommerce_analytics;
use ecommerce_analytics;

create table customers (
	customer_id INT PRIMARY KEY,
    signup_date date not null,
    state varchar(2) not null,
    acquisition_channel varchar(50) not null );
  
create table products (
	product_id int primary key,
    product_name varchar(255) not null,
    category varchar(50) not null,
    list_price decimal(10,2) not null,
    unit_cost decimal(10,2) not null );
    
    create table orders (
    order_id int primary key,
    customer_id int not null,
    order_date datetime not null,
    status varchar(20) not null,
    payment_method varchar(30) not null,
    discount_code varchar(50),
    shipping_fee decimal(10,2) not null,
    has_discount tinyint not null,
    foreign key (customer_id) references customers(customer_id));
    
    create table order_items (
    order_id int not null,
    product_id int not null,
    quantity int not null,
    unit_price decimal(10,2), 
    doscount_amount decimal(10,2) not null,
    price_missing tinyint not null,
    gross_line_value decimal(12,2),
    net_line_value decimal(12,2),
    primary key (order_id,product_id),
    foreign key(order_id) references orders(order_id),
    foreign key(product_id) references products(product_id));
    
    create index idx_orders_customer on orders(customer_id);
    create index idx_orders_date on orders(order_date);
    create index idx_orders_status on orders(status);
    create index idx_order_items_product on order_items(product_id);
    create index idx_customers_channel on customers(acquisition_channel);
    
    select count(*) as customer_count from customers;
    select count(*) as product_count from products;
    select count(*) as order_count from orders;
    select count(*) as order_item_count from order_items;
    
    select
    count(*) as total_orders,
    count(distinct order_id) as unique_orders from orders;
    
    use ecommerce_analytics;
    select count(*) as total_rows from order_items;
    select count(*) as missing_price_rows from order_items where unit_price is null;
    select count(*) as flagged_missing_price_rows from order_items where price_missing =1;
    
    show columns from order_items;
    
    ALTER TABLE order_items
RENAME COLUMN doscount_amount TO discount_amount;
DESCRIBE order_items;

SELECT
    COUNT(*) AS total_rows,
    SUM(price_missing = 1) AS missing_price_rows
FROM order_items;

USE ecommerce_analytics;
SELECT 'customers' AS table_name, COUNT(*) AS total_rows
FROM customers
UNION ALL
SELECT 'products', COUNT(*)
FROM products
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items;

# Orders without a valid customer
SELECT COUNT(*) AS invalid_customer_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

# Order items without a valid product
SELECT COUNT(*) AS invalid_product_items
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

# Orders without any order items
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

# Check order statuses
SELECT
    status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY status
ORDER BY total_orders DESC;

# Business analysis using SQL:How much revenue is the business generating, how is it changing over time, and what factors influence sales?

SELECT
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.gross_line_value), 2)		#Adds known item values before line discounts
        AS known_gross_item_sales,
    ROUND(SUM(oi.net_line_value), 2)		#Adds known item values after line discounts
        AS known_net_item_revenue,
    ROUND(SUM(o.shipping_fee), 2)		#Adds shipping fees for completed orders
        AS completed_order_shipping_fees,
    COUNT(DISTINCT CASE					#Counts unique orders, not product lines
        WHEN oi.price_missing = 1 THEN o.order_id
    END) AS orders_with_missing_prices
FROM orders o
JOIN order_items oi			#Connects orders to their individual product lines
    ON o.order_id = oi.order_id
WHERE o.status = 'completed';		#Filters to completed orders

WITH completed_order_totals AS (
    SELECT
        order_id,
        shipping_fee
    FROM orders
    WHERE status = 'completed'
),
item_totals AS (
    SELECT
        oi.order_id,
        SUM(oi.gross_line_value) AS gross_item_sales,
        SUM(oi.net_line_value) AS net_item_revenue,
        SUM(oi.price_missing = 1) AS missing_price_lines
    FROM order_items oi
    JOIN completed_order_totals co
        ON oi.order_id = co.order_id
    GROUP BY oi.order_id
)
SELECT
    COUNT(*) AS completed_orders,
    ROUND(SUM(it.gross_item_sales), 2) AS known_gross_item_sales,
    ROUND(SUM(it.net_item_revenue), 2) AS known_net_item_revenue,
    ROUND(SUM(co.shipping_fee), 2) AS shipping_fees,
    SUM(it.missing_price_lines > 0) AS orders_with_missing_prices
FROM completed_order_totals co
JOIN item_totals it
    ON co.order_id = it.order_id;
    
#Analyze monthly sales trends
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_item_revenue,
    ROUND(AVG(oi.net_line_value), 2) AS avg_net_value_per_item_line
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

#Calculate Average Order Value (AOV)
     #AOV using orders with complete item prices
WITH order_totals AS (
    SELECT
        o.order_id,
        SUM(oi.net_line_value) AS order_revenue,
        SUM(oi.price_missing) AS missing_price_lines
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY o.order_id
)
SELECT
    COUNT(*) AS completed_orders_with_known_prices,
    ROUND(SUM(order_revenue), 2) AS net_item_revenue,
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM order_totals
WHERE missing_price_lines = 0;

#Monthly revenue and growth
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
        SUM(oi.net_line_value) AS known_net_revenue,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        COUNT(DISTINCT CASE
            WHEN oi.price_missing = 1 THEN o.order_id
        END) AS orders_with_missing_prices
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
sales_with_previous_month AS (
    SELECT
        *,
        LAG(known_net_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM monthly_sales
)
SELECT
    sales_month,
    completed_orders,
    ROUND(known_net_revenue, 2) AS known_net_revenue,
    orders_with_missing_prices,
    ROUND(
        known_net_revenue - previous_month_revenue, 2
    ) AS revenue_change,
    ROUND(
        100.0 * (known_net_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0),
        2
    ) AS mom_growth_percent
FROM sales_with_previous_month
ORDER BY sales_month;

#Top 10 products by known net revenue
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS orders_containing_product,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY known_net_revenue DESC
LIMIT 10;

#Identify high-value customers
SELECT
    c.customer_id,
    c.state,
    c.acquisition_channel,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY
    c.customer_id,
    c.state,
    c.acquisition_channel
ORDER BY known_net_revenue DESC
LIMIT 10;

#Measure repeat-purchase behavior
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS completed_orders
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN completed_orders = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS total_customers,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(DISTINCT customer_id)
         FROM orders
         WHERE status = 'completed'),
        2
    ) AS percentage
FROM customer_orders
GROUP BY customer_type;

#Compare customer acquisition channels
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS purchasing_customers,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue,
    ROUND(
        SUM(oi.net_line_value) /
        NULLIF(COUNT(DISTINCT c.customer_id), 0),
        2
    ) AS known_revenue_per_purchasing_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.acquisition_channel
ORDER BY known_net_revenue DESC;

#Analyze the time between purchases
WITH customer_purchase_dates AS (
    SELECT DISTINCT
        customer_id,
        order_id,
        DATE(order_date) AS purchase_date
    FROM orders
    WHERE status = 'completed'
),
purchase_gaps AS (
    SELECT
        customer_id,
        purchase_date,
        LAG(purchase_date) OVER (
            PARTITION BY customer_id
            ORDER BY purchase_date, order_id
        ) AS previous_purchase_date
    FROM customer_purchase_dates
)
SELECT
    COUNT(*) AS repeat_purchase_intervals,
    ROUND(
        AVG(DATEDIFF(purchase_date, previous_purchase_date)),
        2
    ) AS average_days_between_purchases,
    MIN(DATEDIFF(purchase_date, previous_purchase_date))
        AS shortest_gap_days,
    MAX(DATEDIFF(purchase_date, previous_purchase_date))
        AS longest_gap_days
FROM purchase_gaps
WHERE previous_purchase_date IS NOT NULL;

#Find potentially inactive customers
WITH last_completed_purchase AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_purchase_date
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
),
dataset_date AS (
    SELECT MAX(order_date) AS latest_order_date
    FROM orders
)
SELECT
    c.customer_id,
    c.state,
    c.acquisition_channel,
    l.last_purchase_date,
    DATEDIFF(
        d.latest_order_date,
        l.last_purchase_date
    ) AS days_since_last_purchase
FROM customers c
JOIN last_completed_purchase l
    ON c.customer_id = l.customer_id
CROSS JOIN dataset_date d
WHERE DATEDIFF(
    d.latest_order_date,
    l.last_purchase_date
) >= 90
ORDER BY days_since_last_purchase DESC;

#Category performance
SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue,
    ROUND(
        SUM(oi.net_line_value - oi.quantity * p.unit_cost),
        2
    ) AS known_line_profit,
    ROUND(
        100.0 * SUM(
            oi.net_line_value - oi.quantity * p.unit_cost
        ) / NULLIF(SUM(oi.net_line_value), 0),
        2
    ) AS profit_margin_percent,
    SUM(oi.price_missing) AS missing_price_lines
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY known_net_revenue DESC;

#Rank the top 10 products by profit
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue,
    ROUND(
        SUM(oi.net_line_value - oi.quantity * p.unit_cost),
        2
    ) AS known_line_profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY known_line_profit DESC
LIMIT 10;

#Find products with high sales but low margins
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue,
    ROUND(
        SUM(oi.net_line_value - oi.quantity * p.unit_cost),
        2
    ) AS known_line_profit,
    ROUND(
        100.0 * SUM(
            oi.net_line_value - oi.quantity * p.unit_cost
        ) / NULLIF(SUM(oi.net_line_value), 0),
        2
    ) AS profit_margin_percent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY
    p.product_id,
    p.product_name,
    p.category
HAVING SUM(oi.net_line_value) > 0
ORDER BY profit_margin_percent ASC
LIMIT 10;

#Compare completed, returned and canceled orders
SELECT
    status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders),
        2
    ) AS percentage_of_orders
FROM orders
GROUP BY status
ORDER BY total_orders DESC;

#Customer acquisition and retention opportunities
WITH customer_purchase_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS completed_orders
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT
    c.acquisition_channel,
    COUNT(*) AS purchasing_customers,
    SUM(
        CASE WHEN p.completed_orders = 1
             THEN 1 ELSE 0 END
    ) AS one_time_customers,
    SUM(
        CASE WHEN p.completed_orders >= 2
             THEN 1 ELSE 0 END
    ) AS repeat_customers,
    ROUND(
        100.0 * SUM(
            CASE WHEN p.completed_orders >= 2
                 THEN 1 ELSE 0 END
        ) / COUNT(*),
        2
    ) AS repeat_customer_percent
FROM customers c
JOIN customer_purchase_counts p
    ON c.customer_id = p.customer_id
GROUP BY c.acquisition_channel
ORDER BY repeat_customer_percent DESC;

#Create a consolidated KPI summary
WITH order_revenue AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.status,
        o.order_date,
        SUM(oi.net_line_value) AS known_net_revenue,
        SUM(oi.price_missing) AS missing_price_lines
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.customer_id,
        o.status,
        o.order_date
),
completed_order_summary AS (
    SELECT *
    FROM order_revenue
    WHERE status = 'completed'
),
customer_frequency AS (
    SELECT
        customer_id,
        COUNT(*) AS completed_orders
    FROM completed_order_summary
    GROUP BY customer_id
)
SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE status = 'completed') AS completed_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE status = 'returned') AS returned_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE status = 'canceled') AS canceled_orders,

    (SELECT ROUND(SUM(known_net_revenue), 2)
     FROM completed_order_summary) AS known_net_item_revenue,

    (SELECT ROUND(AVG(known_net_revenue), 2)
     FROM completed_order_summary
     WHERE missing_price_lines = 0) AS avg_order_value_complete_prices,

    (SELECT COUNT(*)
     FROM customer_frequency
     WHERE completed_orders >= 2) AS repeat_customers,

    (SELECT COUNT(*)
     FROM customer_frequency
     WHERE completed_orders = 1) AS one_time_customers;
     
#View 1: Business KPIs
     CREATE OR REPLACE VIEW vw_business_kpis AS
WITH order_totals AS (
    SELECT
        o.order_id,
        SUM(oi.net_line_value) AS known_revenue,
        SUM(oi.price_missing) AS missing_price_lines
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
)
SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM orders
     WHERE status = 'completed') AS completed_orders,
    (SELECT COUNT(*) FROM orders
     WHERE status = 'returned') AS returned_orders,
    (SELECT COUNT(*) FROM orders
     WHERE status = 'canceled') AS canceled_orders,
    (SELECT ROUND(SUM(known_revenue), 2)
     FROM order_totals
     WHERE order_id IN (
         SELECT order_id FROM orders WHERE status = 'completed'
     )) AS known_net_revenue,
    (SELECT ROUND(AVG(known_revenue), 2)
     FROM order_totals ot
     JOIN orders o ON ot.order_id = o.order_id
     WHERE o.status = 'completed'
       AND ot.missing_price_lines = 0) AS aov_complete_prices;
       
#View 2: Monthly sales trends
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue,
    SUM(oi.price_missing) AS missing_price_lines
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

#View 3: Product and category performance
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue,
    ROUND(SUM(
        oi.net_line_value - oi.quantity * p.unit_cost
    ), 2) AS known_line_profit,
    SUM(oi.price_missing) AS missing_price_lines
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.status = 'completed'
GROUP BY p.product_id, p.product_name, p.category;

#View 4: Acquisition channel performance
CREATE OR REPLACE VIEW vw_channel_performance AS
SELECT
    c.acquisition_channel,
    COUNT(DISTINCT c.customer_id) AS purchasing_customers,
    COUNT(DISTINCT o.order_id) AS completed_orders,
    ROUND(SUM(oi.net_line_value), 2) AS known_net_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.acquisition_channel;

SELECT * FROM vw_business_kpis;
SELECT * FROM vw_monthly_sales ORDER BY sales_month;
SELECT * FROM vw_product_performance
ORDER BY known_net_revenue DESC;
SELECT * FROM vw_channel_performance
ORDER BY known_net_revenue DESC;

SELECT COUNT(*) AS total_orders FROM orders;