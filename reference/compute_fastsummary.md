# Fast Summary Statistics by Group

Computes summary statistics for specified numeric columns in a data
frame or data.table, optionally grouped by one or more categorical
variables. This function supports both predefined summary functions
(e.g., mean, sum) and user-specified formulas. It returns results in
either long or wide format, and can optionally convert the output to a
tibble.

## Usage

``` r
compute_fastsummary(
  data,
  cols,
  fns = NULL,
  groups,
  output = c("long", "wide"),
  tbl = FALSE
)
```

## Arguments

- data:

  A data.table or data.frame containing the data to summarize.

- cols:

  A character vector specifying the names of numeric columns to
  summarize.

- fns:

  Optional. A character vector or list of formulas specifying the
  summary functions to apply. If NULL, default functions defined by
  define_fns() are used. - If a character vector, function names must
  match those in the defaults (e.g., "mean", "sum"). - If a list, can
  contain formulas or a mix of character names and formulas.

- groups:

  A character vector specifying one or more grouping variables.

- output:

  A character string specifying the output format. Must be one of: -
  "long": produces a tall table with an indicator column and a value
  column. - "wide": produces a wide table with one column per statistic.

- tbl:

  Logical. If TRUE, converts the resulting data.table into a tibble.

## Value

A data.table (or tibble if tbl = TRUE) containing summary statistics by
group, either in long or wide format.

## Details

The function first matches the output argument, loads default summary
functions from define_fns(), and determines which functions to apply
based on user input. It uses efficient data.table operations for grouped
computation, and optionally reshapes the output to long format with
data.table::melt().

## See also

\[define_fns()\], \[data.table::melt()\], \[tibble::as_tibble()\]

## Examples

``` r
if (FALSE) { # \dontrun{
# Example usage:
compute_fastsummary(
data = contract_harmonized |> as.data.table(),
cols = c("base_salary_lcu", "gross_salary_lcu"),
fns = c("mean", "sum"),
groups = c("occupation_isconame", "year"),
output = "long"
)
} # }
```
