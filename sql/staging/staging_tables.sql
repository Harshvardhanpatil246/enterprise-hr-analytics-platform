# CREATE MYSQL DATABASE
CREATE DATABASE hr_analytics;

USE hr_analytics;

# CREATE STAGING TABLES
# stg_people_data
CREATE TABLE stg_people_data (
    employee_id VARCHAR(50),
    gender VARCHAR(50),
    race VARCHAR(100),
    birth_date DATE,
    education VARCHAR(100),
    location VARCHAR(100),
    location_city VARCHAR(100),
    marital_status VARCHAR(50),
    employment_status VARCHAR(50)
);

# stg_people_employment_history
CREATE TABLE stg_people_employment_history (
    employee_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    department VARCHAR(100),
    sub_department VARCHAR(100),
    first_level_manager VARCHAR(100),
    second_level_manager VARCHAR(100),
    third_level_manager VARCHAR(100),
    fourth_level_manager VARCHAR(100),
    job_level VARCHAR(50),
    salary DECIMAL(12,2),
    hire_date DATE,
    term_date DATE,
    term_type VARCHAR(100),
    term_reason VARCHAR(255),
    active_status VARCHAR(50)
);

#==========================================================
# CREATE dim_department
CREATE TABLE dim_department (
    department_key INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100),
    sub_department_name VARCHAR(100)
);

# POPULATE dim_department
INSERT INTO dim_department (
    department_name,
    sub_department_name
)
SELECT DISTINCT
    department,
    sub_department
FROM stg_people_employment_history

WHERE department IS NOT NULL;
#==========================================================
# CREATE dim_location
CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(100),
    city_name VARCHAR(100)
);

# POPULATE dim_location
INSERT INTO dim_location (
    location,
    city_name
)
SELECT DISTINCT
    location,
    location_city
FROM stg_people_data

WHERE location IS NOT NULL;


#==========================================================
# CREATE dim_job_level
CREATE TABLE dim_job_level (
    job_level_key INT AUTO_INCREMENT PRIMARY KEY,
    job_level_name VARCHAR(50)
);

# POPULATE dim_job_level
INSERT INTO dim_job_level (
    job_level_name
)
SELECT DISTINCT
    job_level
FROM stg_people_employment_history
WHERE job_level IS NOT NULL;


#==========================================================

# CREATE dim_employee
CREATE TABLE dim_employee (
    employee_key INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    gender VARCHAR(50),
    race VARCHAR(100),
    birth_date DATE,
    education VARCHAR(100),
    marital_status VARCHAR(50),
    employment_status VARCHAR(50),
    location_key INT,

    FOREIGN KEY (location_key)
    REFERENCES dim_location(location_key)
);

# POPULATE dim_employee
# dimensional foreign-key mapping ETL.
INSERT INTO dim_employee (
    employee_id,
    first_name,
    last_name,
    gender,
    race,
    birth_date,
    education,
    marital_status,
    employment_status,
    location_key
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
    dl.location_key

FROM stg_people_data pd

LEFT JOIN stg_people_employment_history peh
    ON pd.employee_id = peh.employee_id

LEFT JOIN dim_location dl
    ON pd.location = dl.location
    AND pd.location_city = dl.city_name;
#==========================================================

# CREATE FACT TABLE
# Employment fact table.
CREATE TABLE fact_employment (
    employment_key INT AUTO_INCREMENT PRIMARY KEY,
    employee_key INT,
    department_key INT,
    job_level_key INT,
    salary DECIMAL(12,2),
    hire_date DATE,
    term_date DATE,
    term_type VARCHAR(100),
    term_reason VARCHAR(255),
    active_status VARCHAR(50),

    FOREIGN KEY (employee_key)
    REFERENCES dim_employee(employee_key),

    FOREIGN KEY (department_key)
    REFERENCES dim_department(department_key),

    FOREIGN KEY (job_level_key)
    REFERENCES dim_job_level(job_level_key)
);

# POPULATE fact_employment
INSERT INTO fact_employment (
    employee_key,
    department_key,
    job_level_key,
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
    peh.salary,
    peh.hire_date,
    peh.term_date,
    peh.term_type,
    peh.term_reason,
    peh.active_status

FROM stg_people_employment_history peh

LEFT JOIN dim_employee de
    ON peh.employee_id = de.employee_id

LEFT JOIN dim_department dd
    ON peh.department = dd.department_name
    AND peh.sub_department = dd.sub_department_name

LEFT JOIN dim_job_level djl
    ON peh.job_level = djl.job_level_name;
#==========================================================

# HIERARCHY MODEL
# CREATE bridge_employee_hierarchy

CREATE TABLE bridge_employee_relationship (

    relationship_key INT AUTO_INCREMENT PRIMARY KEY,

    employee_key INT,

    manager_employee_key INT,

    FOREIGN KEY (employee_key)
    REFERENCES dim_employee(employee_key),

    FOREIGN KEY (manager_employee_key)
    REFERENCES dim_employee(employee_key)
);
    
    
# POPULATE bridge_employee_relationship
# LOADED ONLY DIRECT RELATIONSHIP
INSERT INTO bridge_employee_relationship (
    employee_key,
    manager_employee_key
)

SELECT
    emp.employee_key,
    mgr.employee_key

FROM stg_people_employment_history peh

JOIN dim_employee emp
    ON peh.employee_id = emp.employee_id

LEFT JOIN dim_employee mgr
    ON peh.first_level_manager = mgr.employee_id;

#==========================================================
# CREATE INDEXES

CREATE INDEX idx_employee_id
ON dim_employee(employee_id);

CREATE INDEX idx_department_key
ON fact_employment(department_key);

CREATE INDEX idx_employee_key
ON fact_employment(employee_key);
#==========================================================

