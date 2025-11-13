# HRMIS Harmonization

## Overview

This article describes the standard approach for harmonizing human
resource management information system (HRMIS) data, organized into
three main modules: Organization, Worker, and Contract. The contents of
each module are described in `vignette("standard_dictionary")`

## A demo data

Suppose the Government of Brazil shared with us an extraction of their
HRMIS data. First, let’s take a closer look at the data.

``` r
library(govhr)
library(reactable)

reactable(
  head(bra_hrmis, 1e3)
)
```
