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
#' @format A tibble with 17,195 rows and 11 columns:
#' \describe{
#'   \item{country_code}{ISO3 country code (originally from Data360 API).}
#'   \item{year}{Year of observation (character, originally from Data360 API).}
#'   \item{gdp_lcu}{Gross Domestic Product (local currency units). Original WDI code: WB_WDI_NY_GDP_MKTP_CN.}
#'   \item{pexpenditure_lcu}{Total government expenditure (local currency units). Original WDI code: WB_WDI_GC_XPN_TOTL_CN.}
#'   \item{prevenue_lcu}{Total government revenue (local currency units). Original WDI code: WB_WDI_GC_REV_XGRT_CN.}
#'   \item{taxrevenue_lcu}{Total government tax revenue (local currency units). Original WDI code: WB_WDI_GC_TAX_TOTL_CN.}
#'   \item{emp_pop_rate}{Employment-to-population ratio (in percent). Original WDI code: WB_WDI_SL_EMP_TOTL_SP_NE_ZS.}
#'   \item{tot_pop}{Total population. Original WDI code: WB_WDI_SP_POP_TOTL.}
#'   \item{salaried_rate}{Share of employed people who are salaried (in percent). Original WDI code: WB_WDI_SL_EMP_WORK_ZS.}
#'   \item{cpi}{Consumer Price Index, total. Original WDI code: WB_WDI_FP_CPI_TOTL.}
#'   \item{ppp}{Purchasing Power Parity (local currency units per international USD). Original WDI code: WB_WDI_PA_NUS_PRVT_PP.}
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
#' A dataset containing the structure and definitions of the International
#' Standard Classification of Occupations (ISCO-08), as published by the
#' International Labour Organization (ILO).
#'
#' The ISCO provides a system for classifying and aggregating occupational
#' information in order to facilitate international comparisons and
#' harmonization of occupational statistics. It is widely used in labor
#' statistics, survey design, and for policy analysis.
#'
#' @format A data frame with 436 rows and 9 variables:
#' \describe{
#'   \item{isco_version}{Character. Version of the ISCO classification (e.g., "ISCO-08").}
#'   \item{major}{Character. One-digit major group code.}
#'   \item{major_label}{Character. Title of the major group (e.g., "Managers").}
#'   \item{sub_major}{Integer. Two-digit sub-major group code.}
#'   \item{sub_major_label}{Character. Title of the sub-major group (e.g.,
#'   "Chief Executives, Senior Officials and Legislators").}
#'   \item{minor}{Character. Three-digit minor group code.}
#'   \item{minor_label}{Character. Title of the minor group (e.g.,
#'   "Legislators and Senior Officials").}
#'   \item{unit}{Character. Four-digit unit group code.}
#'   \item{description}{Character. Definition of the occupation, following
#'   the official ILO ISCO-08 descriptions (e.g., "Legislators",
#'   "Senior Government Officials").}
#' }
#'
#' @details
#' According to the ILO:
#'
#' *ISCO is designed for international comparability of occupational
#' statistics and for classification of jobs in censuses, household surveys,
#' and administrative records. ISCO-08 is structured hierarchically with:*
#'
#' - \strong{Major groups} (1 digit) – broad occupational categories such as
#'   "Professionals" or "Service and Sales Workers".
#' - \strong{Sub-major groups} (2 digits) – more detailed categories that
#'   subdivide major groups.
#' - \strong{Minor groups} (3 digits) – further disaggregation of sub-major groups.
#' - \strong{Unit groups} (4 digits) – the most detailed level, specifying
#'   occupations with similar tasks and duties.
#'
#' Each unit group includes a definition outlining the tasks and duties that
#' characterize that occupation, as provided by the ILO ISCO documentation.
#'
#' @source International Labour Organization (ILO),
#' \url{https://www.ilo.org/public/english/bureau/stat/isco/}.
#'
#' @examples
#' data(isco)
#' head(isco)
#'
"isco"

