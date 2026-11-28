# Module 03 (Part 2): Time-Series, `LAG`/`LEAD` & Window Frames — Quick Revision Notes

Module 02 me humne MoM revenue growth nikalne ke liye **CTE self-join** likha tha — `LAG()` aur `LEAD()` wahi kaam **ek line me, zyada clean aur faster** tareeke se karte hain.

## 1. `LAG()` vs `LEAD()` (Time-Series Magic)
- **`LAG(col, 1)`**: Pichli row ki value laata hai (e.g., pichle mahine ka revenue ya customer ka pichla subscription plan → **Upgrade / MoM Growth**).
- **`LEAD(col, 1)`**: Agli row ki value laata hai (e.g., customer ki next order date → **Days Between Orders / Retention Gap**).
- **Pro Tip:** First row ke liye `LAG` `NULL` deta hai aur last row ke liye `LEAD` `NULL` deta hai.

## 2. Running Totals & Moving Averages (`ROWS BETWEEN ...`)
Window function ke andar `ORDER BY` lagane se wo row-by-row accumulate hota hai:
- **Running Total:** `SUM(amount) OVER (ORDER BY order_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)`
- **3-Month Moving Average:** `AVG(monthly_revenue) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)`
  - Current row + pichle 2 rows = 3-period rolling window!

## 3. Sabse Common Interview Trap: `LAST_VALUE()` Frame Bug!
Agar aap sirf ye likhoge:
```sql
LAST_VALUE(plan_name) OVER (PARTITION BY customer_id ORDER BY order_date)
```
To SQL default frame **`RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`** lagata hai — matlab `LAST_VALUE` har row par **wahi current row** return kar dega!
- **Fix:** Hamesha explicitly likho:
  `ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING` (poori partition dekhne ke liye — Q7).

## 4. Pareto (80/20) Analysis Pattern (Q9)
Ek hi `SELECT` me:
- Numerator: `SUM(ltv) OVER (ORDER BY ltv DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` (running revenue)
- Denominator: `SUM(ltv) OVER ()` (grand total revenue)
- Divide karne par turant pata chalta hai ki top 20% customers kitna % revenue la rahe hain!
