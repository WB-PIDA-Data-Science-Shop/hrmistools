# Harmonized Contract-Level Dataset (Zambia)

The contract_harmonized dataset contains 50,000 synthetic contract-level
observations consistent with the harmonization dictionary for the
"Contract" module. Each record represents an employment contract for a
worker within an organization, capturing key information on
compensation, contract characteristics, and administrative geography.
All records pertain to Zambia (ISO3: ZMB).

## Usage

``` r
contract_harmonized
```

## Format

A data frame with 50,000 rows and 21 variables:

- contract_id:

  Character. Unique identifier for each contract (e.g., "C000001").

- worker_id:

  Character. Identifier for the worker associated with the contract
  (e.g., "W03583").

- org_id:

  Character. Employer organization associated with the contract (e.g.,
  "ORG0194").

- ref_date:

  Date. Date of contract record entry in YYYY-MM-DD format.

- base_salary_lcu:

  Numeric. Basic pay before allowances and deductions.

- gross_salary_lcu:

  Numeric. Total compensation before taxes and deductions.

- net_salary_lcu:

  Numeric. Take-home pay after taxes and deductions.

- contract_type:

  Character. Type of employment contract — one of "Short-term",
  "Open-term", or "Permanent".

- occupation_native:

  Character. Worker’s occupation title in the native language (e.g.,
  "Comptable", "Analyste").

- occupation_english:

  Character. Worker’s occupation title in English (e.g., "Accountant",
  "Engineer").

- occupation_isconame:

  Character. Occupation name mapped to the ISCO-08 classification (e.g.,
  "Technicians").

- occupation_iscocode:

  Character. ISCO-08 occupation code (e.g., "2411", "2141", "8322").

- start_date:

  Date. Start date of the employment contract (YYYY-MM-DD).

- end_date:

  Date. End date of the employment contract, if applicable (YYYY-MM-DD).

- whours:

  Numeric. Total weekly or monthly working hours as per contract.

- paygrade:

  Character. Pay grade or salary scale classification (e.g., "G7",
  "P1").

- seniority:

  Numeric. Number of years in service or tenure within the organization.

- country_code:

  Character. ISO 3-letter country code ("ZMB").

- country_name:

  Character. Country name ("Zambia").

- adm1_name:

  Character. Subnational administrative division name (e.g., "Lusaka
  Province").

- adm1_code:

  Character. Code corresponding to the administrative division (e.g.,
  "ZMB02").

## Source

Synthetic data generated using Python for demonstration purposes.

## Details

The dataset was synthetically generated to reflect realistic
distributions of salary levels, contract types, and geographic coverage
within Zambia. Salaries are internally consistent such that
`gross_salary ≥ base_salary ≥ net_salary`.

## Examples

``` r
data(contract_harmonized)
dplyr::glimpse(contract_harmonized)
#> Rows: 50,000
#> Columns: 21
#> $ contract_id         <chr> "C000001", "C000002", "C000003", "C000004", "C0000…
#> $ worker_id           <chr> "W03583", "W01347", "W05219", "W07764", "W09786", …
#> $ org_id              <chr> "ORG0194", "ORG0343", "ORG0141", "ORG0167", "ORG02…
#> $ ref_date            <date> 2024-02-28, 2024-08-09, 2024-04-22, 2024-08-30, 2…
#> $ base_salary_lcu     <dbl> 3785.42, 3332.56, 3814.12, 3866.02, 4324.07, 4025.…
#> $ gross_salary_lcu    <dbl> 4252.66, 3943.97, 6319.51, 5578.12, 7283.22, 5444.…
#> $ net_salary_lcu      <dbl> 4252.66, 3943.97, 4325.23, 4679.47, 3409.88, 5398.…
#> $ contract_type       <chr> "Permanent", "Short-term", "Permanent", "Permanent…
#> $ occupation_native   <chr> "Analyste", "Comptable", "Analyste", "Technicien",…
#> $ occupation_english  <chr> "Technician", "Engineer", "Analyst", "Accountant",…
#> $ occupation_isconame <chr> "Technicians", "Technicians", "Engineers", "Engine…
#> $ occupation_iscocode <dbl> 2421, 2421, 2411, 2141, 2421, 2141, 2141, 8322, 24…
#> $ start_date          <date> 2017-08-17, 2023-03-04, 2021-08-14, 2015-04-10, 2…
#> $ end_date            <date> 2027-03-02, 2028-09-01, 2028-06-09, 2024-06-03, 2…
#> $ whours              <dbl> 32.6, 30.3, 32.8, 38.4, 41.9, 42.2, 42.1, 44.7, 41…
#> $ paygrade            <chr> "P1", "G7", "G5", "P1", "G6", "P1", "G7", "G8", "G…
#> $ seniority           <dbl> 16, 29, 15, 29, 21, 1, 19, 19, 6, 26, 12, 4, 17, 4…
#> $ country_code        <chr> "ZMB", "ZMB", "ZMB", "ZMB", "ZMB", "ZMB", "ZMB", "…
#> $ country_name        <chr> "Zambia", "Zambia", "Zambia", "Zambia", "Zambia", …
#> $ adm1_name           <chr> "Western Province", "Lusaka Province", "Central Pr…
#> $ adm1_code           <chr> "ZMB03", "ZMB02", "ZMB03", "ZMB02", "ZMB04", "ZMB0…
dplyr::count(contract_harmonized, contract_type)
#> # A tibble: 3 × 2
#>   contract_type     n
#>   <chr>         <int>
#> 1 Open-term     15018
#> 2 Permanent     25099
#> 3 Short-term     9883
```
