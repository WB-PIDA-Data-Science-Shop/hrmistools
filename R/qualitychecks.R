#' Quality Checks for Harmonized HRMIS Contract Data
#'
#' @param contract_tbl A harmonized HRMIS contract tibble (e.g. contract_alagoas_tbl)
#' @param required_vars A character vector of required variable names (from dictionary)
#'
#' @return A pointblank agent with a battery of test results
#' @export
#'
#' @import dplyr tidyr stringr purrr
#' @importFrom pointblank create_agent col_exists rows_distinct action_levels
#' @importFrom pointblank col_is_character col_is_date col_is_numeric
#' @importFrom pointblank col_vals_between col_vals_lte col_vals_gte
#' @importFrom pointblank col_vals_regex interrogate
#' @importFrom stats quantile
#'

qualitycheck_contractmod <- function(contract_tbl,
                                     required_vars = NULL) {

  # Define default required variables if not passed in
  if (is.null(required_vars)) {
    required_vars <- c(
      "contract_id", "worker_id", "org_id", "org_date",
      "base_salary_lcu", "gross_salary_lcu", "net_salary_lcu",
      "whours", "country_code", "start_date", "end_date"
    )
  }

  # Ensure any missing columns are added as NA
  missing_vars <- setdiff(required_vars, names(contract_tbl))
  if (length(missing_vars) > 0) {
    contract_tbl[missing_vars] <- NA
  }

  # Coerce salary fields to numeric
  salary_vars <- c("base_salary_lcu", "gross_salary_lcu", "net_salary_lcu")

  contract_tbl <-
    contract_tbl %>%
    mutate(across(all_of(salary_vars), ~ suppressWarnings(as.numeric(.))))

  # Compute IQR bounds for outlier detection
  compute_outlier <- function(x) {

    q1 <- quantile(x, 0.25, na.rm = TRUE)
    q3 <- quantile(x, 0.75, na.rm = TRUE)
    iqr <- q3 - q1
    lower <- q1 - (1.5 * iqr)
    upper <- q3 + (1.5 * iqr)

    ob_obj <- list(lower = lower, upper = upper)

    return(ob_obj)

  }


  bounds_list <- purrr::map(contract_tbl %>%
                             select(all_of(salary_vars)),
                            compute_outlier)

  al <- action_levels(warn_at = 1)

  # Create pointblank agent and run checks
  agent <-
    contract_tbl %>%
    create_agent(label = "QCheck for Contract Module",
                 actions = al) %>%
    # Column existence
    col_exists(vars(!!!syms(required_vars))) %>%
    # contract data should be unique at the contract id level for each year of data
    rows_distinct(columns = c(contract_id, org_date)) %>%
    # Type checks
    col_is_character(vars(contract_id, worker_id, org_id, country_code)) %>%
    col_is_date(vars(org_date, start_date, end_date)) %>%
    col_is_numeric(columns = c(base_salary_lcu,
                               gross_salary_lcu,
                               net_salary_lcu,
                               whours)) %>%
    #### logical salary checks
    col_vals_between(base_salary_lcu,
                     left = bounds_list$base_salary_lcu$lower,
                     right = bounds_list$base_salary_lcu$upper) %>%
    col_vals_between(gross_salary_lcu,
                     left = bounds_list$gross_salary_lcu$lower,
                     right = bounds_list$gross_salary_lcu$upper) %>%
    col_vals_between(net_salary_lcu,
                     left = bounds_list$net_salary_lcu$lower,
                     right = bounds_list$net_salary_lcu$upper) %>%
    col_vals_lte(whours, value = 60) %>%
    col_vals_gte(whours, value = 0) %>%
    # ISO3 country code format
    col_vals_regex(columns = vars(country_code),
                   regex = "^[A-Z]{3}$") %>%
    interrogate()

  # Return agent and summary

  return(agent)

}





#' Quality Check for Harmonized Organization Module
#'
#' @param org_tbl A data.frame or tibble containing the harmonized organization module
#'
#' @return A pointblank agent object
#' @export
#'
#' @import dplyr pointblank countrycode
#'
#'
qualitycheck_orgmod <- function(org_tbl) {

  required_vars <- c(
    "org_name_native", "org_id", "country_code", "country_name",
    "adm1_name", "adm1_code", "org_parent", "org_child", "org_name_en"
  )

  # Check required columns exist
  missing_vars <- setdiff(required_vars, names(org_tbl))
  if (length(missing_vars) > 0) {
    stop("Missing required variables: ", paste(missing_vars, collapse = ", "))
  }

  al <- action_levels(warn_at = 1)
  # Begin pointblank checks
  agent <-
    org_tbl |>
    create_agent(label = "QCheck for Organization Module",
                 actions = al) |>
    col_exists(columns = required_vars) |>
    rows_distinct(columns = vars(org_id)) |>
    col_vals_not_null(columns = required_vars) |>
    col_is_character(columns = required_vars) |>
    col_vals_in_set(columns = vars(country_code),
                    set = unique(na.omit(countrycode::codelist$iso3c)))

  agent <- agent %>% interrogate()

  return(agent)
}













