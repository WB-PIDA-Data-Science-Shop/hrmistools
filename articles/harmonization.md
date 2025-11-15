# HRMIS Harmonization

## Introduction

Across many countries—especially in low- and middle-income
settings—governments are increasingly seeking to adopt analytics-driven
approaches to public sector human resource (HR) management and civil
service reform. Yet most government offices and our World Bank regional
counterparts often lack standardized tools for transforming raw HRMIS
data into formats suitable for rigorous analysis. As a result, each new
diagnostic requires bespoke data cleaning, ad hoc coding decisions, and
country-specific scripts that are costly to maintain and difficult to
replicate.

This fragmentation makes HRM analytics expensive, slow, and
inconsistent. It also limits the ability of governments and development
partners—including the World Bank—to compare results across time,
sectors, or countries, or to build reusable analytics pipelines.

This article describes the standard approach for harmonizing human
resource management information system (HRMIS) data, organized into
three main modules: Organization, Worker, and Contract. The contents of
each module are described in `vignette("standard_dictionary")`. In this
article, we provide a set of helper functions to support the
harmonization process across the modules. When users prepare their HRMIS
data according to this standard, teams can immediately apply automated
tools for data quality control as well as dynamic and reproducible
reports on workforce structure dynamics, pay and compensation analytics,
establishment control monitoring, staffing distribution analysis.

This vignette, harmonization.Rmd, presents the practical workflow for
transforming raw HRMIS extracts into these standardized modules. It
provides governments with a clear, repeatable procedure for preparing
their data so that advanced analytics can be deployed rapidly and
consistently—reducing costs, increasing comparability, and strengthening
evidence-based HR decision making.

The harmonization workflow demonstrated here shows how to:

- map raw administrative HR variables into a standardized public sector
  schema,

- recode local classifications (education, occupation, contract type)
  into cross-country taxonomies,

- generate unique and persistent identifiers for workers, organizations,
  and contracts,

- attach missing metadata such as country codes, administrative
  hierarchies, or reference dates,

- structure the cleaned data into the three standard HRMIS modules, and

- validate the outputs against the HRMIS Standard Data Dictionary.

By following this procedure, governments and World Bank teams can unlock
a common analytics ecosystem in which standardized public sector HR data
feeds directly into automated dashboards, diagnostic tools, and
monitoring systems—enabling faster, cheaper, and more consistent
evidence-based HR reform.

### The Raw Data

For this vignette, we apply synthetic data assumed from Brazil HRMIS
system provided at the contract level. See the data below:

``` r
reactable(
  head(bra_hrmis, 1e3)
)
```

We illustrate the harmonization workflow using this dataset. `bra_hrmis`
contains 344920 rows and 34 columns, covering covering demographic,
employment, organizational, and payroll information for public sector
workers.

A quick glimpse of the dataset:

``` r
glimpse(bra_hrmis)
```

    ## Rows: 344,920
    ## Columns: 34
    ## $ ANO_PAGAMENTO                     <chr> "2014", "2014", "2014", "2014", "201…
    ## $ MES_REFERENCIA                    <chr> "9", "9", "9", "9", "9", "9", "9", "…
    ## $ MATRICULA                         <chr> "1", "22", "30", "51", "81", "86", "…
    ## $ CPF                               <chr> "9678b179d65c7d9a40d1eb2f0c687529762…
    ## $ DATA_NASCIMENTO                   <chr> "15311", "19703", "22122", "24943", …
    ## $ GENERO                            <chr> "MASCULINO", "FEMININO", "FEMININO",…
    ## $ ESCOLARIDADE                      <chr> "SEGUNDO GRAU COMPLETO", "5 A 8 SERI…
    ## $ DATA_ADMISSAO                     <chr> "28976", "30167", "29921", "32149", …
    ## $ ADMINISTRACAO                     <chr> "INDIRETA", "DIRETA", "DIRETA", "DIR…
    ## $ TIPO_CONTRATO                     <chr> "TEMPORÁRIO", "EFETIVO COMISSIONADO"…
    ## $ GRUPO                             <chr> "OUTROS", "OUTROS", "OUTROS", "OUTRO…
    ## $ COD_ORGAO                         <chr> "405502", "301101", "301101", "30110…
    ## $ ORGAO                             <chr> "GABINETE CIVIL", "GABINETE CIVIL", …
    ## $ CARREIRA                          <chr> "ENGENHEIRO", "AUXILIAR DE SERVICOS …
    ## $ CARGO                             <chr> "ENGENHEIRO", "AUXILIAR DE SERVICOS …
    ## $ JORNADA                           <chr> "30", "40", "40", "30", "40", "40", …
    ## $ CLASSE                            <chr> NA, "C", "D", "B", "B", "B", "C", "D…
    ## $ NIVEL                             <chr> "SERV816", "ACENC40", "ACSND40", "AC…
    ## $ DATA_ULT_PROGRESSAO               <chr> "41671", NA, "40179", "39638", NA, N…
    ## $ SALARIO_BASE                      <chr> "13191.07", "705.73", "3841.43", "21…
    ## $ CONTRIBUICAO_PREVIDENCIA          <chr> "482.92", "0", "0", "0", "0", "0", "…
    ## $ ADICIONAL_TEMPO_SERVICO           <chr> "1978.66", "0", "0", "0", "0", "0", …
    ## $ COMISSAO                          <chr> "0", "442.87", "316.33999999999997",…
    ## $ ABONO_PERMANENCIA                 <chr> "0", "79.64", "422.56", "0", "0", "0…
    ## $ DECISAO_JUDICIAL                  <chr> "0", "0", "0", "0", "0", "0", "0", "…
    ## $ DEMAIS_GRATIFICACOES_TRANSITORIAS <chr> "0", "237.05", "0", "0", "24.1", "24…
    ## $ DEMAIS_GRATIFICACOES_CARREIRA     <chr> "0", "0", "0", "0", "0", "0", "0", "…
    ## $ SALARIO_BRUTO                     <chr> "15169.73", "1465.29", "4580.33", "2…
    ## $ SALARIO_LIQUIDO                   <chr> "11474.09", "1465.29", "4369.1000000…
    ## $ DATA_APOSENTADORIA                <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ VALOR_BRUTO                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ VALOR_LIQUIDO                     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ TIPO                              <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    ## $ `TEMPO DE CONTRIBUIÇÃO`           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, …

This will give you a brief, surface level overview of the dataset. You
should see the dimensions of the data (i.e. number of rows and columns)
and variable types and perhaps begin to get a sense for completeness (or
the lack thereof) for certain variables.

## The Harmonization Process

### Introduction

The goal of the harmonization process is to establish a consistent and
standardized structure for cleaned HR datasets, ensuring that analytics
supporting government human resources management from a common
analytical foundation. In many client countries, HRM analytics are
conducted in an ad-hoc, highly customized manner that varies by
consultant, ministry, year, and even dataset. This leads to high
analytical costs, limited comparability over time or across
institutions, and significant barriers to scaling evidence-based human
resource reform.

The harmonization framework addresses these challenges directly. By
defining a clear data dictionary and a set of standardized
transformations, governments can prepare their HRMIS data in a format
that is analytically ready and fully compatible with the tools provided
in the `govhr` package. This ensures:

- **Reproducible and transparent workflows**  
- **Cross-country and cross-institution comparability**  
- **Automatic generation of quality checks and dashboards**  
- **Reduced data preparation cost for each new engagement**

The remainder of this section documents the harmonization steps for each
of the three core modules derived from the data dictionary:

1.  **Contract Module**  
2.  **Worker Module**
3.  **Organization Module** Each module represents a specific level of
    analysis defined by the dictionary and is to be constructed directly
    from the raw HRMIS data.

------------------------------------------------------------------------

### Harmonizing the Contract Module

The Contract Module is the foundational component of the harmonized
payroll dataset. The purpose of this module is to extract and structure
all information that is **unique at a contract, reference date level**,
as defined in the data dictionary. A “contract record” refers to a
worker–contract relationship at a specific reference period (usually
month–year), capturing the contractual characteristics governing the
worker’s employment at that time.

In practice, the raw HRMIS data typically mixes variables at different
conceptual levels—worker attributes, position attributes, contract
terms, payroll events, and sometimes even one-off administrative
transactions.

Working with payroll or HRMIS data in many developing-country contexts
often involves very large datasets—sometimes millions of records
spanning multiple years. Such data volumes can quickly overwhelm
standard analytical workflows if not handled using efficient tools.

In R, there are several paradigms for manipulating two-dimensional data.
For the purposes of this tutorial, we rely on the data.table package for
the tasks that are more computationally intensive. At the time of
writing, data.table remains the gold standard for high-performance data
processing in R, offering exceptional speed, efficient memory use, and
an expressive syntax tailored for large datasets.

Although the dplyr package from the tidyverse ecosystem is widely used
and favored for its readability and intuitive grammar, operations on
large payroll datasets can be substantially slower when using dplyr
alone. To ensure reproducibility, performance, and
scalability—especially for teams with limited computational resources—we
adopt data.table as the primary engine for harmonization. However, we
will also use the dplyr functions where performance is not improved to
ensure code readability.

The `bra_hrmis` data is written in Portuguese which might require
translation to English to ease understanding. One option is to use an
LLM like ChatGPT to get a quick as there are only 34 columns.
Alternatively the `polyglotr` R package provides a suite functions that
support translation. This can be applied as follows:

``` r
raw_dictionary <- 
  tibble(raw_colnames_pt = colnames(bra_hrmis),
         raw_colnames_eng = polyglotr::google_translate(colnames(bra_hrmis), "pt", "en"))

kable(raw_dictionary)
```

| raw_colnames_pt                   | raw_colnames_eng                  |
|:----------------------------------|:----------------------------------|
| ANO_PAGAMENTO                     | ANO_PAGAMENTO                     |
| MES_REFERENCIA                    | MES_REFERENCIA                    |
| MATRICULA                         | MATRÍCULA                         |
| CPF                               | CPF                               |
| DATA_NASCIMENTO                   | DATA_NASCIMENTO                   |
| GENERO                            | GÊNERO                            |
| ESCOLARIDADE                      | ESCOLARIDADE                      |
| DATA_ADMISSAO                     | DATA_ADMISSÃO                     |
| ADMINISTRACAO                     | ADMINISTRAÇÃO                     |
| TIPO_CONTRATO                     | TIPO_CONTRATO                     |
| GRUPO                             | GRUPO                             |
| COD_ORGAO                         | COD_ORGAO                         |
| ORGAO                             | ORGAO                             |
| CARREIRA                          | CARREIRA                          |
| CARGO                             | CARGA                             |
| JORNADA                           | JORNADA                           |
| CLASSE                            | CLASSE                            |
| NIVEL                             | NÍVEL                             |
| DATA_ULT_PROGRESSAO               | DATA_ULT_PROGRESSÃO               |
| SALARIO_BASE                      | SALARIO_BASE                      |
| CONTRIBUICAO_PREVIDENCIA          | CONTRIBUICAO_PREVIDÊNCIA          |
| ADICIONAL_TEMPO_SERVICO           | ADICIONAL_TEMPO_SERVICO           |
| COMISSAO                          | COMISSÃO                          |
| ABONO_PERMANENCIA                 | ABONO_PERMANENCIA                 |
| DECISAO_JUDICIAL                  | DECISAO_JUDICIAL                  |
| DEMAIS_GRATIFICACOES_TRANSITORIAS | DEMAIS_GRATIFICACOES_TRANSITORIAS |
| DEMAIS_GRATIFICACOES_CARREIRA     | DEMAIS_GRATIFICACOES_CARREIRA     |
| SALARIO_BRUTO                     | SALARIO_BRUTO                     |
| SALARIO_LIQUIDO                   | SALARIO_LIQUIDO                   |
| DATA_APOSENTADORIA                | DATA_APOSENTADORIA                |
| VALOR_BRUTO                       | VALOR_BRUTO                       |
| VALOR_LIQUIDO                     | VALOR_LIQUIDO                     |
| TIPO                              | TIPO                              |
| TEMPO DE CONTRIBUIÇÃO             | TEMPO DE CONTRIBUIÇÃO             |

The first step when handling any raw payroll dataset is to find the
individual to identifies each countract for each time period unique. We
begin by looking through the `bra_hrmis` object for this. From the above
table and the previous glimpse(), we can see that the `CPF` and
`MATRICULA` variables are the most likely candidates to identify
contracts uniquely. We do a quick check for this as follows:

``` r
### first let us convert the data to a data.table object to speed up our computations

bra_hrmis <- as.data.table(bra_hrmis)

# Unique CPF per year
cpf_summary <- bra_hrmis[, .(unique_cpf = uniqueN(CPF),
                             nobs       = .N),
                         by = ANO_PAGAMENTO]

# Unique Matricula per year
mtr_summary <- bra_hrmis[, .(unique_mtr = uniqueN(MATRICULA),
                             nobs       = .N), 
                         by = ANO_PAGAMENTO]

kable(cpf_summary)
```

| ANO_PAGAMENTO | unique_cpf |  nobs |
|:--------------|-----------:|------:|
| 2014          |      57694 | 60291 |
| 2015          |      59886 | 62614 |
| 2016          |      70677 | 74310 |
| 2017          |      69732 | 73287 |
| 2018          |      70911 | 74418 |

``` r
kable(mtr_summary)
```

| ANO_PAGAMENTO | unique_mtr |  nobs |
|:--------------|-----------:|------:|
| 2014          |      60291 | 60291 |
| 2015          |      62614 | 62614 |
| 2016          |      74310 | 74310 |
| 2017          |      73287 | 73287 |
| 2018          |      74418 | 74418 |

This clearly shows that `MATRICULA` is the contract ID while `CPF` is
possibly the identifier for the worker, the latter will come in handy
during the harmonization of the worker module.

Now, we can begin creating the set of variables as defined by the
`standard_dictionary` vignette. It is often useful to begin by creating
the derived variables. There are four sets of derived variables within
the dictionary:

- 1.  the Industrial Standard Classification of Occupation (ISCO)
      variables, i.e. `occupation_isconame`, `occupation_iscocode` are
      derived from the original occupation variables
      `occupation_native`, `occupation_english`. We apply the
      [`polyglotr::google_translate()`](https://tomeriko96.github.io/polyglotr/reference/google_translate.html)
      function to convert Portuguese named occupations to English as
      well as use the `LabourR::classify_occupation()` function to
      classify these occupations to the level-4 isco names.

``` r
#-----------------------------
# 2. Build occupation table (active + inactive)
#-----------------------------

occup_df <- bra_hrmis[, c("CARREIRA", "CARGO")]

# distinct CARREIRA/CARGO/status
occup_df <- unique(occup_df)

# Add translated vars
occup_df[, occupation_native := tolower(CARREIRA)]

occup_df[, occupation_english := tolower(google_translate(text = CARREIRA,
                                                          source_language = "pt",
                                                          target_language = "en"))]

#-----------------------------
# 3. Classify occupations
#-----------------------------
class_occup_df <- copy(occup_df)[,
  .(id = .I, text = occupation_english)
]

class_occup_df <- classify_occupation(class_occup_df,
                                      isco_level = 4,
                                      lang       = "en", 
                                      num_leaves = 1)


datatable(head(class_occup_df, 
               n = nrow(class_occup_df)), 
          options = list(pageLength = 10)) 
```

``` r
#-----------------------------
# 4. Merge classification back into occup_df
#-----------------------------
occup_df[, id := .I]

# merge iscoGroup
occup_df <- merge(
  occup_df,
  class_occup_df[, .(id = as.integer(id), iscoGroup)],
  by = "id",
  all.x = TRUE
)

setnames(occup_df, "iscoGroup", "occupation_iscocode")

# merge ISCO descriptions
occup_df <- merge(occup_df,
                  isco[, c("unit", "description")] |> as.data.table(),
                  by.x = "occupation_iscocode",
                  by.y = "unit",
                  all.x = TRUE)

setnames(occup_df, "description", "occupation_isconame")

#-----------------------------
# 5. Bring classified occupations back to bra_hrmis (active only)
#-----------------------------

## we perform a left join with data.table syntax for speed as the merging into 
## the hrmis dataset could be computationally intensive

bra_hrmis <- occup_df[bra_hrmis, on = c("CARREIRA", "CARGO")]
```

- 2.  the date variables (`ref_date`, `start_date`, `end_date`) are
      often in the serial 5-digit format and need to be standardized as
      they will be used in preparing the compensation variables which
      are time-variant. Below, we create the date variables:

``` r
### lets include the dates
bra_hrmis[, ref_date := as.Date(paste(ANO_PAGAMENTO, MES_REFERENCIA, "01", sep = "-"))]

setnames(bra_hrmis, c("DATA_ADMISSAO", "DATA_APOSENTADORIA"), c("start_date", "end_date"))
bra_hrmis[, start_date := as.Date(as.integer(start_date), origin = "1899-12-30")]
bra_hrmis[, end_date := as.Date(as.integer(end_date), origin = "1899-12-30")]


### lets include the country code and admin identifier

bra_hrmis[, country_code := "BRA"]
bra_hrmis[, country_name := "Brazil"]
bra_hrmis[, adm1_name := "Alagoas"]
bra_hrmis[, adm1_code := "AL"]
```

- 3.  the compensation variables i.e. `gross_salary_ppp`,
      `base_salary_ppp`, `net_salary_ppp` which are all derived from the
      local currency equivalents `gross_salary_lcu`, `base_salary_lcu`,
      `net_salary_lcu`. We provide a function called
      [`convert_constant_ppp()`](https://wb-pida-data-science-shop.github.io/govhr/reference/convert_constant_ppp.md)
      as well as a `macro_indicators` dataset with this package to
      perform these transformations between the nominal variables
      (i.e. \_lcu) and their real equivalents (\_ppp).

``` r
### lets convert the nominal compensation variables to real (_ppp) values
# Step 1: Create the _lcu salary variables (in-place, no copy)

### lets rename the raw variables here to their actual names
setnames(bra_hrmis, 
         old = c("SALARIO_BASE", "SALARIO_BRUTO", "SALARIO_LIQUIDO", "ABONO_PERMANENCIA"),
         new = c("base_salary_lcu", "gross_salary_lcu", "net_salary_lcu", "allowance_lcu"))


# Step 2: Identify all *_lcu columns to convert
cols_to_convert <- grep("_lcu$", names(bra_hrmis), value = TRUE)

# Step 3: Apply PPP conversion using your convert_constant_ppp function
pfw_df <- 
  macro_indicators |>
  dplyr::filter(country_code == "BRA", 
                year %in% as.integer(unique(bra_hrmis$ANO_PAGAMENTO))) |>
  dplyr::select(all_of(c("country_code", "year", "cpi", "ppp")))


bra_hrmis[, (cols_to_convert) := lapply(.SD, as.numeric), .SDcols = cols_to_convert]


### apply the convert_constant_ppp function to produce those estimates
bra_hrmis <- convert_constant_ppp(data = bra_hrmis[, year := lubridate::year(ref_date)],
                                  cols = cols_to_convert,
                                  macro_indicators = macro_indicators)

### while we are at this lets include the working hour variable as well
bra_hrmis[, whours := as.numeric(JORNADA)]
```

- 4.  the contract type variable `TIPO_CONTRATO` needs to be
      reclassified according to the dictionary, `contract_type`. We do
      so as follows:

``` r
### create a little dictionary mapping all the raw classes into a contract type in a data.table
contract_dict <- 
  data.table(TIPO_CONTRATO = unique(bra_hrmis$TIPO_CONTRATO),
             contract_type = c("short-term", "permanent", "permanent", "open-term",
                               "short-term", "inactive", "retired"))

kable(contract_dict)
```

| TIPO_CONTRATO               | contract_type |
|:----------------------------|:--------------|
| TEMPORÁRIO                  | short-term    |
| EFETIVO COMISSIONADO        | permanent     |
| EFETIVO                     | permanent     |
| EXCLUSIVAMENTE COMISSIONADO | open-term     |
| TEMPOR¡RIO                  | short-term    |
| INATIVO                     | inactive      |
| PENSIONISTA                 | retired       |

Let’s do a data.table join of the `contract_dict` into the `bra_hrmis`

``` r
bra_hrmis <- contract_dict[bra_hrmis, on = "TIPO_CONTRATO"]
```

Now that the derived variables in this contract module have been
created, we are ready to create the rest of the variables all at once to
finalize the module.

``` r
setnames(bra_hrmis,
         old = c("MATRICULA", "CPF", "ORGAO", "CLASSE", "NIVEL"),
         new = c("contract_id", "worker_id", "org_id", "paygrade", "seniority"))


### now let us select the final set of dictionary variables to complete the module
### lets use dplyr::select() function since this will not add any computational time
bra_hrmis_contract <- 
  bra_hrmis |>
  dplyr::select(
    contract_id, worker_id, org_id,
    ends_with("_date"),
    contains("_salary_"),
    contract_type, 
    starts_with("occupation_"),
    country_code, country_name,
    adm1_name, adm1_code,
    whours, paygrade, seniority
  )
```

Here is what our final data looks like:

    ## Rows: 344,920
    ## Columns: 24
    ## $ contract_id         <chr> "1", "22", "30", "51", "81", "86", "102", "103", "…
    ## $ worker_id           <chr> "9678b179d65c7d9a40d1eb2f0c687529762fe73ee1e48e768…
    ## $ org_id              <chr> "GABINETE CIVIL", "GABINETE CIVIL", "SECRETARIA DE…
    ## $ start_date          <date> 1979-05-01, 1982-08-04, 1981-12-01, 1988-01-07, 1…
    ## $ end_date            <date> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ref_date            <date> 2014-09-01, 2014-09-01, 2014-09-01, 2014-09-01, 2…
    ## $ base_salary_lcu     <dbl> 13191.07, 705.73, 3841.43, 2100.44, 699.90, 699.90…
    ## $ gross_salary_lcu    <dbl> 15169.73, 1465.29, 4580.33, 2100.44, 1166.87, 1166…
    ## $ net_salary_lcu      <dbl> 11474.09, 1465.29, 4369.10, 2082.87, 1166.87, 1166…
    ## $ base_salary_ppp     <dbl> 3652.4100, 195.4061, 1063.6345, 581.5804, 193.7918…
    ## $ gross_salary_ppp    <dbl> 4200.2714, 405.7169, 1268.2249, 581.5804, 323.0889…
    ## $ net_salary_ppp      <dbl> 3177.0039, 405.7169, 1209.7385, 576.7156, 323.0889…
    ## $ contract_type       <chr> "short-term", "permanent", "permanent", "permanent…
    ## $ occupation_iscocode <chr> "2149", "9311", "3119", "9311", NA, "9311", "2422"…
    ## $ occupation_native   <chr> "engenheiro", "auxiliar de servicos dive", "tecnic…
    ## $ occupation_english  <chr> "engineer", "dive services assistant", "planning t…
    ## $ occupation_isconame <chr> "Engineering Professionals Not Elsewhere Classifie…
    ## $ country_code        <chr> "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "…
    ## $ country_name        <chr> "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", …
    ## $ adm1_name           <chr> "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alago…
    ## $ adm1_code           <chr> "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "A…
    ## $ whours              <dbl> 30, 40, 40, 30, 40, 40, 30, 40, 30, 40, 30, 30, 40…
    ## $ paygrade            <chr> NA, "C", "D", "B", "B", "B", "C", "D", "C", "D", "…
    ## $ seniority           <chr> "SERV816", "ACENC40", "ACSND40", "ACMNB30", "ACENB…

### Harmonizing the Worker Module

The Worker Module standardizes individual-level information about
employees with the public sector. This section demonstrates the
harmonization pipeline using the same contract-level Brazil (Alagoas)
HRMIS dataset (bra_hrmis) as an example. We will produce a clean,
harmonized dataset named bra_hrmis_worker which conforms to the Worker
Module dictionary in `standard_dictionary.Rmd`.

Let’s start with a little exploration. We need to understand how many
unique worker-organization-refdate combinations are within the data:

``` r
## how many observations should we expect to have
worker_count <- 
bra_hrmis |>
  dplyr::select(worker_id, org_id, ref_date) |>
  uniqueN()
```

This tells us that we have 334248 unique worker_id-org_id-refdate
combinations in the entire dataset. The goal is to ensure that once all
the other variables of the worker module are added. The size of the
worker module remains the same. As we did, in the contract module, we
now add all the derived variables:

``` r
## lets relabel some more variables


# Create the education harmonization dictionary for educat7
education_dictionary <- data.table(
  ESCOLARIDADE = c(
    "ANALFABETO",
    "1 A 4 SERIE DO PRIM. GRAU INCOMPLETO",
    "5 A 8 SERIE DO PRIM. GRAU INCOMPLETO",
    "1 A 4 SERIE DO PRIM. GRAU COMPLETO",
    "5 A 8 SERIE DO PRIM. GRAU COMPLETO",
    "SEGUNDO GRAU INCOMPLETO",
    "SEGUNDO GRAU COMPLETO",
    "ESPECIALIZAÇÃO COMPLETO",
    "ESPECIALIZAÇÃO INCOMPLETO",
    "ESPECIALIZA«√O COMPLETO",
    "ESPECIALIZA«√O INCOMPLETO",
    "CURSO SUPERIOR COMPLETO",
    "CURSO SUPERIOR INCOMPLETO",
    "MESTRADO INCOMPLETO",
    NA_character_
  ),
  educat7 = c(
    "No education",
    "Primary incomplete",
    "Primary incomplete",
    "Primary complete",
    "Primary complete",
    "Secondary incomplete",
    "Secondary complete",
    "Higher than secondary but not university",
    "Higher than secondary but not university",
    "Higher than secondary but not university",
    "Higher than secondary but not university",
    "University incomplete or complete",
    "University incomplete or complete",
    "University incomplete or complete",
    NA_character_
  )
)

# Merge the dictionary into bra_hrmis
bra_hrmis <- education_dictionary[bra_hrmis, on = "ESCOLARIDADE"]


bra_hrmis <- 
bra_hrmis |>
  setnames(old = c("DATA_NASCIMENTO", "GENERO"),
           new = c("birth_date", "gender"))

### lets prepare the birth date variables
bra_hrmis[, birth_date := as.Date(as.integer(birth_date), origin = "1899-12-30")]
```

    ## Warning in as.Date(as.integer(birth_date), origin = "1899-12-30"): NAs
    ## introduced by coercion

The remainder of the variables (`tribe`,
``` race``) appear to be missing from the ```bra_hrmis`raw data. Therefore, we create them as missing variables (`NA\`).

``` r
bra_hrmis[, c("tribe", "race") := .(NA, NA)] ## lets quickly create the variables that are missing from the raw data
```

Finally, we can create the worker module by taking the set of unique
values across the set of worker modules we have now created within
`bra_hrmis`. See the implementation below:

``` r
bra_hrmis_worker <- 
  bra_hrmis |>
  dplyr::select(worker_id, org_id, ref_date, birth_date, gender, educat7,
                country_name, country_code, adm1_name, adm1_code) |>
  unique()
```

Let’s take a look at the `bra_hrmis_worker`

``` r
glimpse(bra_hrmis_worker)
```

    ## Rows: 338,842
    ## Columns: 10
    ## $ worker_id    <chr> "9678b179d65c7d9a40d1eb2f0c687529762fe73ee1e48e768ca2e3c0…
    ## $ org_id       <chr> "GABINETE CIVIL", "GABINETE CIVIL", "SECRETARIA DE ESTADO…
    ## $ ref_date     <date> 2014-09-01, 2014-09-01, 2014-09-01, 2014-09-01, 2014-09-…
    ## $ birth_date   <date> 1941-12-01, 1953-12-10, 1960-07-25, 1968-04-15, 1966-10-…
    ## $ gender       <chr> "MASCULINO", "FEMININO", "FEMININO", "FEMININO", "MASCULI…
    ## $ educat7      <chr> "Secondary complete", "Primary incomplete", "Higher than …
    ## $ country_name <chr> "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", "Brazil…
    ## $ country_code <chr> "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "…
    ## $ adm1_name    <chr> "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas", "A…
    ## $ adm1_code    <chr> "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL…

### Harmonizing the Organization Module

The Organization Module extracts, standardizes, and structures
information on public-sector organizations from the HRMIS records,
`bra_hrmis`. The steps below convert the raw organization identifiers
into a canonical, well-structured organization register according the
harmonization dictionary. See below:

``` r
### get the set of variables according to the dictionary
bra_hrmis_org <- 
  bra_hrmis |>
  mutate(org_name_native = org_id,
         org_type = NA,
         org_parent = NA,
         org_child = NA) |>
  dplyr::select(org_id, org_name_native, ref_date, org_type, org_parent, org_child,
                country_code, country_name, adm1_name, adm1_code) |>
  unique() |>
  mutate(org_name_en = polyglotr::google_translate(org_name_native, target_language = "en"))


glimpse(bra_hrmis_org)
```

    ## Rows: 256
    ## Columns: 11
    ## $ org_id          <chr> "GABINETE CIVIL", "SECRETARIA DE ESTADO DA ARTICULACAO…
    ## $ org_name_native <chr> "GABINETE CIVIL", "SECRETARIA DE ESTADO DA ARTICULACAO…
    ## $ ref_date        <date> 2014-09-01, 2014-09-01, 2014-09-01, 2014-09-01, 2014-…
    ## $ org_type        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ org_parent      <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ org_child       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
    ## $ country_code    <chr> "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "BRA", "BRA"…
    ## $ country_name    <chr> "Brazil", "Brazil", "Brazil", "Brazil", "Brazil", "Bra…
    ## $ adm1_name       <chr> "Alagoas", "Alagoas", "Alagoas", "Alagoas", "Alagoas",…
    ## $ adm1_code       <chr> "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", …
    ## $ org_name_en     <chr> "CIVIL OFFICE", "STATE SECRETARIAT FOR SOCIAL ARTICULA…

## Quality Check for Harmonized Data

### Quality Control for the Contract Module

The function
[`qualitycheck_contractmod()`](https://wb-pida-data-science-shop.github.io/govhr/reference/qualitycheck_contractmod.md)
performs a comprehensive set of checks on a harmonized HRMIS contract
table. It ensures that all required variables exist, validates their
data types, verifies uniqueness conditions, and conducts salary outlier
analysis using interquartile range (IQR) thresholds.

Key Checks Performed

- Column existence: Ensures all required fields such as contract_id,
  worker_id, org_id, salary fields, date fields, and administrative
  codes are present.

- Uniqueness: Observations must be unique at the contract_id–org_date
  level.

- Type validation: Ensures character, date, and numeric variables are
  correctly typed.

- Salary Outlier Detection: For base_salary_lcu, gross_salary_lcu, and
  net_salary_lcu, the function computes an IQR-based lower and upper
  bound and checks that all values fall within expected ranges.

- Logical constraints: whours must be between 0 and 60. Country codes
  must follow the 3-letter ISO3 format.

- ISCO validation: Checks that occupation codes and occupation names
  exist in the official ISCO classification list.

Please see the check below:

``` r
qualitycheck_contractmod(bra_hrmis_contract |> as_tibble())
```

[TABLE]

### Quality Control for the Worker Module

Worker-level harmonization requires the presence and validity of
demographic, identification, and reference date information. The
function
[`qualitycheck_worker()`](https://wb-pida-data-science-shop.github.io/govhr/reference/qualitycheck_worker.md)
applies minimal but essential validation steps to ensure basic integrity
of the worker table.

Key Checks Performed

- Required variables exist: Including worker_id, ref_date, birth_date,
  gender, educat7, tribe, race, and status.

- Uniqueness: Worker IDs must be unique within each reference date
  (ref_date).

- Non-missingness: Required fields cannot be NA.

- Birthdate validation: Birth dates must fall between 1900-01-01 and
  2000-01-01, which reduces data entry anomalies and impossible DOBs.

Please see the check below:

``` r
qualitycheck_worker(bra_hrmis_worker |> as_tibble())
```

[TABLE]

### Quality Control for the Organization Module

The organization module captures ministry/department/agency identifiers,
names, hierarchical parent-child relationships of public sector
organizations, and geographic attributes. The function
[`qualitycheck_orgmod()`](https://wb-pida-data-science-shop.github.io/govhr/reference/qualitycheck_orgmod.md)
validates structural and coding integrity.

Key Checks Performed

- Required variables exist: org_id, org_name_native, org_parent,
  org_child, country_code, country_name: adm1_name, adm1_code, English
  name (org_name_en)

- Row uniqueness: Each org_id must be unique.

- Non-missingness: All required variables must be populated.

- Type validation: All organization fields must be character.

- ISO3 Validation: Ensures country_code belongs to the official World
  Bank/ISO list using the `countrycode` package.

Please see the check below:

``` r
qualitycheck_orgmod(bra_hrmis_org |> as_tibble())
```

[TABLE]
