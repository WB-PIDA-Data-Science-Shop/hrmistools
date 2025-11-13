# Quality checks for Worker Module data

This function runs a set of data quality checks on a worker dataset
using the pointblank framework. It verifies that all required columns
are present, worker IDs are unique, and that values are valid and within
expected ranges.

## Usage

``` r
qualitycheck_worker(worker_tbl)
```

## Arguments

- worker_tbl:

  A data frame or tibble containing worker module data. Must include the
  following columns:

  - `ref_date` – Reference date

  - `worker_id` – Unique worker identifier

  - `birth_date` – Date of birth

  - `gender` – Gender

  - `educat7` – Education (7-category classification)

  - `tribe` – Tribe

  - `race` – Race

  - `status` – Employment or marital status

## Value

A `pointblank_agent` object with the results of the quality checks,
after interrogation.

## Details

The following checks are performed:

1.  All required columns exist in the input data.

2.  `worker_id` is unique for each `ref_date`.

3.  Required columns are not missing.

4.  `birth_date` falls between 1900-01-01 and 2000-01-01.

The checks use pointblank validation steps and produce warnings when
violations are found.

## Examples

``` r
if (FALSE) { # \dontrun{
library(dplyr)
test_tbl <- tibble::tibble(
  ref_date = as.Date("2020-01-01") + 0:2,
  worker_id = 1:3,
  birth_date = as.Date(c("1980-01-01", "1990-01-01", "1975-01-01")),
  gender = c("M", "F", "M"),
  educat7 = c("Primary", "Secondary", "Tertiary"),
  tribe = c("A", "B", "C"),
  race = c("X", "Y", "Z"),
  status = c("Employed", "Unemployed", "Employed")
)

qualitycheck_worker(test_tbl)
} # }
```
