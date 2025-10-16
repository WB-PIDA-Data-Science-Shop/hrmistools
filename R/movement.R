#' Detect hire events based on worker and contract data
#'
#' This function identifies hire events by comparing contract start dates
#' with worker activity in previous reference periods. A hire is defined as
#' a contract that appears in the current period but not in the previous one.
#'
#' @param worker_df A data frame or tibble containing worker information.
#'   Must include at least the columns:
#'   - `worker_id`: Unique identifier for each worker.
#'   - `status`: Employment status (e.g., "active").
#'   - `ref_date`: Reference date associated with the worker's record.
#' @param contract_df A data frame or tibble containing contract information.
#'   Must include at least:
#'   - `worker_id`: Worker identifier linking to `worker_df`.
#'   - `contract_id`: Unique contract identifier.
#'   - `org_date`: Contract start or organization date.
#'
#' @return A tibble containing detected hire events with columns:
#'   - `worker_id`
#'   - `contract_id`
#'   - `ref_date`
#'   - `type_event` ("hire")
#'
#' @examples
#' \dontrun{
#' event_hires <- detect_hire_events(worker_df = workers, contract_df = contracts)
#' }
#'
#' @import dplyr
#' @importFrom lubridate years
#' @importFrom tidyr drop_na
#' @export
detect_hire_events <- function(worker_df, contract_df) {
  contract_hire_df <- contract_df |>
    # keep only contracts of workers active at any point in sample
    inner_join(
      worker_df |>
        group_by(worker_id) |>
        filter(any(status == "active")) |>
        ungroup() |>
        distinct(worker_id),
      by = "worker_id"
    ) |>
    rename(ref_date = org_date) |>
    filter(ref_date > min(ref_date)) |>
    group_by(worker_id, contract_id) |>
    summarise(
      ref_date = first(ref_date),
      .groups = "drop"
    )

  # detect hires: workers not present in previous ref_date
  event_hire_df <- contract_hire_df |>
    arrange(worker_id, ref_date) |>
    group_by(worker_id) |>
    mutate(
      ref_date_lag = lag(ref_date)
    ) |>
    anti_join(
      worker_df |> select(worker_id, ref_date),
      by = c("worker_id", "ref_date_lag" = "ref_date")
    ) |>
    mutate(type_event = "hire") |>
    select(-ref_date_lag)

  return(event_hire_df)
}
