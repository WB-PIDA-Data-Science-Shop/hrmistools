# Detect Worker Reallocation Events

Identifies reallocation events when a worker's set of organizations
changes between consecutive reference dates. Removes hire events and
only keeps reallocation events after the earliest reference date for
each worker.

## Usage

``` r
detect_reallocation(data, worker_hire)
```

## Arguments

- data:

  A data.frame or tibble containing at least the columns: -
  \`worker_id\`: Unique worker identifier. - \`ref_date\`: Reference
  date (Date or convertible to Date). - \`org_id\`: Organization ID.

- worker_hire:

  A data.frame or tibble containing hire events with columns
  \`worker_id\` and \`ref_date\`.

## Value

A tibble with columns: - \`worker_id\` - \`ref_date\` -
\`org_id_nested\`: List-column of organization IDs for that worker and
date. - \`type_event\`: \`"reallocation"\` or \`"no reallocation"\`.

## Examples

``` r
if (FALSE) { # \dontrun{
worker_reallocation_df <- detect_reallocation(contract_rename_org_df, worker_hire_df)
} # }
```
