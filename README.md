# Enterprise HR Analytics Platform

## Project Overview

This project is an end-to-end HR Analytics Platform built using Python, MySQL, and Power BI.

The objective was to transform raw HR source data into a scalable analytics solution capable of supporting executive workforce decision-making.

The project follows a modern analytics engineering workflow:

Raw Data → ETL Pipeline → Data Cleaning → Enterprise Data Warehouse → Analytics Marts → Power BI Dashboard

The solution provides workforce visibility across headcount, attrition, retention, compensation, and organizational performance.

---

# Business Problem

HR leaders require accurate workforce intelligence to answer questions such as:

* How many employees are currently active?
* Which departments experience the highest attrition?
* Which employee groups have low retention?
* How does compensation vary across departments and job levels?
* What is the organizational span of control?
* Which managers oversee the largest teams?
* What workforce risks require immediate attention?

Raw HR data is often distributed across multiple files and lacks analytical structure.

This project solves that challenge by building a complete analytics architecture from raw source data to executive dashboards.

---

# Project Architecture

```
Raw CSV Files
      │
      ▼
Python ETL Pipeline
      │
      ▼
MySQL Staging Layer
      │
      ▼
Data Cleaning & Validation
      │
      ▼
Enterprise Data Warehouse
      │
      ▼
Analytics Reporting Marts
      │
      ▼
Power BI Semantic Layer
      │
      ▼
Executive HR Dashboard
```

---

# Technology Stack

| Layer                 | Technology           |
| --------------------- | -------------------- |
| Data Extraction       | Python               |
| Data Transformation   | Pandas               |
| Database              | MySQL                |
| Data Warehouse        | Dimensional Modeling |
| Analytics Engineering | SQL                  |
| Business Intelligence | Power BI             |
| Documentation         | Markdown             |

---

# Data Engineering Pipeline

## Stage 1: Raw Data Ingestion

Raw HR CSV files were loaded into MySQL staging tables using Python ETL pipelines.

### Source Files

* people_data.csv
* people_employment_history.csv

### ETL Activities

* Automated CSV ingestion
* Column standardization
* Date parsing
* Data profiling
* Null analysis
* Load validation

### Tools Used

* Pandas
* SQLAlchemy
* PyMySQL

---

## Stage 2: Data Cleaning & Validation

Business rules were applied using Python before loading data into the warehouse.

### Cleaning Activities

* Duplicate handling
* Missing value treatment
* Data type validation
* Date standardization
* Text standardization
* Invalid record detection

### Validation Checks

* Employee ID validation
* Hire date validation
* Termination date validation
* Salary validation
* Null percentage analysis

---

## Stage 3: Enterprise Data Warehouse

A normalized HR warehouse was designed using dimensional modeling principles.

### Warehouse Schema

```
hr_warehouse
```

### Dimension Tables

#### dim_employee

Stores employee master information.

Fields include:

* employee_key
* employee_id
* first_name
* last_name
* gender
* race
* education
* marital_status
* employment_status

---

#### dim_department

Stores organizational structure.

Fields include:

* department_key
* department_name
* sub_department_name

---

#### dim_location

Stores location hierarchy.

Fields include:

* location_key
* location_name
* city_name

---

#### dim_job_level

Stores employee hierarchy levels.

Fields include:

* job_level_key
* job_level_name

---

### Bridge Table

#### bridge_employee_relationship

Models recursive employee-manager relationships.

Fields include:

* relationship_key
* employee_key
* manager_employee_key

This enables organizational hierarchy analysis and manager reporting structures.

---

### Fact Table

#### fact_employment

Stores employment events and workforce metrics.

Fields include:

* employment_key
* employee_key
* department_key
* job_level_key
* salary
* hire_date
* term_date
* term_type
* term_reason
* active_status

---

# Analytics Engineering

## Surrogate Key Strategy

All dimensions were built using surrogate keys.

Examples:

* employee_key
* department_key
* location_key
* job_level_key

Benefits:

* Faster joins
* Warehouse scalability
* Historical tracking readiness
* Source system independence

---

## KPI Validation

Before dashboard development, all KPI calculations were validated directly in SQL.

Examples:

### Headcount Validation

* Active Employee Count
* Total Employee Count

### Attrition Validation

* Voluntary Attrition
* Involuntary Attrition
* Attrition Rate

### Retention Validation

* Retention Percentage
* Early Attrition Rate

### Compensation Validation

* Average Salary
* Median Salary
* Salary Distribution

### Workforce Validation

* Department Headcount
* Job Level Distribution
* Gender Distribution

This ensured Power BI calculations matched source-system calculations.

---

# Analytics Reporting Marts

To improve Power BI performance, denormalized reporting marts were created.

---

## mart_headcount

Purpose:

Enterprise workforce reporting.

Contains:

* Employee demographics
* Department information
* Job level information
* Location information
* Salary information

Used for:

* Workforce Analytics
* Executive Summary

---

## mart_turnover

Purpose:

Employee separation analysis.

Used for:

* Attrition Intelligence
* Turnover Analysis

---

## mart_retention

Purpose:

Employee retention monitoring.

Used for:

* Retention Intelligence

---

## mart_employee_hierarchy

Purpose:

Flattened organizational hierarchy reporting.

Used for:

* Manager Analysis
* Span of Control Analysis

---

## mart_compensation

Purpose:

Compensation and salary analytics.

Used for:

* Compensation Intelligence

---

# Power BI Semantic Model

The reporting layer follows industry-standard star schema design.

### Design Principles

* Conformed dimensions
* Single-direction filtering
* No fact-to-fact relationships
* Shared dimensions
* Surrogate key modeling

### Shared Dimensions

* dim_employee
* dim_department
* dim_location
* dim_job_level
* dim_date

### Performance Optimization

* Hidden technical columns
* Date table optimization
* KPI measures instead of calculated columns
* Relationship optimization

---

# Dashboard Pages

---

## 1. Executive Summary

Provides a high-level workforce overview for HR leadership.

Key Metrics:

* Headcount
* Active Employees
* Attrition Rate
* Retention Rate
* Average Salary

Business Purpose:

Executive workforce monitoring.

---

## 2. Workforce Analytics

Analyzes workforce composition and demographics.

Insights:

* Workforce distribution
* Department headcount
* Location analysis
* Job level analysis
* Diversity metrics

Business Purpose:

Workforce planning and organizational analysis.

---

## 3. Attrition Intelligence

Identifies employee turnover trends and workforce risk areas.

Insights:

* Attrition trends
* Attrition by department
* Attrition by location
* Voluntary vs involuntary exits
* Early attrition analysis

Business Purpose:

Reduce employee turnover.

---

## 4. Retention Intelligence

Analyzes employee retention patterns.

Insights:

* Retention trends
* Tenure analysis
* High-risk workforce groups
* Long-tenure employee distribution

Business Purpose:

Improve employee retention.

---

## 5. Compensation Analytics

Evaluates salary distribution and compensation equity.

Insights:

* Salary by department
* Salary by job level
* Salary distribution
* Compensation benchmarking

Business Purpose:

Support compensation strategy.

---

# Key Business Insights Generated

The platform enables stakeholders to:

* Monitor workforce health
* Identify attrition hotspots
* Improve retention strategies
* Evaluate compensation equity
* Analyze workforce demographics
* Understand organizational structure
* Support HR decision-making using data

---

# Skills Demonstrated

### Data Engineering

* ETL Development
* Data Cleaning
* Data Validation
* Data Quality Checks
* Data Pipeline Design

### SQL & Data Warehousing

* Dimensional Modeling
* Fact & Dimension Design
* Surrogate Keys
* Recursive Hierarchies
* Bridge Tables
* Analytics Marts

### Analytics Engineering

* KPI Engineering
* Semantic Modeling
* Data Lineage
* Business Logic Implementation

### Business Intelligence

* Power BI
* DAX
* Dashboard Development
* Executive Reporting
* Workforce Analytics

---

# Project Outcome

Built an enterprise-style HR Analytics Platform that transforms raw HR data into actionable business intelligence through a scalable data engineering, warehousing, and analytics architecture.

The solution demonstrates industry-aligned practices across ETL, data warehousing, analytics engineering, and Power BI development.
