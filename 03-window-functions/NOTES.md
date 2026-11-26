# Module 03 (Part 1): Window Functions — Quick Revision Notes

Window Functions SQL interviews ka **sabse important topic** hain kyunki ye har row ko preserve rakhte hue group-level calculations karne dete hain.

## `GROUP BY` vs `OVER (...)` (Sabse Bada Farq)
- **`GROUP BY`** rows ko collapse kar deta hai (10 employees → 5 department rows).
- **Window Function (`OVER (...)`)** har row ko **zinda rakhta hai** aur uske bagal me aggregate/rank chipka deta hai (10 employees → 10 rows hi milengi!).

## 1. `ROW_NUMBER()` vs `RANK()` vs `DENSE_RANK()` (Q1)
Jab do logon ki salary barabar ho (e.g. `Maha` aur `Daniyal` dono `100,000`):
| Function | Behavior on Ties | Example Ranks (180k, 150k, 100k, 100k, 95k) |
|---|---|---|
| `ROW_NUMBER()` | Har row ko unique number deta hai | `1, 2, 3, 4, 5` |
| `RANK()` | Tie par same rank, par **next number skip** hota hai | `1, 2, 3, 3, 5` |
| `DENSE_RANK()` | Tie par same rank, **koi gap nahi** | `1, 2, 3, 3, 4` |

- **Interview Rule:** "Nth highest salary" nikalne ke liye hamesha **`DENSE_RANK()`** use karo (Q10), `ROW_NUMBER()` tie break kar dega aur `RANK()` gaps ki wajah se miss kar sakta hai!

## 2. Top-N Per Group Pattern (Q2, Q7)
SQL me `WHERE` clause ke andar direct window function (`WHERE DENSE_RANK() OVER (...) <= 2`) **allowed nahi hai** kyunki `WHERE`, `SELECT` ke window step se pehle execute hota hai.
- **Solution:** Pehle CTE me window rank banao, phir outer query me `WHERE dept_rank <= 2` filter lagao!

## 3. Window Aggregates (`AVG`, `MAX`, `SUM`, `COUNT` + `OVER`) (Q3, Q4, Q8, Q9)
- `SUM(salary) OVER (PARTITION BY department_id)` har employee ko uske department ka total payroll dikha deta hai.
- Isse ek hi `SELECT` me bina self-join ya extra CTE ke **% contribution** (`100.0 * salary / SUM(salary) OVER (...)`) nikal aata hai!
- **SQLite Tip:** `100.0` multiply karna mat bhoolna warna integer division `0` dega.

## 4. `NTILE(n)` Bucketing (Q6)
- Sorted rows ko `n` barabar buckets (quartiles/deciles) me baantne ke liye `NTILE(4) OVER (ORDER BY salary DESC)` use hota hai — customer segmentation aur compensation bands me bahut kaam aata hai.
