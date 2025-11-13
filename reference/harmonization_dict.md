# HRMIS Harmonization Data Dictionary

A structured metadata dictionary describing variables harmonized across
the Human Resource Management Information System (HRMIS) modules:
Organization, Worker, and Contract. The dictionary follows SDMX-style
documentation standards and specifies variable names, identifiers, data
types (in R), relationships, and other metadata fields used in HRMIS
data harmonization.

## Usage

``` r
harmonization_dict
```

## Format

A tibble with 48 rows and 9 variables:

- Concept Name:

  Variable or concept name as used in the HRMIS module.

- Concept ID:

  Short machine-readable variable name used in datasets.

- Description:

  Detailed explanation of the variable or concept.

- Data Type:

  R data type assigned to the variable (e.g., `character`, `numeric`,
  `Date`).

- Representation (Code list / Format):

  Expected format, code list, or data representation.

- Primary Key:

  Indicates whether the variable uniquely identifies a record (`"Yes"`
  or `"No"`).

- Relationship:

  Describes any relational links to other modules or variables.

- Module:

  The HRMIS module the variable belongs to: `"Organization"`,
  `"Worker"`, or `"Contract"`.

- Example Value:

  Illustrative example value for the variable.

## Details

The dictionary integrates all HRMIS modules into a single metadata
table. It was designed for use in R-based harmonization workflows and
conforms to SDMX Content-Oriented Guidelines (COG) for defining
concepts, code lists, and roles.

## References

SDMX Technical Standards v3.0 — Data Structure Definition (DSD):
<https://sdmx.org/?page_id=5008>

SDMX Content-Oriented Guidelines (COG): <https://sdmx.org/?page_id=4345>

Eurostat SDMX Metadata Reference Manual:
<https://ec.europa.eu/eurostat/web/metadata/reference-metadata-reporting-standards>

## Examples

``` r
library(dplyr)
data(harmonization_dict)

# View structure
glimpse(harmonization_dict)
#> Rows: 48
#> Columns: 9
#> $ `Concept Name`                        <chr> "Organization ID", "Organization…
#> $ `Concept ID`                          <chr> "org_id", "org_name_native", "or…
#> $ Description                           <chr> "Unique identifier assigned to e…
#> $ `Data Type`                           <chr> "character", "character", "chara…
#> $ `Representation (Code list / Format)` <chr> "Alphanumeric (e.g., 'MOF001')",…
#> $ `Primary Key`                         <chr> "Yes", "No", "No", "No", "No", "…
#> $ Relationship                          <chr> "Referenced in Worker, Contract"…
#> $ Module                                <chr> "Organization", "Organization", …
#> $ `Example Value`                       <chr> "MOF001", "Ministère des Finance…

# Filter dictionary by module
harmonization_dict |>
filter(Module == "Worker")
#> # A tibble: 16 × 9
#>    `Concept Name`    `Concept ID` Description `Data Type` Representation (Code…¹
#>    <chr>             <chr>        <chr>       <chr>       <chr>                 
#>  1 Worker ID         worker_id    Unique ide… character   Alphanumeric          
#>  2 Organization ID   org_id       Identifier… character   Alphanumeric          
#>  3 Reference Date    ref_date     Date of th… Date        YYYY-MM-DD            
#>  4 Date of Birth     birth_day    Worker’s d… Date        YYYY-MM-DD            
#>  5 Gender            gender       Sex of the… character   Codelist: SEX (M, F, …
#>  6 Educational Atta… educat4      Educationa… character   Codelist: EDUC4       
#>  7 Educational Atta… educat5      Educationa… character   Codelist: EDUC5       
#>  8 Educational Atta… educat7      Educationa… character   Codelist: EDUC7       
#>  9 Educational Atta… educat10     Educationa… character   Codelist: EDUC10      
#> 10 Tribe             tribe        Worker’s e… character   Text                  
#> 11 Race              race         Worker’s r… character   Text                  
#> 12 Employment Status status       Employment… character   Codelist: STATUS      
#> 13 Country Code      country_code ISO 3-lett… character   ISO3                  
#> 14 Country Name      country_name Official c… character   Text                  
#> 15 Administration 1… adm1_name    Subnationa… character   Text                  
#> 16 Administration 1… adm1_code    Administra… character   Alphanumeric          
#> # ℹ abbreviated name: ¹​`Representation (Code list / Format)`
#> # ℹ 4 more variables: `Primary Key` <chr>, Relationship <chr>, Module <chr>,
#> #   `Example Value` <chr>
```
