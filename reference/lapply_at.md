# Apply multiple functions to multiple variables (data.table compatible)

A lightweight helper function that applies a list of functions to a set
of variables, mimicking the behavior of \`dplyr::summarise_at()\`, but
designed for use within \`data.table\` syntax. This is useful when you
want to compute several summary statistics (e.g., mean, sd) over a
subset of columns defined by \`.SD\` and \`.SDcols\`.

## Usage

``` r
lapply_at(var, funs, ...)
```

## Arguments

- var:

  A vector, list, or data frame-like object (e.g., \`.SD\` inside a
  \`data.table\` call) containing the variables to which the functions
  should be applied.

- funs:

  A character vector of function names (e.g., \`"mean"\`, \`"sd"\`,
  \`"sum"\`) or a list of function objects to be applied to each element
  of \`var\`.

- ...:

  Additional arguments passed to each function call (e.g., \`na.rm =
  TRUE\`).

## Value

A named list where each element corresponds to a combination of variable
and function (e.g., \`Sepal.Length_mean\`, \`Sepal.Length_sd\`),
suitable for use inside \`data.table::lapply()\`.

## See also

\[dplyr::summarise_at()\], \[data.table::lapply()\]

## Examples

``` r
library(data.table)
iris_dt <- as.data.table(iris)

# Compute mean and sd for Sepal variables by Species
iris_dt[, lapply_at(.SD, c("mean", "sd"), na.rm = TRUE),
        .SDcols = patterns("^Sepal"),
        by = Species]
#>       Species Sepal.Length_mean Sepal.Length_sd Sepal.Width_mean Sepal.Width_sd
#>        <fctr>             <num>           <num>            <num>          <num>
#> 1:     setosa             5.006       0.3524897            3.428      0.3790644
#> 2: versicolor             5.936       0.5161711            2.770      0.3137983
#> 3:  virginica             6.588       0.6358796            2.974      0.3224966
```
