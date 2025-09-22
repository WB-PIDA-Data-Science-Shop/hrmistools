#' Fetch World Bank Data360 CPI
#'
#' This function retrieves data from the Data360 API.
#'
#' @return A tibble containing data, including country codes, country names,
#'         years, and values.
#' @examples
#' \dontrun{
#'   cpi_data <- get_data360_api("WB_WDI", "WB_WDI_FP_CPI_TOTL")
#'   head(cpi_data)
#' }
#'
#' @param dataset_id Unique identifier for the database.
#' @param indicator_id Indicator ID.
#'
#' @import httr
#' @import dplyr
#' @importFrom janitor clean_names
#' @importFrom jsonlite fromJSON
#' @importFrom tibble as_tibble
#' @export
get_data360_api <- function(dataset_id, indicator_id) {
  base_url <- "https://data360api.worldbank.org/data360/data"

  modified_url <- httr::modify_url(
    base_url,
    query = list(
      DATABASE_ID = dataset_id,
      INDICATOR = indicator_id,
      skip = 0
    )
  )

  res <- httr::GET(modified_url)
  httr::stop_for_status(res)  # error if request fails

  data_json <- httr::content(res, as = "text", encoding = "UTF-8")
  data_list <- jsonlite::fromJSON(data_json)
  count <- data_list$count

  skip_row <- 0
  nrow_data_360 <- 0
  data_360 <- tibble()

  while(nrow_data_360 < count){
    data_url <- httr::modify_url(
      url = modified_url,
      query = list(skip = skip_row)
    )

    data_res <- httr::GET(data_url)
    httr::stop_for_status(res)  # error if request fails

    data_json <- httr::content(data_res, as = "text", encoding = "UTF-8")
    data_list <- jsonlite::fromJSON(data_json)

    data_360 <- data_360 |>
      bind_rows(
        data_list$value
      )

    nrow_data_360 <- nrow(data_360)
    skip_row <- skip_row + 1000
  }

  data_360_clean <- data_360 |>
    pivot_wider(
      id_cols = c(REF_AREA, TIME_PERIOD),
      values_from = OBS_VALUE,
      names_from = INDICATOR
    ) |>
    select(
      country_code = REF_AREA,
      year = TIME_PERIOD,
      everything()
    ) |>
    janitor::clean_names()

  return(data_360_clean)
}

