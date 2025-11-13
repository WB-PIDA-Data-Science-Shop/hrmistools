# Detect Worker Retirement Events

Identifies workers who retired, i.e., whose status changed from "active"
to "inactive".

## Usage

``` r
detect_retirement(data)
```

## Arguments

- data:

  A data.frame or data.table with columns \`worker_id\`, \`ref_date\`,
  and \`status\`.

## Value

A data.table with \`worker_id\`, \`ref_date\`, and \`type_event =
"retire"\`.

## Examples

``` r
if (FALSE) { # \dontrun{
retire_events <- detect_retirement(worker_df)
} # }
```
