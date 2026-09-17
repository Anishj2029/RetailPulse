SELECT * FROM vw_business_overview;

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS total_customers,
    COUNT(DISTINCT oi.product_id) AS products_sold,
    ROUND(SUM(oi.price), 2) AS total_product_revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;

-- Query 2: Monthly Revenue Trend
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

SELECT
    COALESCE(p.product_category_name, 'Unknown') AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY revenue DESC
LIMIT 10;

SELECT
    ROUND(SUM(order_total) / COUNT(*), 2) AS average_order_value
FROM (
    SELECT
        o.order_id,
        SUM(oi.price + oi.freight_value) AS order_total
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY o.order_id
) AS order_values;

-- Query 6: Customer Distribution by State
SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Query 7: Top States by Revenue
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;
USE retailpulse;

SELECT
    customer_order_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS customer_order_count
    FROM orders
    GROUP BY customer_id
) AS customer_orders
GROUP BY customer_order_count
ORDER BY customer_order_count;

SELECT
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
) AS customer_orders;

SELECT
    payment_type,
    COUNT(*) AS total_payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;

SELECT
    payment_type,
    COUNT(*) AS total_transactions,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM order_payments),
        2
    ) AS usage_percentage
FROM order_payments
GROUP BY payment_type
ORDER BY usage_percentage DESC;

SELECT
    payment_type,
    ROUND(AVG(payment_installments), 2) AS average_installments,
    MAX(payment_installments) AS maximum_installments
FROM order_payments
GROUP BY payment_type
ORDER BY average_installments DESC;

SELECT
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
WHERE order_delivered_customer_date IS NOT NULL;

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_estimated_delivery_date
            )
        ),
        2
    ) AS average_delivery_difference_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

  SELECT
    ROUND(
        SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

  SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_delivered_customer_date >
             order_estimated_delivery_date
            THEN 'Delivered Late'
        ELSE 'Delivered On Time'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY delivery_status;

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

SELECT
    COALESCE(p.product_category_name, 'Unknown') AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(oi.product_id) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY category
ORDER BY revenue DESC;

SELECT
    COALESCE(p.product_category_name, 'Unknown') AS category,
    ROUND(AVG(oi.price), 2) AS average_product_price,
    COUNT(oi.product_id) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY category
ORDER BY average_product_price DESC;

SELECT
    oi.product_id,
    COALESCE(p.product_category_name, 'Unknown') AS category,
    COUNT(*) AS units_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY oi.product_id, category
ORDER BY revenue DESC
LIMIT 10;