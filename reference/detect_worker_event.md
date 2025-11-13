# Detect Worker Events

Expands a dataset of workers and reference dates to include all possible
worker–date combinations, fills missing periods, and identifies "hire"
or "fire" events based on changes in status over time.

## Usage

``` r
detect_worker_event(
  data,
  id_col,
  event_type,
  start_date,
  end_date,
  freq = "year"
)
```

## Arguments

- data:

  A data.table or data.frame containing at least the columns: -
  \`worker_id\`: Unique identifier for workers. - \`ref_date\`:
  Reference date (must be coercible to Date). - \`status\`: Worker
  status (e.g., "active", "inactive").

- id_col:

  Character. Name of the identifier column (e.g., \`"worker_id"\`).

- event_type:

  Character. Either \`"hire"\` or \`"fire"\`, controlling which event to
  detect.

- start_date:

  Optional start date for the full date sequence (default:
  \`"2007-09-01"\`).

- end_date:

  Optional end date for the full date sequence (default:
  \`"2018-01-01"\`).

- freq:

  Frequency for the sequence of dates (default: \`"year"\`). Can be any
  valid value for `seq.Date(by = ...)`.

## Value

A dataset with event types detected (e.g., hire or fire).

## Examples

``` r
if (FALSE) { # \dontrun{
hires <- detect_worker_event(worker_df, id_col = "worker_id", start_date = "2007-09-01",
                       end_date = "2018-01-01", event_type = "hire")

fires <- detect_worker_event(worker_df, id_col = "worker_id", start_date = "2007-09-01",
                       end_date = "2018-01-01", event_type = "fire")
} # }
```
