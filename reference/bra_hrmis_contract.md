# Contract Dataset

This dataset contains detailed information about contracts, including
salaries, allowances, occupation, work hours, and organizational
context. Each row represents a unique contract record.

## Usage

``` r
bra_hrmis_contract
```

## Format

A data frame with N rows and 24 variables:

- contract_id:

  Unique identifier for the contract

- worker_id:

  Foreign key linking to Worker module

- org_id:

  Foreign key linking to Organization module

- ref_date:

  Timestamp for the contract record

- base_salary_lcu:

  Base compensation in local currency units (LCU)

- gross_salary_lcu:

  Total compensation before deductions in local currency units

- net_salary_lcu:

  Compensation after deductions in local currency units

- allowance_lcu:

  Allowances in local currency units

- occupation_native:

  Job title in the local language

- occupation_english:

  Job title translated to English

- occupation_isconame:

  ISCO standard occupation name

- occupation_iscocode:

  ISCO standard occupation code

- start_date:

  Contract start date

- end_date:

  Contract end date, if applicable

- country_code:

  Official World Bank ISO-3 country code

- country_name:

  Official World Bank country name

- adm1_name:

  First-level administrative division name

- adm1_code:

  First-level administrative division code

- whours:

  Standard or actual hours worked

- paygrade:

  Salary scale or grade level

- seniority:

  Years of service or seniority level

- year:

  Year of the record
