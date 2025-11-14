# Organization Dataset

This dataset contains information about public sector organizations,
including identifiers, names, hierarchical relationships, and geographic
context. Each row represents a unique organization record.

## Usage

``` r
bra_hrmis_org
```

## Format

A data frame with N rows and 9 variables:

- org_id:

  Unique identifier for the organization

- org_name_native:

  Official organization name in local language

- org_name_en:

  Organization name translated to English

- country_code:

  Official World Bank ISO-3 country code

- country_name:

  Official World Bank country name

- adm1_name:

  First-level administrative division name

- adm1_code:

  First-level administrative division code

- org_parent:

  Identifier for parent organization in hierarchy

- org_child:

  Identifier for child organizations in hierarchy
