-- MySQL 8+ Solutions for 18 Practice Exercises
USE sql_journey;

-- 1. All employees with name and job title
SELECT first_name, last_name, job_title FROM employees;

-- 2. Only Engineering department employees
SELECT e.*
FROM employees e
JOIN departments d ON d.department_id = e.department_id
WHERE d.department_name = 'Engineering';

-- 3. Salary descending
SELECT first_name, last_name, salary FROM employees ORDER BY salary DESC;

-- 4. Salary >= 100000
SELECT first_name, last_name, salary FROM employees WHERE salary >= 100000;

-- 5. Unique job titles
SELECT DISTINCT job_title FROM employees ORDER BY job_title;

-- 6. Average company salary
SELECT ROUND(AVG(salary), 2) AS average_salary FROM employees;

-- 7. Employee count per department
SELECT d.department_name, COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- 8. Average salary per department
SELECT d.department_name, ROUND(AVG(e.salary), 2) AS average_salary
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- 9. Departments with avg salary > 100000
SELECT d.department_name, ROUND(AVG(e.salary), 2) AS average_salary
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING AVG(e.salary) > 100000;

-- 10. Employee name + department name
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON d.department_id = e.department_id;

-- 11. Employees and hours per project
SELECT p.project_name, e.first_name, e.last_name, ep.hours_worked
FROM employee_projects ep
JOIN employees e ON e.employee_id = ep.employee_id
JOIN projects p ON p.project_id = ep.project_id
ORDER BY p.project_name, ep.hours_worked DESC;

-- 12. Departments with no employees
SELECT d.department_name
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;

-- 13. Employee with manager name (Self Join - MySQL CONCAT)
SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee,
       COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'No manager') AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id;

-- 14. Highest paid employee
SELECT * FROM employees WHERE salary = (SELECT MAX(salary) FROM employees);

-- 15. Total hours per project (including 0 hours)
SELECT p.project_name, COALESCE(SUM(ep.hours_worked), 0) AS total_hours
FROM projects p
LEFT JOIN employee_projects ep ON ep.project_id = p.project_id
GROUP BY p.project_id, p.project_name;

-- 16. Salary bands using CASE
SELECT first_name, last_name, salary,
       CASE
           WHEN salary < 100000 THEN 'Low'
           WHEN salary < 140000 THEN 'Medium'
           ELSE 'High'
       END AS salary_band
FROM employees;

-- 17. Hired after 2022
SELECT * FROM employees WHERE hire_date > '2022-12-31';

-- 18. Salary above company average
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
