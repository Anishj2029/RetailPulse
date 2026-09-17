USE retailpulse;


-- =========================================================
-- View 1: Business Overview
-- Purpose:
-- Provides high-level KPIs such as total orders,
-- total customers, products sold, total revenue,
-- and average item price.
-- =========================================================

CREATE OR REPLACE VIEW vw_business_overview AS
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS products_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- Check the Business Overview view
SELECT *
FROM vw_business_overview;


-- =========================================================
-- View 2: Monthly Revenue
-- Purpose:
-- Shows how revenue and order volume change month by month.
-- Useful for identifying growth, seasonal trends,
-- and high-performing months.
-- =========================================================

CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;


-- Check the Monthly Revenue view
SELECT *
FROM vw_monthly_revenue
ORDER BY month;


-- =========================================================
-- View 3: Category Performance
-- Purpose:
-- Measures the performance of each product category.
-- Shows number of orders, items sold, and revenue.
-- Useful for finding the most profitable categories.
-- =========================================================

CREATE OR REPLACE VIEW vw_category_performance AS
SELECT
    COALESCE(p.product_category_name, 'Unknown') AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.product_id) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY category;


-- Check the Category Performance view
SELECT *
FROM vw_category_performance
ORDER BY revenue DESC;


-- =========================================================
-- View 4: State Performance
-- Purpose:
-- Shows the number of orders and revenue generated
-- by customers from each state.
-- Useful for geographic sales analysis.
-- =========================================================

CREATE OR REPLACE VIEW vw_state_performance AS
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state;


-- Check the State Performance view
SELECT *
FROM vw_state_performance
ORDER BY revenue DESC;

-- =========================================================
-- View 5: Payment Performance
-- Purpose:
-- Shows payment method usage, total payment value,
-- and average installments.
-- Useful for understanding customer payment preferences.
-- =========================================================

CREATE OR REPLACE VIEW vw_payment_performance AS
SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_installments), 2) AS average_installments
FROM order_payments
GROUP BY payment_type;


-- Check the Payment Performance view
SELECT *
FROM vw_payment_performance
ORDER BY total_payment_value DESC;


-- =========================================================
-- View 6: Delivery Performance
-- Purpose:
-- Measures delivery time and compares actual delivery
-- dates with estimated delivery dates.
-- Useful for identifying late deliveries.
-- =========================================================

CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'

        WHEN order_delivered_customer_date >
             order_estimated_delivery_date
            THEN 'Delivered Late'

        ELSE 'Delivered On Time'
    END AS delivery_status,

    COUNT(*) AS total_orders,

    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_days

FROM orders
GROUP BY delivery_status;


-- Check the Delivery Performance view
SELECT *
FROM vw_delivery_performance
ORDER BY total_orders DESC;

-- =========================================================
-- View 7: Customer Performance
-- Purpose:
-- Shows how many orders each customer placed
-- and the total amount spent by that customer.
-- Useful for identifying high-value and repeat customers.
-- =========================================================

CREATE OR REPLACE VIEW vw_customer_performance AS
SELECT
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent,

    CASE
        WHEN COUNT(DISTINCT o.order_id) > 1
            THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type

FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.customer_id;


-- Check the Customer Performance view
SELECT *
FROM vw_customer_performance
LIMIT 20;

-- =========================================================
-- View 8: Seller Performance
-- Purpose:
-- Shows total orders, items sold, and revenue
-- generated by each seller.
-- Useful for comparing seller performance.
-- =========================================================

CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.product_id) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price

FROM order_items oi
GROUP BY oi.seller_id;


-- Check the Seller Performance view
SELECT *
FROM vw_seller_performance
ORDER BY revenue DESC
LIMIT 10;