#' World Bank Country and Lending Groups
#'
#' This dataset is produced by the World Bank Group to classify countries as to their income levels and other groups.
#'
#' @format ## `countryclass`
#' A data frame with 267 rows and 4 columns:
#' \describe{
#'   \item{country_code}{World Bank country code}
#'   \item{economy}{Country name}
#'   \item{region}{World Bank region}
#'   \item{income_group}{World Bank income classification}
#'   ...
#' }
#' @source <https://ddh-openapi.worldbank.org/resources/DR0095333/download/>
"countryclass"


#' Macro-level World Bank WDI indicators
#'
#' This dataset contains a selection of macroeconomic and labor market indicators
#' for multiple countries and years. The data are primarily sourced from the World
#' Bank World Development Indicators (WDI) via the Data360 API. The variables have
#' been renamed for convenience, but the original WDI variable codes are provided
#' for reference.
#'
#' @format A tibble with 11652 rows and 14 variables:
#' \describe{
#'   \item{country_code}{ISO3 country code (originally from Data360 API).}
#'   \item{year}{Year of observation (character, originally from Data360 API).}
#'   \item{gdp_lcu}{Gross Domestic Product (local currency units). Original WDI code: WB_WDI_NY_GDP_MKTP_CN.}
#'   \item{pexpenditure_lcu}{Total government expenditure (local currency units). Original WDI code: WB_WDI_GC_XPN_TOTL_CN.}
#'   \item{prevenue_lcu}{Total government revenue (local currency units). Original WDI code: WB_WDI_GC_REV_XGRT_CN.}
#'   \item{taxrevenue_lcu}{Total government tax revenue (local currency units). Original WDI code: WB_WDI_GC_TAX_TOTL_CN.}
#'   \item{emp_pop_rate}{Employment-to-population ratio (in percent). Original WDI code: WB_WDI_SL_EMP_TOTL_SP_NE_ZS.}
#'   \item{labor_force_total}{Labor force, total. Original WDI code: WB_WDI_SL_TLF_TOTL_IN.}
#'   \item{labor_force_advanced_edu}{Labor force with advanced education (percentage of total working-age population with advanced education). Original WDI code: WB_WDI_SL_TLF_ADVN_ZS.}
#'   \item{tot_pop}{Total population. Original WDI code: WB_WDI_SP_POP_TOTL.}
#'   \item{government_expenditure_gdp}{General government final consumption expenditure (percentage of GDP). Original WDI code: WB_WDI_NE_CON_GOVT_ZS.}
#'   \item{salaried_rate}{Share of employed people who are salaried (in percent). Original WDI code: WB_WDI_SL_EMP_WORK_ZS.}
#'   \item{cpi}{Consumer Price Index, total. Original WDI code: WB_WDI_FP_CPI_TOTL.}
#'   \item{ppp}{Purchasing Power Parity (local currency units per international USD). Original WDI code: WB_WDI_PA_NUS_PRVT_PP.}
#'   \item{fiscal_balance}{Overall Fiscal Balance, USD, percentage of GDP.}
#'   \item{emp_pop}{The population of employed i.e. `emp_pop_rate` * `tot_pop`.}
#'   \item{salaried_pop}{The population of salaried workers i.e. `salaried_rate` * `emp_pop`.}
#' }
#'
#' @details
#' This dataset was prepared to support wage bill diagnostics and other fiscal
#' and labor market analysis. All numeric variables have been coerced to numeric
#' type. Missing values may exist for certain countries and years.
#'
#' @source Data360 API, World Bank World Development Indicators (WDI)
#' \url{https://data.worldbank.org/indicator}
#'
"macro_indicators"


#' International Standard Classification of Occupations (ISCO-08)
#'
#' A dataset containing the structure of the International
#' Standard Classification of Occupations (ISCO-08), as published by the
#' International Labour Organization (ILO).
#'
#' The ISCO provides a system for classifying and aggregating occupational
#' information to facilitate international comparisons and harmonization of
#' occupational statistics. It is widely used in labor statistics, survey design,
#' and policy analysis.
#'
#' @format A data frame with 436 rows and 9 variables:
#' \describe{
#'   \item{isco_version}{Character. Version of the ISCO classification (e.g., `"ISCO-08"`).}
#'   \item{major}{Character. One-digit major group code.}
#'   \item{major_label}{Character. Title of the major group (e.g., `"Managers"`).}
#'   \item{sub_major}{Character. Two-digit sub-major group code.}
#'   \item{sub_major_label}{Character. Title of the sub-major group (e.g.,
#'   `"Chief Executives, Senior Officials and Legislators"`).}
#'   \item{minor}{Character. Three-digit minor group code.}
#'   \item{minor_label}{Character. Title of the minor group (e.g.,
#'   `"Legislators and Senior Officials"`).}
#'   \item{unit}{Character. Four-digit unit group code.}
#'   \item{description}{Character. Definition or title of the occupation
#'   at the unit group level (e.g., `"Legislators"`, `"Senior Government Officials"`).}
#' }
#'
#' @details
#' ISCO-08 is structured hierarchically:
#' - \strong{Major groups} (1 digit) – broad occupational categories
#' - \strong{Sub-major groups} (2 digits) – subdivisions of major groups
#' - \strong{Minor groups} (3 digits) – subdivisions of sub-major groups
#' - \strong{Unit groups} (4 digits) – most detailed level, individual occupations
#'
#' Each unit group includes a description outlining the scope of the occupation
#' according to ILO’s ISCO-08 documentation.
#'
#' @source International Labour Organization (ILO),
#' \url{https://www.ilo.org/public/english/bureau/stat/isco/}
#'
#' @examples
#' data(isco)
#' head(isco)
"isco"

#' @title Social Sustainability Global Database
#' @description The Social Sustainability global database and its visualization dashboard <https://public.tableau.com/app/profile/social.sustainability.and.inclusion.world.bank/viz/SocialSustainabilityGlobalDashboard2_0/Historia1?publish=yes/> are global public goods produced by the Social Development Global Practice of The World Bank Group. They feature leading indicators of inclusion, resilience, social cohesion, and process legitimacy, for 222 countries, disaggregated by population group and analyzed spatially and over time. In addition, the dashboard allows the user to overlay the indicators in the geospatial platform of the World Bank Group.
#' @format A data frame with 195 rows and 3 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code.}
#'   \item{\code{year}}{numeric Year.}
#'   \item{\code{confidence_in_gov}}{numeric Percentage of population with confidence in government.}
#'}
#' @source World Bank
#' \url{https://datacatalog.worldbank.org/int/search/dataset/0061880/Social-Sustainability-Global-Database-}
"social_sustainability"

#' @title Worldwide Bureaucracy Indicators
#' @description The Worldwide Bureaucracy Indicators (WWBI) database is a unique cross-national dataset on public sector employment and wages that aims to fill an information gap, thereby helping researchers, development practitioners, and policymakers gain a better understanding of the personnel dimensions of state capability, the footprint of the public sector within the overall labor market, and the fiscal implications of the public sector wage bill. The dataset is derived from administrative data and household surveys, thereby complementing existing, expert perception-based approaches.
#' @format A data frame with 993 rows and 11 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code.}
#'   \item{\code{year}}{double Year.}
#'   \item{\code{share_no_edu}}{double Share of public sector workers with no education.}
#'   \item{\code{share_primary_edu}}{double Share of public sector workers with primary education completed.}
#'   \item{\code{share_secondary_edu}}{double Share of public sector workers with secondary education completed.}
#'   \item{\code{share_tertiary_edu}}{double Share of public sector workers with tertiary education completed.}
#'   \item{\code{ps_wage_premium_edu_sector}}{double Public sector wage premium in the education sector, compared to formal sector workers in the private sector.}
#'   \item{\code{ps_wage_premium_hea_sector}}{double Public sector wage premium in the health sector, compared to formal sector workers in the private sector.}
#'   \item{\code{ps_wage_premium_female}}{double Public sector wage premium for female workers, compared to formal sector workers in the private sector.}
#'   \item{\code{ps_wage_premium_male}}{double Public sector wage premium for male workers, compared to formal sector workers in the private sector.}
#'   \item{\code{ps_wage_premium_pooled}}{double Public sector wage premium for all public sector workers, compared to formal sector workers in the private sector.}
#'}
#' @source World Bank
#' \url{https://data360.worldbank.org/en/int/dataset/WB_WWBI}
"wwbi"

#' @title World Bank Enterprise Surveys
#' @description The Formal Sector World Bank Enterprise Surveys, generally known by the shortened term, World Bank Enterprise Surveys (WBES), are the main product of the Enterprise Surveys team. They are nationally representative firm-level surveys with top managers and owners of businesses in over 160 economies, reaching 180 in upcoming years, that provide insight into many business environment topics such as access to finance, corruption, infrastructure, and performance, among others. The comprehensive data and analytical reports enable easy comparisons across economies and time. The information collected through these surveys is publicly available at the economy and firm level. Explore the indicators by economy or topic, browse the surveys, or access the granular data on the WBES data portal.
#' @format A data frame with 413 rows and 3 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code.}
#'   \item{\code{year}}{character Year.}
#'   \item{\code{workforce_constraint}}{character Proportion of establishments identifying an inadequately educated workforce as a major or severe constraint to the current operations of the establishment.}
#'}
#'
#' @source World Bank
#' \url{https://data360.worldbank.org/en/int/indicator/WB_ES_T_WK10}
"enterprise_surveys"


#' Harmonized Public Sector Employment Contracts (Sample)
#'
#' @description
#' A harmonized dataset of 10,000 anonymized public sector employment contracts
#' for Brazil. The data illustrate how administrative human resource (HR)
#' information can be structured for analysis within the
#' **Public Institutions Data and Analytics** framework. Variables include
#' identifiers for contracts, workers, and organizations; employment dates;
#' compensation measures; and occupational classifications.
#'
#' @format A tibble with 10,000 rows and 21 variables:
#' \describe{
#'   \item{contract_id}{Numeric. Unique identifier for the employment contract.}
#'   \item{worker_id}{Numeric. Unique identifier for the worker (anonymized).}
#'   \item{org_id}{Character. Name and code of the employing organization.}
#'   \item{org_date}{Date. Date when the employing organization was established or recorded.}
#'   \item{year}{Numeric. Reference year of the contract record.}
#'   \item{base_salary_lcu}{Numeric. Base salary expressed in local currency units (LCU).}
#'   \item{gross_salary_lcu}{Numeric. Gross salary including allowances and bonuses (LCU).}
#'   \item{net_salary_lcu}{Numeric. Net salary after deductions (LCU).}
#'   \item{whours}{Numeric. Weekly contracted working hours.}
#'   \item{country_code}{Character. ISO3 country code (here, `"BRA"` for Brazil).}
#'   \item{country_name}{Character. Country name.}
#'   \item{adm1_name}{Character. Name of the first administrative division (e.g., state).}
#'   \item{adm1_code}{Character. Administrative division code (e.g., `"AL"` for Alagoas).}
#'   \item{start_date}{Date. Contract start date.}
#'   \item{end_date}{Numeric. Contract end date (may be `NA` for ongoing contracts).}
#'   \item{paygrade}{Character. Pay grade or salary level associated with the contract.}
#'   \item{seniority}{Character. Seniority or position classification code.}
#'   \item{occupation_native}{Character. Original occupation title in the source language (Portuguese).}
#'   \item{occupation_english}{Character. English translation of the occupation title.}
#'   \item{occupation_iscocode}{Numeric. ISCO-08 occupation code, where available.}
#'   \item{occupation_isconame}{Character. ISCO-08 occupation group name.}
#' }
#'
#' @details
#' This dataset provides a harmonized structure for analyzing public employment
#' and compensation across government entities. It is intended as a demonstration
#' dataset for testing data pipelines, HR analytics tools, and summary functions
#' such as [compute_summary()].
#'
#' The variables follow a consistent schema used for HRMIS-type administrative
#' data within the World Bank’s Governance GP. Salary variables are expressed
#' in **local currency units (LCU)** and are not adjusted for inflation.
#'
#' @examples
#' data(contract_harmonized)
#'
#' dplyr::glimpse(contract_harmonized)
#'
#' # Example: Compute mean salary by occupation group
#' compute_summary(contract_harmonized,
#'                 cols = c("gross_salary_lcu"),
#'                 groups = c("occupation_isconame"),
#'                 fns = c("mean"))
#'
#' @source
#' Synthetic dataset generated for illustrative purposes by ChatGPT (2025),
#' based on typical administrative HR data structures used in public sector analytics.
#'
#' @keywords datasets
"contract_harmonized"

#' HRMIS Harmonization Data Dictionary
#'
#' A structured metadata dictionary describing variables harmonized across
#' the Human Resource Management Information System (HRMIS) modules:
#' Organization, Worker, and Contract. The dictionary follows
#' SDMX-style documentation standards and specifies variable names,
#' identifiers, data types (in R), relationships, and other metadata fields
#' used in HRMIS data harmonization.
#'
#' @format A tibble with 48 rows and 9 variables:
#' \describe{
#' \item{Concept Name}{Variable or concept name as used in the HRMIS module.}
#' \item{Concept ID}{Short machine-readable variable name used in datasets.}
#' \item{Description}{Detailed explanation of the variable or concept.}
#' \item{Data Type}{R data type assigned to the variable (e.g., \code{character}, \code{numeric}, \code{Date}).}
#' \item{Representation (Code list / Format)}{Expected format, code list, or data representation.}
#' \item{Primary Key}{Indicates whether the variable uniquely identifies a record (\code{"Yes"} or \code{"No"}).}
#' \item{Relationship}{Describes any relational links to other modules or variables.}
#' \item{Module}{The HRMIS module the variable belongs to: \code{"Organization"}, \code{"Worker"}, or \code{"Contract"}.}
#' \item{Example Value}{Illustrative example value for the variable.}
#' }
#'
#' @details
#' The dictionary integrates all HRMIS modules into a single metadata table.
#' It was designed for use in R-based harmonization workflows and
#' conforms to SDMX Content-Oriented Guidelines (COG) for defining
#' concepts, code lists, and roles.
#'
#' @references
#' SDMX Technical Standards v3.0 — Data Structure Definition (DSD):
#' \url{https://sdmx.org/?page_id=5008}

#'
#' SDMX Content-Oriented Guidelines (COG):
#' \url{https://sdmx.org/?page_id=4345}

#'
#' Eurostat SDMX Metadata Reference Manual:
#' \url{https://ec.europa.eu/eurostat/web/metadata/reference-metadata-reporting-standards}

#'
#' @examples
#'
#' library(dplyr)
#' data(harmonization_dict)
#'
#' # View structure
#' glimpse(harmonization_dict)
#'
#'# Filter dictionary by module
#' harmonization_dict |>
#' filter(Module == "Worker")
#'
"harmonization_dict"
