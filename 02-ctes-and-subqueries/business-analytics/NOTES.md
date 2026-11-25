# Module 02 (Part 2): Business Analytics (Revenue, Cohort & Retention) — Quick Revision Notes

Is module me humne **real-world SaaS / E-commerce business metrics** ko pure SQL (CTEs + Aggregations + Date math) se calculate karna seekha.

## 1. Recognized Revenue vs Raw Orders (Q1, Q3)
- Kabhi bhi `SUM(amount)` seedha `orders` table par mat lagao — `Refunded` aur `Pending` orders revenue ko inflate kar dete hain!
- Hamesha `WHERE status = 'Completed'` filter lagao, ya `SUM(CASE WHEN status = 'Completed' THEN amount ELSE 0 END)` use karo jab saath me `Refunded` rate bhi nikalna ho.

## 2. Month-over-Month (MoM) Growth Bina Window Functions Ke (Q2)
- Har month ko ek integer index me badlo: `(year * 12 + month)`.
- Phir CTE ko khud se `LEFT JOIN` karo on `curr.month_index = prev.month_index + 1`.
- Formula: `100.0 * (curr - prev) / prev` (`100.0` lagana zaroori hai taaki SQLite integer division na kare!).

## 3. Cohort & Retention Analysis (Q5, Q6)
- **Cohort:** Jin users ne ek hi month me signup kiya (`strftime('%Y-%m', signup_date)`), wo ek cohort hain.
- **Month Offset:** Har completed order ke liye nikalo ki wo signup ke kitne mahine baad aaya:
  `(order_year - signup_year) * 12 + (order_month - signup_month)`
  - `month_offset = 0` → Signup month ka conversion
  - `month_offset = 1, 2, 3...` → Retention % (`active_users / cohort_users * 100.0`)
- **Zaroori Tip:** `COUNT(DISTINCT customer_id)` ya `SELECT DISTINCT customer_id, cohort_month, month_offset` zaroor lagao, warna ek user ke 2 orders ek hi month me 200% retention dikha denge!

## 4. New vs Returning Revenue & Repeat Rate (Q7, Q8)
- Har user ka `MIN(order_date)` nikal kar `first_order_month` banao.
- Agar order uske `first_order_month` me hua to **New Customer Revenue**, aur baad ke mahine me hua to **Returning Customer Revenue**.
- **Repeat Buyer:** `completed_orders >= 2`. Product/growth interviews me ye metric retention aur product-market fit dikhata hai.

## 5. Churn Detection (`NOT EXISTS`) & LTV (Q9, Q10)
- **Churned / At-Risk users:** Jinhone pichle mahino me kharida (`order_date < '2026-05-01'`) par latest month me `NOT EXISTS` koi completed order.
- **ARPU vs AOV:**
  - **AOV (Average Order Value)** = `Total Revenue / Completed Orders`
  - **ARPU (Average Revenue Per User)** = `Total Revenue / Total Signups` (Q4)
