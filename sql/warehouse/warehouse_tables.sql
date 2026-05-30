USE hr_warehouse;


# CREATE DIMENSION TABLES
# Based on Dimension dependency order 

# DIM 1 — dim_location
CREATE TABLE hr_warehouse.dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(255),
    city_name VARCHAR(255)
);

# LOAD dim_location
INSERT INTO hr_warehouse.dim_location (
    location,
    city_name
)
SELECT DISTINCT
    location,
    location_city
FROM hr_analytics.clean_people_data;


#==========================================================
# DIM 2 — dim_department
CREATE TABLE hr_warehouse.dim_department (
    department_key INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(255),
    sub_department_name VARCHAR(255)
);

# LOAD dim_department
INSERT INTO hr_warehouse.dim_department (
    department_name,
    sub_department_name
)
SELECT DISTINCT
    department,
    sub_department
FROM hr_analytics.clean_people_employment_history;
#==========================================================

# DIM 3 — dim_job_level
CREATE TABLE hr_warehouse.dim_job_level (
    job_level_key INT AUTO_INCREMENT PRIMARY KEY,
    job_level_name VARCHAR(255)
);

# LOAD dim_job_level
INSERT INTO hr_warehouse.dim_job_level (
    job_level_name
)
SELECT DISTINCT
    job_level
FROM hr_analytics.clean_people_employment_history;
#==========================================================

# DIM 4 — dim_employee
CREATE TABLE hr_warehouse.dim_employee (
    employee_key INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(50),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    gender VARCHAR(50),
    race VARCHAR(100),
    birth_date DATE,
    education VARCHAR(255),
    marital_status VARCHAR(100),
    employment_status VARCHAR(100),
    location_key INT,
    is_org_root BOOLEAN,

    FOREIGN KEY (location_key)
    REFERENCES hr_warehouse.dim_location(location_key)
);

# LOAD dim_employee
INSERT INTO hr_warehouse.dim_employee (
    employee_id,
    first_name,
    last_name,
    gender,
    race,
    birth_date,
    education,
    marital_status,
    employment_status,
    location_key,
    is_org_root
)

SELECT DISTINCT
    pd.employee_id,
    peh.first_name,
    peh.last_name,
    pd.gender,
    pd.race,
    pd.birth_date,
    pd.education,
    pd.marital_status,
    pd.employment_status,
    dl.location_key,

    CASE
        WHEN peh.first_level_manager IS NULL
        THEN 1
        ELSE 0
    END AS is_org_root

FROM hr_analytics.clean_people_data pd

LEFT JOIN hr_analytics.clean_people_employment_history peh
    ON pd.employee_id = peh.employee_id

LEFT JOIN hr_warehouse.dim_location dl
    ON pd.location = dl.location
    AND pd.location_city = dl.city_name;
#==========================================================


# CREATE RECURSIVE RELATIONSHIP TABLE
# models: direct reporting relationship only.
CREATE TABLE hr_warehouse.bridge_employee_relationship (
    relationship_key INT AUTO_INCREMENT PRIMARY KEY,
    employee_key INT,
    manager_employee_key INT,

    FOREIGN KEY (employee_key)
    REFERENCES hr_warehouse.dim_employee(employee_key),

    FOREIGN KEY (manager_employee_key)
    REFERENCES hr_warehouse.dim_employee(employee_key)
);


# LOAD RELATIONSHIP TABLE
INSERT INTO hr_warehouse.bridge_employee_relationship (
    employee_key,
    manager_employee_key
)
SELECT
    emp.employee_key,
    mgr.employee_key

FROM hr_analytics.clean_people_employment_history peh

JOIN hr_warehouse.dim_employee emp
    ON peh.employee_id = emp.employee_id

LEFT JOIN hr_warehouse.dim_employee mgr
    ON peh.first_level_manager = mgr.employee_id;
    
#==========================================================

# CREATE FACT TABLE
CREATE TABLE hr_warehouse.fact_employment (
    employment_key INT AUTO_INCREMENT PRIMARY KEY,
    employee_key INT,
    department_key INT,
    job_level_key INT,
    location_key INT,
    salary DECIMAL(12,2),
    hire_date DATE,
    term_date DATE,
    term_type VARCHAR(100),
    term_reason VARCHAR(255),
    active_status VARCHAR(50),

    FOREIGN KEY (employee_key)
    REFERENCES hr_warehouse.dim_employee(employee_key),

    FOREIGN KEY (department_key)
    REFERENCES hr_warehouse.dim_department(department_key),

    FOREIGN KEY (job_level_key)
    REFERENCES hr_warehouse.dim_job_level(job_level_key),
    
    FOREIGN KEY (location_key)
	REFERENCES hr_warehouse.dim_location(location_key)
);

# LOAD FACT TABLE
INSERT INTO hr_warehouse.fact_employment (
    employee_key,
    department_key,
    job_level_key,
    location_key,
    salary,
    hire_date,
    term_date,
    term_type,
    term_reason,
    active_status
)

SELECT
    de.employee_key,
    dd.department_key,
    djl.job_level_key,
    dl.location_key,
    peh.salary,
    peh.hire_date,
    peh.term_date,
    peh.term_type,
    peh.term_reason,
    peh.active_status

FROM hr_analytics.clean_people_employment_history peh

LEFT JOIN hr_warehouse.dim_employee de
    ON peh.employee_id = de.employee_id

LEFT JOIN hr_warehouse.dim_department dd
    ON peh.department = dd.department_name
    AND peh.sub_department = dd.sub_department_name

LEFT JOIN hr_warehouse.dim_job_level djl
    ON peh.job_level = djl.job_level_name

LEFT JOIN hr_analytics.clean_people_data pd
    ON peh.employee_id = pd.employee_id

LEFT JOIN hr_warehouse.dim_location dl
    ON pd.location = dl.location
    AND pd.location_city = dl.city_name;

#==========================================================

# CREATE LOAD AUDIT TABLE
CREATE TABLE hr_warehouse.etl_load_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(255),
    rows_loaded INT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

# INSERT AUDIT RECORDS
# dim_employee
INSERT INTO hr_warehouse.etl_load_audit (
    table_name,
    rows_loaded
)
SELECT
    'dim_employee',
    COUNT(*)
FROM hr_warehouse.dim_employee;


# dim_location
INSERT INTO hr_warehouse.etl_load_audit (
    table_name,
    rows_loaded
)
SELECT
    'dim_location',
    COUNT(*)
FROM hr_warehouse.dim_location;


# dim_department
INSERT INTO hr_warehouse.etl_load_audit (
    table_name,
    rows_loaded
)
SELECT
    'dim_department',
    COUNT(*)
FROM hr_warehouse.dim_department;


# dim_job_level
INSERT INTO hr_warehouse.etl_load_audit (
    table_name,
    rows_loaded
)
SELECT
    'dim_job_level',
    COUNT(*)
FROM hr_warehouse.dim_job_level;

# bridge_employee_relationship
INSERT INTO hr_warehouse.etl_load_audit (
    table_name,
    rows_loaded
)
SELECT
    'bridge_employee_relationship',
    COUNT(*)
FROM hr_warehouse.bridge_employee_relationship;



# fact_employment
INSERT INTO hr_warehouse.etl_load_audit (
    table_name,
    rows_loaded
)
SELECT
    'fact_employment',
    COUNT(*)
FROM hr_warehouse.fact_employment;


# ==============================================================

ALTER TABLE hr_warehouse.dim_employee
ADD COLUMN age INT;

SET SQL_SAFE_UPDATES = 0;

UPDATE dim_employee
SET age = TIMESTAMPDIFF(YEAR, birth_date, '2022-12-31');

SET SQL_SAFE_UPDATES = 1;

# ==============================================================


drop table hr_warehouse.etl_load_audit;