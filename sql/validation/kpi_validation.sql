# HEADCOUNT TOTAL
set @YEAR_TOTAL_HEADCOUNT = "2012-12-31";

SELECT COUNT(DISTINCT employee_id) AS Total_Headcount
FROM mart_headcount
WHERE hire_date <= @YEAR_TOTAL_HEADCOUNT
AND (
    term_date IS NULL
    OR term_date > @YEAR_TOTAL_HEADCOUNT
);

#===============================================================

# Active Employees
SELECT
    COUNT(DISTINCT employee_id) AS active_employee_count
FROM mart_headcount
WHERE hire_date <= '2022-12-31'
AND (
        term_date IS NULL
        OR
        term_date > '2022-12-31'
    );

#===============================================================

# ATTRITION Rate /  TURNOVER %
WITH turnover_data AS (
SELECT 
	count(distinct employee_id) AS employees_left
from mart_turnover
where term_date BETWEEN "2013-01-01" AND "2013-12-31"
),

begin_hc AS (
select count(DISTINCT employee_id) as beginning_headcount
from mart_headcount
where hire_date <= "2012-01-01"
AND (
term_date is null
OR term_date > "2012-01-01")
),

end_hc AS (
select count(DISTINCT employee_id) as ending_headcount
from mart_headcount
where hire_date <= "2014-12-31"
AND (
term_date is null
OR term_date > "2014-12-31")
)

select
(employees_left * 100)
/
((beginning_headcount + ending_headcount)/2.0) AS turnover_percent
from turnover_data,
begin_hc,
end_hc;

#===============================================================

# RETENTION %
WITH beginning_emp AS (
    SELECT COUNT(DISTINCT employee_id) AS beginning_employees
    FROM mart_headcount
    WHERE hire_date <= '2012-01-01'
    AND (
        term_date IS NULL
        OR term_date > '2012-01-01'
    )
),

retained_emp AS (
    SELECT COUNT(DISTINCT employee_id) AS retained_employees
    FROM mart_headcount
    WHERE hire_date <= '2012-01-01'
    AND (
        term_date IS NULL
        OR term_date > '2012-12-31'
    )
)

SELECT (retained_employees * 100.0)
/ beginning_employees AS retention_percent
FROM beginning_emp,
     retained_emp;

#===============================================================

# Average Tenure
select
	ROUND(AVG(
	datediff(
	COALESCE(term_date, "2012-12-31"), hire_date)/365.25),2) AS avg_tenure_years
from mart_headcount
where hire_date <= "2012-12-31";

#===============================================================

# Average Salary
select 
	(avg(salary)/1000) AS avg_salary
from hr_marts.mart_compensation;

#===============================================================

# Median Salary
WITH salary_ranked AS (
    SELECT
        salary,
        ROW_NUMBER() OVER (
            ORDER BY salary
        ) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM mart_compensation
)
SELECT
    AVG(salary) AS median_salary
FROM salary_ranked
WHERE rn IN (
    FLOOR((total_rows + 1)/2),
    FLOOR((total_rows + 2)/2)
);

#===============================================================

# Salary Distribution Across Departments
SELECT
    department_name,
    sum(salary) as Total_Salary
FROM mart_compensation
GROUP BY department_name
ORDER BY Total_Salary desc;

#===============================================================

# YoY Growth %
with current_hc as (

select 
	count(DISTINCT employee_id) AS current_year_headcount
from mart_headcount
where hire_date <= "2013-12-31"
AND (
	term_date is null
	OR term_date > "2013-12-31"
	)
), 

previous_hc AS (
select 
	count(DISTINCT employee_id) as previous_year_headcount
from mart_headcount
where hire_date <= "2012-12-31" 
	AND (
	term_date is null
	OR term_date > "2012-12-31"
    )
)

select 
	(current_year_headcount - previous_year_headcount) * 100/ 
    (previous_year_headcount) AS yoy_headcount_growth_percent
from current_hc,
previous_hc;

#===============================================================

# Total Hires
SELECT count(DISTINCT employee_id)
FROM hr_marts.mart_headcount;

#===============================================================

# Avg Employees Per Manager
select
count(distinct employee_id)
/ count(distinct manager_l1)
from hr_marts.mart_employee_hierarchy_flat;

#===============================================================

# Total Managers
select
count(distinct manager_employee_id)
from mart_employee_hierarchy_flat
where manager_employee_id is not null;

#===============================================================

# Departing Employees
SELECT
    COUNT(DISTINCT employee_id)
        AS departing_employees
FROM mart_turnover
WHERE term_date BETWEEN
      '2012-01-01'
      AND
      '2022-12-31';
      
#================================================================

# Net Workforce
SELECT
(
SELECT count(DISTINCT employee_id)
FROM hr_marts.mart_headcount
)
-
(
SELECT
    COUNT(DISTINCT employee_id)
        AS departing_employees
FROM mart_turnover
WHERE term_date BETWEEN
      '2012-01-01'
      AND
      '2022-12-31'
)
AS Net_workforce;

#================================================================

# Early Attrition (Exit Analysis)
SELECT
    ROUND(COUNT(
            DISTINCT CASE
                WHEN DATEDIFF(term_date, hire_date) <= 365
                THEN employee_id
            END
        ) * 100.0
        /
        COUNT(DISTINCT employee_id),2) AS early_attrition_percent

FROM hr_marts.mart_turnover
WHERE term_date BETWEEN
      '2012-01-01'
      AND
      '2022-12-31';
      
#==================================================================

# Early Attrition (Workforce)
SELECT
    ROUND(COUNT(
            DISTINCT CASE
                WHEN DATEDIFF(term_date, hire_date) <= 365
                THEN employee_id
            END) * 100.0
        /
        COUNT(DISTINCT employee_id),2) AS early_attrition_percent

FROM hr_marts.mart_retention;

#===================================================================

# Voluntary Attrition
SELECT 
	Round(count(employee_id)*100 
    /
    (SELECT count(DISTINCT employee_id) 
    FROM mart_turnover), 2)
FROM mart_turnover
WHERE term_type = 'Voluntary' and 
	term_date between 
    '2012-01-01'
	AND
	'2022-12-31';
    
#=====================================================================

# Voluntary Attrition
SELECT 
	Round(count(employee_id)*100 
    /
    (SELECT count(DISTINCT employee_id) 
    FROM mart_turnover), 2)
FROM mart_turnover
WHERE term_type = 'Involuntary' and 
	term_date between 
    '2012-01-01'
	AND
	'2022-12-31';
    
#=====================================================================

# Average Span Of Control
SELECT
    ROUND(COUNT(DISTINCT employee_id) * 1.0
    /
    COUNT(DISTINCT manager_employee_id),2) AS span_of_control

FROM mart_employee_hierarchy_flat
WHERE manager_employee_id IS NOT NULL;

#=======================================================================

# Department Headcount
SELECT
    department_name,
    COUNT(DISTINCT employee_id)
        AS headcount
FROM mart_headcount
GROUP BY department_name
ORDER BY headcount DESC;

#=======================================================================

# Job Level Distribution
SELECT
    job_level_name,
    COUNT(DISTINCT employee_id)
        AS employees
FROM mart_headcount
GROUP BY job_level_name
ORDER BY employees DESC;

#=======================================================================

# Gender Distribution
SELECT
    gender,
    COUNT(DISTINCT employee_id)
        AS employees
FROM mart_headcount
GROUP BY gender;