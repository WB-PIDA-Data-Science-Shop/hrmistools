#' @title International Standard Classification of Occupations
#' @description The International Classification of Occupations (ISCO) seeks to facilitate international communication about occupations by providing statisticians with a framework to make internationally comparable occupational data available, and by allowing international occupational data to be produced in a form that can be useful for research as well as for specific decision-making and action-oriented activities. The current version, known as ISCO-08, was published in 2008 and is the fourth iteration, following ISCO-58, ISCO-68 and ISCO-88.
#' @format A data frame with 619 rows and 8 variables:
#' \describe{
#'   \item{\code{level}}{character Level of occupation: (1) Major Group, (2) Sub-Major Group, (3) Minor Group, (4) Unit Group}
#'   \item{\code{isco_08_code}}{character Occupation code}
#'   \item{\code{title_en}}{character Title in English}
#'   \item{\code{definition}}{character Definition}
#'   \item{\code{tasks_include}}{character Tasks included}
#'   \item{\code{included_occupations}}{character Included occupations}
#'   \item{\code{excluded_occupations}}{character Excluded occupations}
#'   \item{\code{notes}}{character Notes}
#'}
#' @source <https://ilostat.ilo.org/methods/concepts-and-definitions/classification-occupation/>
"isco"

#' @title Consumer Price Index
#' @description Index of the prices of consumption goods and services, as compared to a certain reference period (2010=100).
#' @format A data frame with 9078 rows and 3 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code}
#'   \item{\code{year}}{character Year}
#'   \item{\code{cpi}}{character Consumer Price Index (2010 = 100)}
#'}
#' @source <https://data360.worldbank.org/en/int/indicator/WB_WDI_FP_CPI_TOTL>
"cpi"

#' @title PPP Conversion Factor
#' @description The purchasing power parity (PPP) conversion factor is a currency conversion factor and a spatial price deflator. They convert different currencies to a common currency and, in the process of conversion, equalize their purchasing power by eliminating the differences in price levels between countries, thereby allowing volume or output comparisons of gross domestic product (GDP) and its expenditure components. This conversion factor is for household final consumption expenditure and the base currency is the US dollar.
#' @format A data frame with 6172 rows and 3 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code}
#'   \item{\code{year}}{character Year}
#'   \item{\code{ppp}}{character PPP conversion factor, private consumption (LCU per international $)}
#'}
#' @source <https://data360.worldbank.org/en/int/indicator/WB_WDI_PA_NUS_PRVT_PP>
"ppp"

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
