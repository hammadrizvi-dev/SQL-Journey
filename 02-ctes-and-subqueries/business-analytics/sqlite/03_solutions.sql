-- Module 02 (Part 2): Business Analytics (Revenue, Cohort & Retention) — Verified Solutions (SQLite)

-- 1. Monthly recognized revenue, completed orders, and Average Order Value (AOV)
SELECT strftime('%Y-%m', order_date) AS order_month,
       COUNT(*) AS completed_orders,
       SUM(amount) AS total_revenue,
       ROUND(AVG(amount), 2) AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY order_month
ORDER BY order_month;

-- 2. Month-over-Month (MoM) revenue growth % using CTE self-join
WITH monthly_rev AS (
    SELECT strftime('%Y-%m', order_date) AS order_month,
           (CAST(strftime('%Y', order_date) AS INTEGER) * 12
            + CAST(strftime('%m', order_date) AS INTEGER)) AS month_index,
           SUM(amount) AS total_revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY order_month, month_index
)
SELECT curr.order_month,
       curr.total_revenue,
       prev.total_revenue AS prev_month_revenue,
       ROUND(100.0 * (curr.total_revenue - prev.total_revenue) / prev.total_revenue, 2) AS mom_growth_pct
FROM monthly_rev curr
LEFT JOIN monthly_rev prev
    ON curr.month_index = prev.month_index + 1
ORDER BY curr.order_month;

-- 3. Plan-level completed revenue and refund rate %
SELECT p.plan_name,
       COUNT(o.order_id) AS total_orders,
       SUM(CASE WHEN o.status = 'Completed' THEN o.amount ELSE 0 END) AS completed_revenue,
       SUM(CASE WHEN o.status = 'Refunded' THEN 1 ELSE 0 END) AS refunded_orders,
       ROUND(100.0 * SUM(CASE WHEN o.status = 'Refunded' THEN 1 ELSE 0 END) / COUNT(o.order_id), 2) AS refund_rate_pct
FROM plans p
LEFT JOIN orders o ON o.plan_id = p.plan_id
GROUP BY p.plan_id, p.plan_name
ORDER BY completed_revenue DESC;

-- 4. Acquisition channel conversion rate %, total revenue, and ARPU
WITH customer_rev AS (
    SELECT c.customer_id,
           c.acquisition_channel,
           COALESCE(SUM(CASE WHEN o.status = 'Completed' THEN o.amount ELSE 0 END), 0) AS spend,
           MAX(CASE WHEN o.status = 'Completed' THEN 1 ELSE 0 END) AS is_paying
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.acquisition_channel
)
SELECT acquisition_channel,
       COUNT(*) AS total_signups,
       SUM(is_paying) AS paying_customers,
       ROUND(100.0 * SUM(is_paying) / COUNT(*), 2) AS conversion_rate_pct,
       SUM(spend) AS total_revenue,
       ROUND(1.0 * SUM(spend) / COUNT(*), 2) AS arpu
FROM customer_rev
GROUP BY acquisition_channel
ORDER BY total_revenue DESC;

-- 5. Signup cohort size and lifetime revenue contribution
WITH cohort_customers AS (
    SELECT customer_id,
           strftime('%Y-%m', signup_date) AS cohort_month
    FROM customers
)
SELECT cc.cohort_month,
       COUNT(DISTINCT cc.customer_id) AS cohort_size,
       COALESCE(SUM(CASE WHEN o.status = 'Completed' THEN o.amount ELSE 0 END), 0) AS cohort_revenue,
       ROUND(1.0 * COALESCE(SUM(CASE WHEN o.status = 'Completed' THEN o.amount ELSE 0 END), 0)
             / COUNT(DISTINCT cc.customer_id), 2) AS revenue_per_signup
FROM cohort_customers cc
LEFT JOIN orders o ON o.customer_id = cc.customer_id
GROUP BY cc.cohort_month
ORDER BY cc.cohort_month;

-- 6. Monthly cohort retention matrix (Month 0, Month 1, Month 2, ...)
WITH cohort_sizes AS (
    SELECT strftime('%Y-%m', signup_date) AS cohort_month,
           COUNT(*) AS cohort_users
    FROM customers
    GROUP BY cohort_month
),
cohort_activity AS (
    SELECT DISTINCT
           c.customer_id,
           strftime('%Y-%m', c.signup_date) AS cohort_month,
           ((CAST(strftime('%Y', o.order_date) AS INTEGER) - CAST(strftime('%Y', c.signup_date) AS INTEGER)) * 12
            + (CAST(strftime('%m', o.order_date) AS INTEGER) - CAST(strftime('%m', c.signup_date) AS INTEGER))) AS month_offset
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'Completed'
)
SELECT ca.cohort_month,
       ca.month_offset,
       COUNT(ca.customer_id) AS active_users,
       cs.cohort_users,
       ROUND(100.0 * COUNT(ca.customer_id) / cs.cohort_users, 2) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON cs.cohort_month = ca.cohort_month
WHERE ca.month_offset >= 0
GROUP BY ca.cohort_month, ca.month_offset, cs.cohort_users
ORDER BY ca.cohort_month, ca.month_offset;

-- 7. Repeat purchase rate (One-Time vs Repeat buyers)
WITH paying_counts AS (
    SELECT customer_id, COUNT(*) AS completed_orders
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
),
labeled AS (
    SELECT customer_id,
           CASE WHEN completed_orders >= 2 THEN 'Repeat Buyer' ELSE 'One-Time Buyer' END AS buyer_type
    FROM paying_counts
),
totals AS (
    SELECT COUNT(*) AS total_buyers FROM labeled
)
SELECT l.buyer_type,
       COUNT(*) AS customer_count,
       ROUND(100.0 * COUNT(*) / t.total_buyers, 2) AS share_pct
FROM labeled l
CROSS JOIN totals t
GROUP BY l.buyer_type, t.total_buyers
ORDER BY customer_count DESC;

-- 8. New vs Returning customer revenue split by month
WITH first_completed AS (
    SELECT customer_id,
           strftime('%Y-%m', MIN(order_date)) AS first_order_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT strftime('%Y-%m', o.order_date) AS order_month,
       SUM(CASE WHEN strftime('%Y-%m', o.order_date) = fc.first_order_month THEN o.amount ELSE 0 END) AS new_customer_revenue,
       SUM(CASE WHEN strftime('%Y-%m', o.order_date) > fc.first_order_month THEN o.amount ELSE 0 END) AS returning_customer_revenue,
       SUM(o.amount) AS total_revenue
FROM orders o
JOIN first_completed fc ON fc.customer_id = o.customer_id
WHERE o.status = 'Completed'
GROUP BY order_month
ORDER BY order_month;

-- 9. Churned / At-Risk paying customers (active before May 2026, no completed order in May 2026)
WITH pre_may_buyers AS (
    SELECT customer_id,
           MAX(order_date) AS last_order_date,
           SUM(amount) AS lifetime_spend
    FROM orders
    WHERE status = 'Completed'
      AND order_date < '2026-05-01'
    GROUP BY customer_id
)
SELECT c.customer_id,
       c.full_name,
       c.acquisition_channel,
       p.last_order_date,
       p.lifetime_spend
FROM pre_may_buyers p
JOIN customers c ON c.customer_id = p.customer_id
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o2
    WHERE o2.customer_id = p.customer_id
      AND o2.status = 'Completed'
      AND o2.order_date >= '2026-05-01'
)
ORDER BY p.lifetime_spend DESC;

-- 10. Top 5 customers by Lifetime Value (LTV)
WITH customer_ltv AS (
    SELECT customer_id,
           COUNT(*) AS total_orders,
           COUNT(DISTINCT strftime('%Y-%m', order_date)) AS active_months,
           SUM(amount) AS lifetime_value
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT c.full_name,
       c.city,
       strftime('%Y-%m', c.signup_date) AS signup_cohort,
       l.active_months,
       l.total_orders,
       l.lifetime_value
FROM customer_ltv l
JOIN customers c ON c.customer_id = l.customer_id
ORDER BY l.lifetime_value DESC, l.total_orders DESC
LIMIT 5;
