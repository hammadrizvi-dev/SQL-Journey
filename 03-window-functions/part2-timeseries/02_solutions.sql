-- Module 03 (Part 2): Time-Series & Frame Window Functions — Verified Solutions (SQLite 3.25+ & MySQL 8+ compatible)
-- Run on analytics.db (seeded from 02-ctes-and-subqueries/business-analytics/sqlite/01_schema_and_seed.sql)

-- 1. Month-over-Month (MoM) revenue growth % using LAG() (cleaner than CTE self-join)
WITH monthly_rev AS (
    SELECT strftime('%Y-%m', order_date) AS order_month,
           SUM(amount) AS total_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY order_month
)
SELECT order_month,
       total_revenue,
       LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
       ROUND(
           100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY order_month))
           / LAG(total_revenue) OVER (ORDER BY order_month),
           2
       ) AS mom_growth_pct
FROM monthly_rev
ORDER BY order_month;

-- 2. Cumulative (Running Total) revenue by month
WITH monthly_rev AS (
    SELECT strftime('%Y-%m', order_date) AS order_month,
           COUNT(*) AS completed_orders,
           SUM(amount) AS monthly_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY order_month
)
SELECT order_month,
       completed_orders,
       monthly_revenue,
       SUM(monthly_revenue) OVER (
           ORDER BY order_month
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_total_revenue
FROM monthly_rev
ORDER BY order_month;

-- 3. 3-Month Moving Average of monthly revenue
WITH monthly_rev AS (
    SELECT strftime('%Y-%m', order_date) AS order_month,
           SUM(amount) AS monthly_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY order_month
)
SELECT order_month,
       monthly_revenue,
       ROUND(
           AVG(monthly_revenue) OVER (
               ORDER BY order_month
               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
           ),
           2
       ) AS moving_avg_3m
FROM monthly_rev
ORDER BY order_month;

-- 4. Per-customer running lifetime spend across completed orders
SELECT c.customer_id,
       c.full_name,
       o.order_date,
       p.plan_name,
       o.amount,
       SUM(o.amount) OVER (
           PARTITION BY o.customer_id
           ORDER BY o.order_date ASC, o.order_id ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_customer_spend
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN plans p ON p.plan_id = o.plan_id
WHERE o.status = 'Completed'
ORDER BY c.customer_id, o.order_date, o.order_id;

-- 5. Next order date and days between consecutive orders per customer using LEAD()
WITH order_gaps AS (
    SELECT c.customer_id,
           c.full_name,
           o.order_date,
           LEAD(o.order_date) OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date ASC, o.order_id ASC
           ) AS next_order_date
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
)
SELECT customer_id,
       full_name,
       order_date,
       next_order_date,
       CAST(julianday(next_order_date) - julianday(order_date) AS INTEGER) AS days_to_next_order
FROM order_gaps
ORDER BY customer_id, order_date;

-- 6. Plan Upgrade / Downgrade / Renewal tracker using LAG(monthly_price)
WITH plan_history AS (
    SELECT c.customer_id,
           c.full_name,
           o.order_date,
           p.plan_name,
           p.monthly_price,
           LAG(p.plan_name) OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date ASC, o.order_id ASC
           ) AS prev_plan,
           LAG(p.monthly_price) OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date ASC, o.order_id ASC
           ) AS prev_price
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN plans p ON p.plan_id = o.plan_id
    WHERE o.status = 'Completed'
)
SELECT customer_id,
       full_name,
       order_date,
       prev_plan,
       plan_name AS current_plan,
       CASE
           WHEN prev_price IS NULL THEN 'New Subscription'
           WHEN monthly_price > prev_price THEN 'Upgrade (+' || (monthly_price - prev_price) || ')'
           WHEN monthly_price < prev_price THEN 'Downgrade'
           ELSE 'Renewal (Same Tier)'
       END AS movement_type
FROM plan_history
ORDER BY customer_id, order_date;

-- 7. Compare each customer's first plan vs latest plan using FIRST_VALUE & LAST_VALUE
WITH customer_journey AS (
    SELECT DISTINCT
           c.customer_id,
           c.full_name,
           FIRST_VALUE(p.plan_name) OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date ASC, o.order_id ASC
           ) AS first_plan,
           LAST_VALUE(p.plan_name) OVER (
               PARTITION BY o.customer_id
               ORDER BY o.order_date ASC, o.order_id ASC
               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
           ) AS latest_plan,
           COUNT(*) OVER (PARTITION BY o.customer_id) AS completed_orders
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN plans p ON p.plan_id = o.plan_id
    WHERE o.status = 'Completed'
)
SELECT customer_id,
       full_name,
       first_plan,
       latest_plan,
       completed_orders,
       CASE WHEN first_plan <> latest_plan THEN 'Expanded' ELSE 'Unchanged' END AS tier_status
FROM customer_journey
ORDER BY customer_id;

-- 8. Monthly revenue share of total & gap from peak month using window aggregates
WITH monthly_rev AS (
    SELECT strftime('%Y-%m', order_date) AS order_month,
           SUM(amount) AS monthly_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY order_month
)
SELECT order_month,
       monthly_revenue,
       MAX(monthly_revenue) OVER () AS peak_month_revenue,
       MAX(monthly_revenue) OVER () - monthly_revenue AS gap_from_peak,
       ROUND(100.0 * monthly_revenue / SUM(monthly_revenue) OVER (), 2) AS share_of_total_pct
FROM monthly_rev
ORDER BY order_month;

-- 9. Pareto (80/20) Cumulative Revenue % by customer LTV
WITH ltv AS (
    SELECT c.customer_id,
           c.full_name,
           SUM(o.amount) AS customer_ltv
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.full_name
)
SELECT customer_id,
       full_name,
       customer_ltv,
       SUM(customer_ltv) OVER (
           ORDER BY customer_ltv DESC, customer_id ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_revenue,
       ROUND(
           100.0 * SUM(customer_ltv) OVER (
               ORDER BY customer_ltv DESC, customer_id ASC
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) / SUM(customer_ltv) OVER (),
           2
       ) AS cumulative_revenue_pct
FROM ltv
ORDER BY customer_ltv DESC, customer_id ASC;

-- 10. City-wise order sequence and cumulative revenue progression
SELECT c.city,
       o.order_date,
       c.full_name,
       o.amount,
       ROW_NUMBER() OVER (
           PARTITION BY c.city
           ORDER BY o.order_date ASC, o.order_id ASC
       ) AS city_order_seq,
       SUM(o.amount) OVER (
           PARTITION BY c.city
           ORDER BY o.order_date ASC, o.order_id ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS city_running_revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'Completed'
ORDER BY c.city, o.order_date, o.order_id;
