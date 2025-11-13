# HRMIS Standard Data Dictionary

## Overview

This article describes the standard dictionary for human resource
management information system (HRMIS) data, organized into three main
modules: Organization, Worker, and Contract. These modules are designed
to organize and standardize information about public sector personnel
across different countries and administrative levels.

## Module 1: Organization

The Organization module captures information about public sector
institutions, including ministries, departments, and agencies.

### Fields

| Field Name                  | Variable Name      | Description                                       |
|-----------------------------|--------------------|---------------------------------------------------|
| Organization ID             | `org_id`           | Unique identifier for the organization            |
| Organization Name (Native)  | `org_name_native`  | Official organization name in local language      |
| Organization Name (English) | `org_name_english` | Organization name translated to English           |
| Reference Date              | `ref_date`         | Latest date when the organization had that name   |
| Organization Type           | `org_type`         | Type of organization (Ministry/Department/Agency) |
| Parent Organization         | `org_parent`       | Identifier for parent organization in hierarchy   |
| Child Organization          | `org_child`        | Identifier for child organizations in hierarchy   |
| Country Code                | `country_code`     | Official World Bank ISO-3 country code            |
| Country Name                | `country_name`     | Official World Bank country name                  |
| Administration 1 Name       | `adm1_name`        | First-level administrative division name          |
| Administration 1 Code       | `adm1_code`        | First-level administrative division code          |

### Notes

- **Organization Type**: Indicates the hierarchical level of the
  institution within the government structure. Ideally, this would
  support parent-child relationships, though such data may be rare in
  practice.
- **Administration Level**: Refers to the geographic/administrative
  level of government (e.g., national, state/provincial, local).
- **Reference Date**: Critical for tracking organizational changes,
  mergers, or renaming over time.

## Module 2: Worker

The Worker module contains demographic and employment information about
individual public sector employees.

### Fields

| Field Name                           | Variable Name  | Description                                      |
|--------------------------------------|----------------|--------------------------------------------------|
| Worker ID                            | `worker_id`    | Unique identifier for the worker                 |
| Organization ID                      | `org_id`       | Foreign key linking to Organization module       |
| Reference Date                       | `ref_date`     | Timestamp for the worker record                  |
| Date of Birth                        | `birth_day`    | Worker’s date of birth                           |
| Gender                               | `gender`       | Worker’s gender                                  |
| Education Attainment (5 categories)  | `educat5`      | Education level using 5-category classification  |
| Education Attainment (10 categories) | `educat10`     | Education level using 10-category classification |
| Tribe                                | `tribe`        | Tribal affiliation (where applicable)            |
| Race                                 | `race`         | Racial/ethnic classification                     |
| Employment Status                    | `status`       | Current status (active/retired)                  |
| Country Code                         | `country_code` | Official World Bank ISO-3 country code           |
| Country Name                         | `country_name` | Official World Bank country name                 |
| Administration 1 Name                | `adm1_name`    | First-level administrative division name         |
| Administration 1 Code                | `adm1_code`    | First-level administrative division code         |

### Notes

- **Education Categories**: Multiple classification systems are provided
  to allow for cross-country comparisons and mapping to international
  standards.
- **Geographic Information**: While workers are linked to organizations,
  separate geographic fields allow for tracking mobility and remote work
  arrangements.
- **Privacy Considerations**: This module contains sensitive personal
  information and should be handled according to applicable data
  protection regulations.

## Module 3: Contract

The Contract module captures details about employment contracts,
compensation, and job characteristics.

### Fields

| Field Name             | Variable Name                                                | Description                                                     |
|------------------------|--------------------------------------------------------------|-----------------------------------------------------------------|
| Contract ID            | `contract_id`                                                | Unique identifier for the contract                              |
| Worker ID              | `worker_id`                                                  | Foreign key linking to Worker module                            |
| Organization ID        | `org_id`                                                     | Foreign key linking to Organization module                      |
| Reference Date         | `ref_date`                                                   | Timestamp for the contract record                               |
| Base Salary (LCU)      | `base_salary`                                                | Base compensation in local currency units                       |
| Base Salary (PPP)      | `base_salary_ppp`                                            | Base compensation in constant international dollars             |
| Gross Salary (LCU)     | `gross_salary_lcu`                                           | Total compensation before deductions in local currency units    |
| Net Salary (PPP)       | `net_salary`                                                 | Compensation after deductions in constant international dollars |
| Allowances (LCU)       | `allowance_lcu`                                              | Allowances in local currency units                              |
| Allowances (PPP)       | `allowance_ppp` Allowances in constant international dollars |                                                                 |
| Contract Type          | `contract_type`                                              | Contract modality (short-term/open-term/permanent)              |
| Occupation (Native)    | `occupation_native`                                          | Job title in local language                                     |
| Occupation (English)   | `occupation_english`                                         | Job title translated to English                                 |
| Occupation (ISCO Name) | `occupation_isconame`                                        | ISCO standard occupation name                                   |
| Occupation (ISCO Code) | `occupation_iscocode`                                        | ISCO standard occupation code                                   |
| Start Date             | `start_date`                                                 | Contract start date                                             |
| End Date               | `end_date`                                                   | Contract end date (if applicable)                               |
| Country Code           | `country_code`                                               | Official World Bank ISO-3 country code                          |
| Country Name           | `country_name`                                               | Official World Bank country name                                |
| Administration 1 Name  | `adm1_name`                                                  | First-level administrative division name                        |
| Administration 1 Code  | `adm1_code`                                                  | First-level administrative division code                        |
| Hours Worked           | `whours`                                                     | Standard or actual hours worked                                 |
| Pay Grade              | `paygrade`                                                   | Salary scale or grade level                                     |
| Seniority              | `seniority`                                                  | Years of service or seniority level                             |

### Notes

- **Compensation Fields**: Multiple salary measures allow for analysis
  of gross-to-net ratios, taxation effects, and allowances.
- **Occupation Coding**: Both native and standardized (ISCO)
  classifications enable within-country detail and cross-country
  comparability.
- **Contract Duration**: The combination of `contract_type`,
  `start_date`, and `end_date` provides comprehensive information about
  employment stability and temporary arrangements.

## Relationship between modules

The three modules are related as follows:

    Organization (1) ←→ (N) Worker
    Organization (1) ←→ (N) Contract
    Worker (1) ←→ (N) Contract

- One organization can have many workers
- One organization can have many contracts
- One worker can have multiple contracts (over time or concurrent)

## Data Quality Considerations

1.  **Temporal Consistency**: Ensure `ref_date` fields are properly
    maintained across all modules
2.  **Geographic Consistency**: Country and administration codes should
    be consistent across all modules
3.  **Unique Identifiers**: All ID fields should be globally unique and
    persistent
4.  **Missing Data**: Document conventions for handling missing or
    unavailable data
5.  **Historical Records**: Consider versioning strategy for tracking
    changes over time
