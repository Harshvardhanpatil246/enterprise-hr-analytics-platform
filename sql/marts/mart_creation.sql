# Analytics Mart Engineering

# CREATE MART SCHEMA
CREATE SCHEMA hr_marts;

# MART 1 — mart_headcount
CREATE TABLE hr_marts.mart_headcount AS

SELECT
    fe.employment_key,
    fe.employee_key,
    fe.department_key,
    de.location_key,
    fe.job_level_key,
    de.employee_id,
    de.first_name,
    de.last_name,
    de.gender,
    de.race,
    de.education,
    de.marital_status,
    de.employment_status,
    dl.location,
    dl.city_name,
    dd.department_name,
    dd.sub_department_name,
    djl.job_level_name,
    fe.salary,
    fe.hire_date,
    fe.term_date,
    fe.active_status

FROM hr_warehouse.fact_employment fe

LEFT JOIN hr_warehouse.dim_employee de
    ON fe.employee_key = de.employee_key

LEFT JOIN hr_warehouse.dim_department dd
    ON fe.department_key = dd.department_key

LEFT JOIN hr_warehouse.dim_location dl
    ON de.location_key = dl.location_key

LEFT JOIN hr_warehouse.dim_job_level djl
    ON fe.job_level_key = djl.job_level_key;
    
    
    
# MART 2 — mart_turnover
CREATE TABLE hr_marts.mart_turnover AS

SELECT
    fe.employment_key,
	fe.employee_key,
    fe.department_key,
    de.location_key,
    fe.job_level_key,
    de.employee_id,
    dd.department_name,
    ehf.manager_name,
    ehf.manager_employee_id,
    djl.job_level_name,
    dl.location,
    dl.city_name,
    de.gender,
    de.race,
    fe.hire_date,
    fe.term_date,
    fe.term_type,
    fe.term_reason,
    fe.salary,

    TIMESTAMPDIFF(
        YEAR,
        fe.hire_date,
        COALESCE(fe.term_date, '2022-12-31')
    ) AS tenure_years

FROM hr_warehouse.fact_employment fe

LEFT JOIN hr_warehouse.dim_employee de
    ON fe.employee_key = de.employee_key

LEFT JOIN hr_warehouse.dim_department dd
    ON fe.department_key = dd.department_key

LEFT JOIN hr_warehouse.dim_job_level djl
    ON fe.job_level_key = djl.job_level_key

LEFT JOIN hr_warehouse.dim_location dl
    ON de.location_key = dl.location_key
    
LEFT JOIN mart_employee_hierarchy_flat ehf
	ON fe.employee_key = ehf.employee_key

WHERE fe.term_date IS NOT NULL;


# MART 3 — mart_retention
CREATE TABLE hr_marts.mart_retention AS

SELECT
    de.employee_id,
    fe.employee_key,
    fe.department_key,
    de.location_key,
    fe.job_level_key,
    dd.department_name,
    djl.job_level_name,
    dl.location,
    de.gender,
    de.race,
    fe.hire_date,
    fe.term_date,
    fe.active_status,
    TIMESTAMPDIFF(
        YEAR,
        fe.hire_date,
        '2022-12-31'
    ) AS current_tenure

FROM hr_warehouse.fact_employment fe

LEFT JOIN hr_warehouse.dim_employee de
    ON fe.employee_key = de.employee_key

LEFT JOIN hr_warehouse.dim_department dd
    ON fe.department_key = dd.department_key

LEFT JOIN hr_warehouse.dim_job_level djl
    ON fe.job_level_key = djl.job_level_key

LEFT JOIN hr_warehouse.dim_location dl
    ON de.location_key = dl.location_key;



# MART 4 — mart_employee_hierarchy
CREATE TABLE hr_marts.mart_employee_hierarchy AS

SELECT
    emp.employee_id,
    CONCAT(emp.first_name, ' ', emp.last_name)
    AS employee_name,
    mgr1.employee_id AS manager_l1,
    mgr2.employee_id AS manager_l2,
    mgr3.employee_id AS manager_l3

FROM hr_warehouse.dim_employee emp

LEFT JOIN hr_warehouse.bridge_employee_relationship r1
    ON emp.employee_key = r1.employee_key

LEFT JOIN hr_warehouse.dim_employee mgr1
    ON r1.manager_employee_key = mgr1.employee_key

LEFT JOIN hr_warehouse.bridge_employee_relationship r2
    ON mgr1.employee_key = r2.employee_key

LEFT JOIN hr_warehouse.dim_employee mgr2
    ON r2.manager_employee_key = mgr2.employee_key

LEFT JOIN hr_warehouse.bridge_employee_relationship r3
    ON mgr2.employee_key = r3.employee_key

LEFT JOIN hr_warehouse.dim_employee mgr3
    ON r3.manager_employee_key = mgr3.employee_key;
    
    
    
    
# MART 5 — mart_diversity
CREATE TABLE hr_marts.mart_diversity AS

SELECT
    de.gender,
    de.race,
    dd.department_name,
    djl.job_level_name,
    COUNT(*) AS employee_count

FROM hr_warehouse.fact_employment fe

LEFT JOIN hr_warehouse.dim_employee de
    ON fe.employee_key = de.employee_key

LEFT JOIN hr_warehouse.dim_department dd
    ON fe.department_key = dd.department_key

LEFT JOIN hr_warehouse.dim_job_level djl
    ON fe.job_level_key = djl.job_level_key

GROUP BY
    de.gender,
    de.race,
    dd.department_name,
    djl.job_level_name;


# MART 6 — mart_compensation
CREATE TABLE hr_marts.mart_compensation AS

SELECT
    de.employee_id,
    fe.employee_key,
    fe.department_key,
    de.location_key,
    fe.job_level_key,
    dd.department_name,
    djl.job_level_name,
    fe.hire_date,
    dl.location,
    fe.salary,

    CASE
        WHEN fe.salary >= 50000
        THEN 'High Income'

        WHEN fe.salary >= 30000
        THEN 'Mid Income'

        ELSE 'Standard Income'
    END AS salary_band

FROM hr_warehouse.fact_employment fe

LEFT JOIN hr_warehouse.dim_employee de
    ON fe.employee_key = de.employee_key

LEFT JOIN hr_warehouse.dim_department dd
    ON fe.department_key = dd.department_key

LEFT JOIN hr_warehouse.dim_job_level djl
    ON fe.job_level_key = djl.job_level_key

LEFT JOIN hr_warehouse.dim_location dl
    ON de.location_key = dl.location_key;




# mart_employee_hierarchy_flat
CREATE TABLE hr_marts.mart_employee_hierarchy_flat AS

SELECT
    emp.employee_key,
    emp.employee_id,
    CONCAT(
        emp.first_name,
        ' ',
        emp.last_name
    ) AS employee_name,
    mgr.employee_key AS manager_employee_key,
    mgr.employee_id AS manager_employee_id,
    CONCAT(
        mgr.first_name,
        ' ',
        mgr.last_name
    ) AS manager_name,
    fe.department_key,
    dept.department_name,
    fe.location_key,
    loc.location,
    fe.job_level_key,
    jl.job_level_name,
    fe.hire_date,
    fe.term_date,
    fe.active_status,

    CASE
        WHEN mgr.employee_key IS NULL
            THEN 'Executive'
        ELSE 'Managed Employee'
    END AS hierarchy_type

FROM hr_warehouse.bridge_employee_relationship br

JOIN hr_warehouse.dim_employee emp
    ON br.employee_key = emp.employee_key

LEFT JOIN hr_warehouse.dim_employee mgr
    ON br.manager_employee_key = mgr.employee_key

LEFT JOIN hr_warehouse.fact_employment fe
    ON emp.employee_key = fe.employee_key

LEFT JOIN hr_warehouse.dim_department dept
    ON fe.department_key = dept.department_key

LEFT JOIN hr_warehouse.dim_location loc
    ON fe.location_key = loc.location_key

LEFT JOIN hr_warehouse.dim_job_level jl
    ON fe.job_level_key = jl.job_level_key;