-- queries.sql — SQL Analytics Lab
-- Module 3: SQL & Relational Data
--
-- Instructions:
--   Write your SQL query beneath each comment block.
--   Do NOT modify the comment markers (-- Q1, -- Q2, etc.) — the autograder uses them.
--   Test each query locally: psql -h localhost -U postgres -d testdb -f queries.sql
--
-- ============================================================

-- Q1: Employee Directory with Departments
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id
ORDER BY 
    d.name ASC,
    e.salary DESC;


-- Q2: Department Salary Analysis
SELECT 
    d.name AS department_name,
    SUM(e.salary) AS total_salary
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id
GROUP BY d.name
HAVING SUM(e.salary) > 150000;


-- Q3: Highest-Paid Employee per Department
SELECT *
FROM (
    SELECT 
        e.name AS employee_name,
        d.name AS department_name,
        e.salary,
        ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rn
    FROM employees e
    JOIN departments d
        ON e.dept_id = d.dept_id
) sub
WHERE rn = 1;


-- Q4: Project Staffing Overview
SELECT 
    p.name AS project_name,
    COUNT(pa.emp_id) AS num_employees,
    COALESCE(SUM(pa.hours_allocated), 0) AS total_hours
FROM projects p
LEFT JOIN project_assignments pa
    ON p.project_id = pa.project_id
GROUP BY p.name;


-- Q5: Above-Average Departments
WITH company_avg AS (
    SELECT AVG(salary) AS avg_salary
    FROM employees
)
SELECT 
    d.name AS department_name,
    AVG(e.salary) AS dept_avg_salary,
    c.avg_salary AS company_avg_salary
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id
CROSS JOIN company_avg c
GROUP BY d.name, c.avg_salary
HAVING AVG(e.salary) > c.avg_salary;


-- Q6: Running Salary Total
SELECT 
    e.name AS employee_name,
    d.name AS department_name,
    e.salary,
    SUM(e.salary) OVER (
        PARTITION BY e.dept_id
        ORDER BY e.hire_date
        ROWS UNBOUNDED PRECEDING
    ) AS running_total_salary
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id
ORDER BY d.name, e.hire_date;


-- Q7: Unassigned Employees
SELECT 
    e.name AS employee_name,
    d.name AS department_name
FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id
LEFT JOIN project_assignments pa
    ON e.emp_id = pa.emp_id
WHERE pa.emp_id IS NULL;


-- Q8: Hiring Trends
WITH monthly_hires AS (
    SELECT 
        EXTRACT(YEAR FROM hire_date) AS hire_year,
        EXTRACT(MONTH FROM hire_date) AS hire_month,
        COUNT(*) AS num_hires
    FROM employees
    GROUP BY hire_year, hire_month
)
SELECT *
FROM monthly_hires
ORDER BY hire_year, hire_month;


-- Q9: Schema Design — Employee Certifications
-- Design and implement a certifications tracking system.
--
-- Tasks:
-- 1. CREATE TABLE certifications (certification_id SERIAL PK, name VARCHAR NOT NULL, issuing_org VARCHAR, level VARCHAR)
CREATE TABLE certifications (
    certification_id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    issuing_org VARCHAR,
    level VARCHAR
);
-- 2. CREATE TABLE employee_certifications (id SERIAL PK, employee_id FK->employees, certification_id FK->certifications, certification_date DATE NOT NULL)
CREATE TABLE employee_certifications (
    id SERIAL PRIMARY KEY,
    emp_id INT REFERENCES employees(emp_id),
    certification_id INT REFERENCES certifications(certification_id),
    certification_date DATE NOT NULL
);
-- 3. INSERT at least 3 certifications and 5 employee_certification records
INSERT INTO certifications (name, issuing_org, level) VALUES
('Python Basics', 'Coursera', 'Beginner'),
('Project Management', 'PMI', 'Intermediate'),
('Data Analysis', 'Udemy', 'Advanced');

INSERT INTO employee_certifications (emp_id, certification_id, certification_date) VALUES
(1, 1, '2023-01-15'),
(2, 1, '2023-02-10'),
(3, 2, '2023-03-05'),
(4, 3, '2023-01-20'),
(5, 2, '2023-02-28');


-- 4. Write a query listing employees with their certifications (JOIN across 3 tables)
SELECT 
    e.name AS employee_name,
    c.name AS certification_name,
    c.issuing_org,
    ec.certification_date
FROM employee_certifications ec
JOIN employees e ON ec.emp_id = e.emp_id
JOIN certifications c ON ec.certification_id = c.certification_id;

--    Expected columns: first_name, last_name, certification_name, issuing_org, certification_date
