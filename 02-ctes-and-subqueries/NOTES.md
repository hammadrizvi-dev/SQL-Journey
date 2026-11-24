# Module 02: CTEs (`WITH`) & Subqueries — Quick Revision Notes

## CTE (`WITH`) kyun use karte hain?
- Jab ek query me **2 steps** chahiye (pehle aggregate/average nikalo, phir us par filter ya join karo), to nested subquery padhne me mushkil hoti hai.
- **CTE (`WITH temp_name AS (...)`)** ek temporary named table bana deta hai jo sirf us query ke liye chalta hai. Code clean aur interview-friendly lagta hai!

## 4 Interview Patterns Jo Is Module Me Seekhe
1. **Group Average se Compare Karna (Q1, Q4):**
   - Pehle CTE me `GROUP BY` karke `AVG` nikalo, phir main query me `JOIN` karke `WHERE e.salary > da.avg_salary`.
2. **Per-Group Maximum Row Nikalna (Q3):**
   - CTE me `MAX(salary)` per department nikalo, phir `JOIN` on `department_id AND salary = max_salary`. (Tie hone par dono rows mil jaati hain!)
3. **`NOT EXISTS` Pattern (Q6):**
   - "Kaun log kisi Active project par nahi hain?" — `NOT IN` me `NULL` values ki wajah se bug aa sakta hai; **`NOT EXISTS` hamesha safer hota hai**.
4. **Integer Division Bug se Bachna (Q9):**
   - SQLite me `500000 / 300` integer division karta hai (decimal kat jata hai). `1.0 * budget / total_hours` likhne se exact decimal milta hai!
