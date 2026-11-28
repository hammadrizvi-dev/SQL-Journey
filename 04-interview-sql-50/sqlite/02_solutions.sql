-- Module 04 (Batch 1): Interview SQL 50 — Verified Solutions (SQLite 3.25+ & MySQL 8+ compatible)

-- 1. Employees earning more than their own manager
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary AS employee_salary,
       m.first_name || ' ' || m.last_name AS manager_name,
       m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary
ORDER BY e.salary DESC;

-- 2. Salary percentile rank & cumulative distribution within each department
SELECT d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       ROUND(PERCENT_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary ASC), 2) AS pct_rank,
       ROUND(CUME_DIST()    OVER (PARTITION BY e.department_id ORDER BY e.salary ASC), 2) AS cume_dist
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.salary DESC;

-- 3. Gap to the next higher-paid colleague in the same department using LAG()
SELECT d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       LAG(e.salary) OVER (
           PARTITION BY e.department_id
           ORDER BY e.salary DESC, e.employee_id ASC
       ) AS next_higher_salary,
       COALESCE(
           LAG(e.salary) OVER (
               PARTITION BY e.department_id
               ORDER BY e.salary DESC, e.employee_id ASC
           ) - e.salary,
           0
       ) AS gap_to_next_higher
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.salary DESC;

-- 4. Cumulative department payroll % in descending salary order
SELECT d.department_name,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary,
       SUM(e.salary) OVER (
           PARTITION BY e.department_id
           ORDER BY e.salary DESC, e.employee_id ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS running_dept_payroll,
       ROUND(
           100.0 * SUM(e.salary) OVER (
               PARTITION BY e.department_id
               ORDER BY e.salary DESC, e.employee_id ASC
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) / SUM(e.salary) OVER (PARTITION BY e.department_id),
           2
       ) AS cumulative_payroll_pct
FROM employees e
JOIN departments d ON d.department_id = e.department_id
ORDER BY d.department_name, e.salary DESC, e.employee_id ASC;

-- 5. Projects exceeding the average total logged hours across all projects
WITH project_hours AS (
    SELECT p.project_id,
           p.project_name,
           p.status,
           COALESCE(SUM(ep.hours_worked), 0) AS total_hours
    FROM projects p
    LEFT JOIN employee_projects ep ON ep.project_id = p.project_id
    GROUP BY p.project_id, p.project_name, p.status
),
avg_hours AS (
    SELECT AVG(total_hours) AS company_avg_hours FROM project_hours
)
SELECT ph.project_name,
       ph.status,
       ph.total_hours,
       ROUND(ah.company_avg_hours, 2) AS avg_project_hours
FROM project_hours ph
CROSS JOIN avg_hours ah
WHERE ph.total_hours > ah.company_avg_hours
ORDER BY ph.total_hours DESC;

-- 6. Relational Division: Employees assigned to ALL 'Active' projects
WITH active_project_count AS (
    SELECT COUNT(*) AS req_count
    FROM projects
    WHERE status = 'Active'
),
emp_active_projects AS (
    SELECT ep.employee_id,
           COUNT(DISTINCT ep.project_id) AS active_count
    FROM employee_projects ep
    JOIN projects p ON p.project_id = ep.project_id
    WHERE p.status = 'Active'
    GROUP BY ep.employee_id
)
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.job_title,
       eap.active_count AS active_projects_covered
FROM emp_active_projects eap
JOIN employees e ON e.employee_id = eap.employee_id
CROSS JOIN active_project_count apc
WHERE eap.active_count = apc.req_count
ORDER BY e.employee_id;

-- 7. Departments where EVERY employee earns at least 90,000
SELECT d.department_name,
       COUNT(e.employee_id) AS headcount,
       MIN(e.salary) AS min_salary,
       MAX(e.salary) AS max_salary
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING MIN(e.salary) >= 90000
ORDER BY min_salary DESC;

-- 8. Hiring timeline with cumulative company headcount
SELECT hire_date,
       first_name || ' ' || last_name AS employee_name,
       job_title,
       COUNT(*) OVER (
           ORDER BY hire_date ASC, employee_id ASC
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS cumulative_headcount
FROM employees
ORDER BY hire_date ASC, employee_id ASC;

-- 9. Same-department colleague pairs earning within 15,000 of each other (no duplicates)
SELECT d.department_name,
       e1.first_name || ' ' || e1.last_name AS employee_1,
       e1.salary AS salary_1,
       e2.first_name || ' ' || e2.last_name AS employee_2,
       e2.salary AS salary_2,
       ABS(e1.salary - e2.salary) AS salary_diff
FROM employees e1
JOIN employees e2
    ON e1.department_id = e2.department_id
   AND e1.employee_id < e2.employee_id
JOIN departments d ON d.department_id = e1.department_id
WHERE ABS(e1.salary - e2.salary) <= 15000
ORDER BY d.department_name, salary_diff ASC;

-- 10. Project utilization summary preserving zero-hour projects
SELECT p.project_name,
       p.status,
       p.budget,
       COUNT(ep.employee_id) AS assigned_staff,
       COALESCE(SUM(ep.hours_worked), 0) AS total_hours,
       CASE
           WHEN COALESCE(SUM(ep.hours_worked), 0) >= 300 THEN 'High Utilization'
           WHEN COALESCE(SUM(ep.hours_worked), 0) >= 100 THEN 'Moderate Utilization'
           ELSE 'Low / Unstarted'
       END AS utilization_tier
FROM projects p
LEFT JOIN employee_projects ep ON ep.project_id = p.project_id
GROUP BY p.project_id, p.project_name, p.status, p.budget
ORDER BY total_hours DESC;

-- 11. Second most senior employee in each department
WITH seniority AS (
    SELECT d.department_name,
           e.first_name || ' ' || e.last_name AS employee_name,
           e.hire_date,
           ROW_NUMBER() OVER (
               PARTITION BY e.department_id
               ORDER BY e.hire_date ASC, e.employee_id ASC
           ) AS seniority_rank
    FROM employees e
    JOIN departments d ON d.department_id = e.department_id
)
SELECT department_name, employee_name, hire_date
FROM seniority
WHERE seniority_rank = 2
ORDER BY department_name;

-- 12. Multi-CTE Executive Department Dashboard
WITH dept_stats AS (
    SELECT d.department_id,
           d.department_name,
           d.location,
           COUNT(e.employee_id) AS headcount,
           COALESCE(SUM(e.salary), 0) AS total_payroll
    FROM departments d
    LEFT JOIN employees e ON e.department_id = d.department_id
    GROUP BY d.department_id, d.department_name, d.location
),
top_earners AS (
    SELECT department_id,
           first_name || ' ' || last_name AS top_earner,
           ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC, employee_id ASC) AS rn
    FROM employees
),
active_hours AS (
    SELECT e.department_id,
           COALESCE(SUM(ep.hours_worked), 0) AS active_project_hours
    FROM employees e
    JOIN employee_projects ep ON ep.employee_id = e.employee_id
    JOIN projects p ON p.project_id = ep.project_id
    WHERE p.status = 'Active'
    GROUP BY e.department_id
)
SELECT ds.department_name,
       ds.location,
       ds.headcount,
       ds.total_payroll,
       COALESCE(te.top_earner, 'N/A') AS top_earner,
       COALESCE(ah.active_project_hours, 0) AS active_project_hours
FROM dept_stats ds
LEFT JOIN top_earners te ON te.department_id = ds.department_id AND te.rn = 1
LEFT JOIN active_hours ah ON ah.department_id = ds.department_id
ORDER BY ds.total_payroll DESC;
