-- Module 02: CTEs (WITH) & Subqueries — Verified Solutions (SQLite & MySQL 8+ compatible)

-- 1. Employees earning above their own department's average salary
WITH dept_avg AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.first_name, e.last_name, d.department_name, e.salary, ROUND(da.avg_salary, 2) AS dept_avg_salary
FROM employees e
JOIN dept_avg da ON da.department_id = e.department_id
JOIN departments d ON d.department_id = e.department_id
WHERE e.salary > da.avg_salary
ORDER BY d.department_name, e.salary DESC;

-- 2. Employees with total project hours > 150
WITH emp_hours AS (
    SELECT employee_id, SUM(hours_worked) AS total_hours
    FROM employee_projects
    GROUP BY employee_id
)
SELECT e.first_name, e.last_name, eh.total_hours
FROM employees e
JOIN emp_hours eh ON eh.employee_id = e.employee_id
WHERE eh.total_hours > 150
ORDER BY eh.total_hours DESC;

-- 3. Highest paid employee(s) per department
WITH dept_max AS (
    SELECT department_id, MAX(salary) AS max_salary
    FROM employees
    GROUP BY department_id
)
SELECT d.department_name, e.first_name, e.last_name, e.salary
FROM employees e
JOIN dept_max dm ON dm.department_id = e.department_id AND e.salary = dm.max_salary
JOIN departments d ON d.department_id = e.department_id
ORDER BY e.salary DESC;

-- 4. Projects with total hours above average project hours
WITH proj_hours AS (
    SELECT p.project_id, p.project_name, COALESCE(SUM(ep.hours_worked), 0) AS total_hours
    FROM projects p
    LEFT JOIN employee_projects ep ON ep.project_id = p.project_id
    GROUP BY p.project_id, p.project_name
)
SELECT project_name, total_hours
FROM proj_hours
WHERE total_hours > (SELECT AVG(total_hours) FROM proj_hours)
ORDER BY total_hours DESC;

-- 5. Salary difference from company average
WITH company_avg AS (
    SELECT AVG(salary) AS avg_sal FROM employees
)
SELECT e.first_name, e.last_name, e.salary,
       ROUND(e.salary - ca.avg_sal, 2) AS salary_diff
FROM employees e
CROSS JOIN company_avg ca
ORDER BY salary_diff DESC;

-- 6. Employees NOT assigned to any 'Active' project
SELECT e.first_name, e.last_name, e.job_title
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM employee_projects ep
    JOIN projects p ON p.project_id = ep.project_id
    WHERE ep.employee_id = e.employee_id AND p.status = 'Active'
)
ORDER BY e.employee_id;

-- 7. Locations with total salary bill > 200000
WITH loc_stats AS (
    SELECT d.location, COUNT(e.employee_id) AS emp_count, SUM(e.salary) AS total_bill
    FROM departments d
    JOIN employees e ON e.department_id = d.department_id
    GROUP BY d.location
)
SELECT location, emp_count, total_bill
FROM loc_stats
WHERE total_bill > 200000
ORDER BY total_bill DESC;

-- 8. Direct report count and average salary per manager
WITH mgr_stats AS (
    SELECT manager_id, COUNT(*) AS direct_reports, ROUND(AVG(salary), 2) AS avg_team_salary
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
)
SELECT m.first_name || ' ' || m.last_name AS manager_name,
       ms.direct_reports, ms.avg_team_salary
FROM mgr_stats ms
JOIN employees m ON m.employee_id = ms.manager_id
ORDER BY ms.direct_reports DESC;

-- 9. Project budget per hour worked (excluding 0-hour projects)
WITH proj_hours AS (
    SELECT p.project_id, p.project_name, p.budget, SUM(ep.hours_worked) AS total_hours
    FROM projects p
    JOIN employee_projects ep ON ep.project_id = p.project_id
    GROUP BY p.project_id, p.project_name, p.budget
)
SELECT project_name, budget, total_hours,
       ROUND(1.0 * budget / total_hours, 2) AS budget_per_hour
FROM proj_hours
WHERE total_hours > 0
ORDER BY budget_per_hour DESC;

-- 10. Top 3 highest-paid employees with department and total project hours
WITH emp_hours AS (
    SELECT employee_id, COALESCE(SUM(hours_worked), 0) AS total_hours
    FROM employee_projects
    GROUP BY employee_id
)
SELECT e.first_name, e.last_name, d.department_name, e.salary,
       COALESCE(eh.total_hours, 0) AS total_hours
FROM employees e
JOIN departments d ON d.department_id = e.department_id
LEFT JOIN emp_hours eh ON eh.employee_id = e.employee_id
ORDER BY e.salary DESC
LIMIT 3;
