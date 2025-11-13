# Flag outliers based on the IQR rule

This function flags values in a numeric vector as outliers if they fall
below Q1 - 1.5 \* IQR or above Q3 + 1.5 \* IQR.

## Usage

``` r
flag_outlier(x)
```

## Arguments

- x:

  A numeric vector.

## Value

A logical vector of the same length as \`x\`, where \`TRUE\` indicates
the observation is an outlier.

## Examples

``` r
x <- c(1, 2, 2, 3, 4, 5, 100)
flag_outlier(x)
#> [1] FALSE FALSE FALSE FALSE FALSE FALSE  TRUE
# Returns TRUE only for the value 100
```
