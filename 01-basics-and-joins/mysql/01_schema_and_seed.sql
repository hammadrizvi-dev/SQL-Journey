-- MySQL 8+ Schema and Seed Data
-- Run: mysql -u root -p < 01_schema_and_seed.sql

CREATE DATABASE IF NOT EXISTS sql_journey;
USE sql_journey;

DROP TABLE IF EXISTS employee_projects;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    location VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    salary INT NOT NULL CHECK (salary > 0),
    hire_date DATE NOT NULL,
    manager_id INT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(120) NOT NULL UNIQUE,
    budget INT NOT NULL CHECK (budget > 0),
    status ENUM('Planned', 'Active', 'Completed') NOT NULL
);

CREATE TABLE employee_projects (
    employee_id INT NOT NULL,
    project_id INT NOT NULL,
    hours_worked INT NOT NULL CHECK (hours_worked >= 0),
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

INSERT INTO departments VALUES
    (1, 'Engineering', 'Lahore'),
    (2, 'Sales', 'Karachi'),
    (3, 'Human Resources', 'Islamabad'),
    (4, 'Finance', 'Lahore'),
    (5, 'Design', 'Remote');

INSERT INTO employees VALUES
    (1, 'Ayesha', 'Khan', 'ayesha.khan@example.com', 1, 'Engineering Manager', 180000, '2020-01-15', NULL),
    (2, 'Bilal', 'Ahmed', 'bilal.ahmed@example.com', 1, 'Senior Developer', 150000, '2021-03-10', 1),
    (3, 'Sara', 'Malik', 'sara.malik@example.com', 1, 'Developer', 110000, '2022-07-01', 1),
    (4, 'Hamza', 'Raza', 'hamza.raza@example.com', 2, 'Sales Manager', 140000, '2019-11-20', NULL),
    (5, 'Noor', 'Ali', 'noor.ali@example.com', 2, 'Sales Executive', 85000, '2023-02-14', 4),
    (6, 'Usman', 'Tariq', 'usman.tariq@example.com', 2, 'Sales Executive', 90000, '2022-09-05', 4),
    (7, 'Hira', 'Shah', 'hira.shah@example.com', 3, 'HR Specialist', 95000, '2021-06-18', NULL),
    (8, 'Omar', 'Iqbal', 'omar.iqbal@example.com', 4, 'Accountant', 105000, '2020-08-25', NULL),
    (9, 'Maha', 'Siddiqui', 'maha.siddiqui@example.com', 5, 'UI Designer', 100000, '2023-05-12', NULL),
    (10, 'Daniyal', 'Hussain', 'daniyal.hussain@example.com', 1, 'QA Engineer', 100000, '2024-01-08', 1);

INSERT INTO projects VALUES
    (1, 'E-commerce Platform', 500000, 'Active'),
    (2, 'Mobile Banking App', 750000, 'Active'),
    (3, 'HR Portal', 200000, 'Completed'),
    (4, 'Brand Redesign', 150000, 'Planned');

INSERT INTO employee_projects VALUES
    (1, 1, 120), (1, 2, 80), (2, 1, 160), (2, 2, 100),
    (3, 1, 140), (3, 3, 60), (4, 1, 40), (4, 2, 50),
    (5, 1, 90), (6, 2, 110), (7, 3, 130), (9, 4, 75),
    (10, 1, 100);
