-- Module 03 (Part 1): Window Functions — Verified Solutions (SQLite 3.25+ & MySQL 8+ compatible)

-- 1. Compare ROW_NUMBER(), RANK(), and DENSE_RANK() across company salaries
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       d.department_name,
       e.salary,
       ROW_NUMBER() OVER (ORDER BY e.salary DESC, e.employee_id ASC) AS row_num,
       RANK()       OVER (ORDER BY e.salary DESC) AS salary_rank,
       DENSE_RANK() OVER (ORDER BY e.salary DESC) AS dense_salary_rank
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY e.salary DESC, e.employee_id ASC;

-- 2. Top 2 highest-paid employees per department (preserving ties with DENSE_RANK)
WITH dept_ranked AS (
    SELECT d.department_name,
           e.first_name || ' ' || e.last_name AS employee_name,
           e.job_title,
           e.salary,
           DENSE_RANK() OVER (
               PARTITION BY e.department_id
               ORDER BY e.salary DESC
           ) AS dept_rank
    FROM employees e
    JOIN departments d ON d.department_id = e.department_id
)
SELECT department_name, employee_name, job_title, salary, dept_rank
FROM dept_ranked
WHERE dept_rank <= 2
ORDER BY department_name, dept_rank, salary DESC;

-- 3. Employee salary alongside department average, department max, and gap to max (without collapsing rows)
SELECT d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
       MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary,
       MAX(e.salary) OVER (PARTITION BY e.department_id) - e.salary AS gap_from_dept_max
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.salary DESC;

-- 4. Each employee's % share of their department's total payroll
SELECT d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       SUM(e.salary) OVER (PARTITION BY e.department_id) AS dept_total_payroll,
       ROUND(
           100.0 * e.salary / SUM(e.salary) OVER (PARTITION BY e.department_id),
           2
       ) AS payroll_share_pct
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, payroll_share_pct DESC;

-- 5. Seniority ranking by hire_date inside each department
SELECT d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.hire_date,
       ROW_NUMBER() OVER (
           PARTITION BY e.department_id
           ORDER BY e.hire_date ASC, e.employee_id ASC
       ) AS tenure_rank,
       CASE
           WHEN ROW_NUMBER() OVER (
               PARTITION BY e.department_id
               ORDER BY e.hire_date ASC, e.employee_id ASC
           ) = 1 THEN 'Department Pioneer'
           ELSE 'Team Member'
       END AS seniority_tag
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, tenure_rank;

-- 6. Divide employees into 4 compensation quartiles using NTILE(4)
WITH tiered AS (
    SELECT e.first_name || ' ' || e.last_name AS employee_name,
           d.department_name,
           e.salary,
           NTILE(4) OVER (ORDER BY e.salary DESC, e.employee_id ASC) AS quartile
    FROM employees e
    JOIN departments d ON d.department_id = e.department_id
)
SELECT employee_name,
       department_name,
       salary,
       quartile,
       CASE quartile
           WHEN 1 THEN 'Q1 - Top Tier'
           WHEN 2 THEN 'Q2 - Upper Mid'
           WHEN 3 THEN 'Q3 - Lower Mid'
           ELSE 'Q4 - Entry Tier'
       END AS comp_band
FROM tiered
ORDER BY quartile, salary DESC;

-- 7. Top contributor(s) by hours worked for each project
WITH project_ranks AS (
    SELECT p.project_name,
           p.status,
           e.first_name || ' ' || e.last_name AS employee_name,
           ep.hours_worked,
           RANK() OVER (
               PARTITION BY ep.project_id
               ORDER BY ep.hours_worked DESC
           ) AS contrib_rank
    FROM employee_projects ep
    JOIN projects p ON p.project_id = ep.project_id
    JOIN employees e ON e.employee_id = ep.employee_id
)
SELECT project_name, status, employee_name, hours_worked
FROM project_ranks
WHERE contrib_rank = 1
ORDER BY hours_worked DESC, project_name;

-- 8. Employee hours contribution % per project using window SUM()
SELECT p.project_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       ep.hours_worked,
       SUM(ep.hours_worked) OVER (PARTITION BY ep.project_id) AS project_total_hours,
       ROUND(
           100.0 * ep.hours_worked / SUM(ep.hours_worked) OVER (PARTITION BY ep.project_id),
           2
       ) AS project_contrib_pct
FROM employee_projects ep
JOIN projects p ON p.project_id = ep.project_id
JOIN employees e ON e.employee_id = ep.employee_id
ORDER BY p.project_name, ep.hours_worked DESC;

-- 9. City-wise (location) salary rank and location headcount
SELECT d.location,
       d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       COUNT(*) OVER (PARTITION BY d.location) AS location_headcount,
       DENSE_RANK() OVER (
           PARTITION BY d.location
           ORDER BY e.salary DESC
       ) AS location_salary_rank
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.location, location_salary_rank, e.employee_id;

-- 10. Interview Classic: 2nd highest salary employee(s) without LIMIT/OFFSET
WITH ranked_salaries AS (
    SELECT e.employee_id,
           e.first_name || ' ' || e.last_name AS employee_name,
           d.department_name,
           e.salary,
           DENSE_RANK() OVER (ORDER BY e.salary DESC) AS sal_rank
    FROM employees e
    JOIN departments d ON d.department_id = e.department_id
)
SELECT employee_id, employee_name, department_name, salary
FROM ranked_salaries
WHERE sal_rank = 2;
