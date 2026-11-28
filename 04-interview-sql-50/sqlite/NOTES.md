# Module 04 (Batch 1): Interview SQL 50 — Quick Revision Notes

Ye 12 problems FAANG aur product startups ke **sabse frequent SQL interview patterns** cover karte hain:

## 1. Relational Division ("ALL X" Queries — Q6)
- Question: *"Kaun se employees saare Active projects par kaam kar rahe hain?"*
- Pattern: `COUNT(DISTINCT project_id)` per employee = `(SELECT COUNT(*) FROM projects WHERE status = 'Active')`.
- Kabhi nested `NOT EXISTS` me ulajhne se pehle ye count-matching trick try karo — bahut clean aur interview-ready hai!

## 2. "Every Item Satisfies Condition" (`HAVING MIN(...)` — Q7)
- Question: *"Aise departments jahan har employee >= 90k kamata ho."*
- Agar kisi department me **sabse kam** salary (`MIN(salary)`) hi `>= 90000` hai, to automatically sabki salary `>= 90000` hogi!

## 3. Non-Equi Self-Join Duplicate Fix (`e1.id < e2.id` — Q9)
- Jab same table ko khud se join karke pairs banate hain (e.g. `(Ayesha, Bilal)` aur `(Bilal, Ayesha)`), to **`e1.employee_id < e2.employee_id`** lagane se:
  1. Self-pairing `(Ayesha, Ayesha)` khatam hota hai.
  2. Reverse duplicate `(Bilal, Ayesha)` hat jaata hai.

## 4. `PERCENT_RANK()` vs `CUME_DIST()` (Q2)
- **`PERCENT_RANK()`**: `(rank - 1) / (total_rows - 1)` → `0.0` se `1.0` tak (single-row partition me `0.0`).
- **`CUME_DIST()`**: `rows_with_value_<=_current / total_rows` → `(0, 1]` range me.

## 5. Multi-CTE Modular Pipelines (Q12)
- Real analytics dashboards me ek hi mega-join likhne ke bajaye alag-alag CTEs (`dept_stats`, `top_earners`, `active_hours`) banakar end me `LEFT JOIN` karna **fan-out (row multiplication) bugs** se bachata hai!
