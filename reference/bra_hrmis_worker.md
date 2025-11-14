# Worker Dataset

This dataset contains demographic and employment information for
workers, including identifiers, education, tribal/racial classification,
employment status, and geographic context. Each row represents a unique
worker record.

## Usage

``` r
bra_hrmis_worker
```

## Format

A data frame with N rows and 9 variables:

- worker_id:

  Unique identifier for the worker

- birth_date:

  Worker’s date of birth

- gender:

  Worker’s gender

- educat7:

  Education level using 7-category classification

- tribe:

  Tribal affiliation (where applicable)

- race:

  Racial/ethnic classification

- status:

  Current employment status (active/retired)

- country_code:

  Official World Bank ISO-3 country code

- ref_date:

  Timestamp for the worker record
