# Module 01: SQL Basics, Aggregates & Joins — Quick Revision Notes

Ye notes quick revision ke liye hain taaki bina double mehnat ke har concept yaad rahe.

## Key Concepts Covered (18 Queries)

1. **`SELECT`, `WHERE`, `ORDER BY`, `DISTINCT`** (Q1–Q5)
   - `WHERE` rows ko filter karta hai grouping se pehle.
   - `DISTINCT` duplicate values hatata hai.
2. **Aggregates & `GROUP BY` / `HAVING`** (Q6–Q9)
   - `AVG`, `COUNT`, `SUM`, `MAX` group par kaam karte hain.
   - **Interview rule:** `WHERE` individual rows filter karta hai; `HAVING` grouped results (`AVG(salary) > 100000`) filter karta hai.
3. **`INNER JOIN` vs `LEFT JOIN`** (Q10–Q12, Q15)
   - `LEFT JOIN` left table ki saari rows rakhta hai, chahe match na mile (missing side `NULL` hoti hai).
   - "Jahan koi match nahi hai" dhoondhne ke liye: `LEFT JOIN ... WHERE right_table.id IS NULL` (Q12).
4. **Self Join** (Q13)
   - Ek hi table ko khud se join karna (jaise `employees e` ko `employees m` se `manager_id` par).
   - `COALESCE(val, 'No manager')` `NULL` ko readable text se replace karta hai.
   - **SQLite vs MySQL difference:** SQLite me string jodna `||` se hota hai; MySQL me `CONCAT(a, ' ', b)` use hota hai.
5. **Subqueries & `CASE WHEN`** (Q14, Q16, Q18)
   - Subquery: query ke andar query (`WHERE salary > (SELECT AVG(salary) FROM employees)`).
   - `CASE WHEN`: SQL ka `if-elif-else`, buckets/labels banane ke kaam aata hai.
