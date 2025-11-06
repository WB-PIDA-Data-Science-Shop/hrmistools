#' Calculate time intervals between reference dates
#'
#' This function computes the time interval between consecutive values
#' in a reference date column, optionally within groups.
#'
#' @param data A data frame or tibble.
#' @param ref_date Name of the column containing reference dates.
#' @param group_vars Optional grouping variables (e.g., `id`, `country`, or `c(id, country)`).
#'
#' @return The original data with an additional set of columns indicating the
#'   difference between consecutive reference dates.
#' @examples
#' library(tibble)
#'
#' df <- tibble(id = c(1, 1, 1, 2, 2),
#'              ref_date = as.Date(c("2020-01-01", "2021-01-01", "2023-01-01",
#'                                   "2020-06-01", "2020-12-01")))
#' calculate_date_intervals(df, "ref_date", "id")
#'
#' @importFrom data.table setDT setorderv copy shift
#' @export
calculate_date_intervals <- function(data, ref_date, group_vars = NULL) {
  # Ensure the input is a data.table for efficient modification
  data.table::setDT(data)

  # Sort by group and then by the date column to ensure correct lagged values
  data.table::setorderv(data, c(group_vars, ref_date))

  # Calculate the interval using get() and shift()
  data_out <- data[,
       .(interval_days = as.numeric(ref_date) - as.numeric(data.table::shift(ref_date, type = "lag"))),
       by = group_vars
  ]

  data_out <- data.table::copy(data)

  return(data_out)
}

#' Detect Worker Events
#'
#' Expands a dataset of workers and reference dates to include all possible
#' worker–date combinations, fills missing periods, and identifies "hire" or
#' "fire" events based on changes in status over time.
#'
#' @param data A data.table or data.frame containing at least the columns:
#'   - `worker_id`: Unique identifier for workers.
#'   - `ref_date`: Reference date (must be coercible to Date).
#'   - `status`: Worker status (e.g., "active", "inactive").
#' @param id_col Character. Name of the identifier column (e.g., `"worker_id"`).
#' @param event_type Character. Either `"hire"` or `"fire"`, controlling which event to detect.
#' @param start_date Optional start date for the full date sequence
#'   (default: `"2007-09-01"`).
#' @param end_date Optional end date for the full date sequence
#'   (default: `"2018-01-01"`).
#' @param freq Frequency for the sequence of dates (default: `"year"`).
#'   Can be any valid value for \code{seq.Date(by = ...)}.
#'
#' @return A dataset with event types detected (e.g., hire or fire).
#'
#' @importFrom data.table as.data.table copy setorderv shift
#' @importFrom lubridate ymd
#'
#' @examples
#' \dontrun{
#' hires <- detect_worker_event(worker_df, id_col = "worker_id", start_date = "2007-09-01",
#'                        end_date = "2018-01-01", event_type = "hire")
#'
#' fires <- detect_worker_event(worker_df, id_col = "worker_id", start_date = "2007-09-01",
#'                        end_date = "2018-01-01", event_type = "fire")
#' }
#' @export
detect_worker_event <- function(data,
                                id_col,
                                event_type,
                                start_date,
                                end_date,
                                freq = "year") {
  # Convert to data.table
  dt <- data.table::as.data.table(data)

  # Filter for active workers
  active_workers_dt <- dt[status == "active"]

  # Build full date range and unique worker IDs
  expanded_active_workers_dt <- active_workers_dt |>
    complete_dates(
      id_col,
      start_date,
      end_date,
      freq
    ) |>
    data.table::copy()

  # Sort by worker and date
  data.table::setorderv(expanded_active_workers_dt, cols = c(id_col, "ref_date"))

  # Add lag/lead and event detection
  if (event_type == "hire") {
    expanded_active_workers_dt[
      ,
      type_event := ifelse(
        status == "active" & is.na(data.table::shift(status, type = "lag")),
        "hire",
        "no hire"
    ), by = id_col]

    expanded_active_workers_dt <- expanded_active_workers_dt[
      ref_date > lubridate::ymd(start_date),
    ]
  } else {
    expanded_active_workers_dt[
      ,
      type_event := ifelse(
        status == "active" & is.na(data.table::shift(status, type = "lead")),
        "fire",
        "no fire"
    ), by = id_col]

    expanded_active_workers_dt <- expanded_active_workers_dt[
      ref_date < lubridate::ymd(end_date),
    ]
  }

  expanded_active_workers_dt <- expanded_active_workers_dt[
    type_event %in% c("hire", "fire"),
    c(id_col, "ref_date", "type_event"),
    with = FALSE
  ]

  data_out <- convert_data(expanded_active_workers_dt, data)

  return(data_out)
}

#' Detect Worker Retirement Events
#'
#' Identifies workers who retired, i.e., whose status changed from "active" to "inactive".
#'
#' @param data A data.frame or data.table with columns `worker_id`, `ref_date`, and `status`.
#'
#' @return A data.table with `worker_id`, `ref_date`, and `type_event = "retire"`.
#'
#' @importFrom data.table as.data.table shift
#'
#' @examples
#' \dontrun{
#' retire_events <- detect_retirement(worker_df)
#' }
#' @export
detect_retirement <- function(data) {
  # Convert to data.table
  dt <- data.table::as.data.table(data)

  # Ensure ordering by worker and date
  data.table::setorderv(dt, cols = c("worker_id", "ref_date"))

  # Create lag_status within each worker
  dt[, lead_status := data.table::shift(status, type = "lead"), by = worker_id]

  # Filter for retire events
  retire_dt <- dt[lead_status == "inactive" & status == "active",
                  .(worker_id, ref_date)]

  # Add event type
  retire_dt[, type_event := "retire"]

  retire_dt <- retire_dt |>
    convert_data(data)

  return(retire_dt)
}

#' Detect Worker Reallocation Events
#'
#' Identifies reallocation events when a worker's set of organizations changes
#' between consecutive reference dates. Removes hire events and only keeps
#' reallocation events after the earliest reference date for each worker.
#'
#' @param data A data.frame or tibble containing at least the columns:
#'   - `worker_id`: Unique worker identifier.
#'   - `ref_date`: Reference date (Date or convertible to Date).
#'   - `org_id`: Organization ID.
#' @param worker_hire A data.frame or tibble containing hire events with columns
#'   `worker_id` and `ref_date`.
#'
#' @return A tibble with columns:
#'   - `worker_id`
#'   - `ref_date`
#'   - `org_id_nested`: List-column of organization IDs for that worker and date.
#'   - `type_event`: `"reallocation"` or `"no reallocation"`.
#'
#' @importFrom dplyr arrange select group_by mutate ungroup distinct filter anti_join lag
#' @importFrom tidyr nest
#' @importFrom purrr map2_chr
#'
#' @examples
#' \dontrun{
#' worker_reallocation_df <- detect_reallocation(contract_rename_org_df, worker_hire_df)
#' }
#' @export
detect_reallocation <- function(data, worker_hire) {
  data_nested <- data %>%
    # Arrange by worker, date, and org
    arrange(worker_id, ref_date, org_id) %>%

    # Keep only relevant columns
    select(worker_id, ref_date, org_id) %>%

    # Nest org_id by worker_id and ref_date
    group_by(worker_id, ref_date) %>%
    nest(.key = "org_id_nested")

  data_reallocation <- data_nested %>%

    # Detect reallocation events by comparing to previous ref_date
    group_by(worker_id) %>%
    mutate(
      type_event = map2_chr(
        org_id_nested,
        lag(org_id_nested),
        ~ ifelse(!identical(.x, .y), "reallocation", "no reallocation")
      )
    ) %>%
    select(-org_id_nested) |>
    ungroup() %>%

    # Remove hire events
    anti_join(
      worker_hire %>% distinct(worker_id, ref_date),
      by = c("worker_id", "ref_date")
    ) %>%

    # Keep only reallocation events after earliest ref_date
    group_by(worker_id) %>%
    filter(ref_date > min(ref_date) & type_event == "reallocation") %>%
    ungroup()

  return(data_reallocation)
}

detect_reallocation2 <- function(data, worker_hire) {
  data_nested <- data %>%
    arrange(worker_id, ref_date, org_id) %>%
    select(worker_id, ref_date, org_id) %>%
    group_by(worker_id, ref_date) %>%
    summarise(org_id_nested = list(unique(org_id)), .groups = "drop")

  data_reallocation <- data_nested %>%
    group_by(worker_id) %>%
    mutate(
      org_from = lag(org_id_nested),
      org_to   = org_id_nested,
      type_event = map2_chr(org_to, org_from,
                            ~ ifelse(!identical(.x, .y),
                                     "reallocation",
                                     "no reallocation"))
    ) %>%
    ungroup() %>%
    anti_join(
      worker_hire %>% distinct(worker_id, ref_date),
      by = c("worker_id", "ref_date")
    ) %>%
    group_by(worker_id) %>%
    filter(ref_date > min(ref_date) & type_event == "reallocation") %>%
    ungroup() %>%
    select(worker_id, ref_date, org_from, org_to, type_event)

  return(data_reallocation)
}

#' Complete Panel Data by Identifier and Reference Dates
#'
#' Expands a dataset to include all combinations of identifiers and reference
#' dates within a specified start–end range. This is useful for ensuring that
#' each identifier has a record for every time point, even if data are missing.
#'
#' @param data A data.frame or data.table containing at least an identifier column.
#' @param id_col Character. Name of the identifier column (e.g., `"worker_id"`).
#' @param start_date Character or Date. Start of the full date sequence
#'   (e.g., `"2007-09-01"`).
#' @param end_date Character or Date. End of the full date sequence
#'   (e.g., `"2018-01-01"`).
#' @param freq Character. Interval for date sequence passed to
#'   \code{seq.Date(by = ...)}. Default is `"year"`.
#'
#' @return A \code{data.table} containing all possible combinations of identifiers
#'   and reference dates between the given start and end points, merged with
#'   the original data.
#'
#' @details
#' This function generates a complete identifier–date grid using
#' \code{seq.Date()} between \code{start_date} and \code{end_date}, then merges
#' it with the original dataset using a left join (\code{all.x = TRUE}).
#'
#' @importFrom data.table as.data.table data.table setnames
#' @importFrom lubridate ymd
#' @importFrom dplyr mutate if_else
#'
#' @examples
#' \dontrun{
#' complete_dt <- complete_dates(
#'   data = worker_df,
#'   id_col = "worker_id",
#'   start_date = "2007-09-01",
#'   end_date = "2018-01-01",
#'   freq = "year"
#' )
#' }
#' @export
complete_dates <- function(
    data,
    id_col,
    start_date,
    end_date,
    freq = "year"
) {
  # Convert to data.table
  dt <- data.table::as.data.table(data)

  dt[
    ,
    expanded := FALSE
  ]

  # Build full date range and unique identifiers
  full_dates <- lubridate::ymd(start_date) %>%
    seq(lubridate::ymd(end_date), by = freq)
  unique_id <- unique(dt[[id_col]])

  # Create complete identifier–date grid
  full_grid <- data.table::data.table(
    id = rep(unique_id, each = length(full_dates)),
    ref_date = rep(full_dates, length(unique_id))
  )

  # Merge grid with original data (dynamic column name assignment)
  expanded_dt <- merge(
    full_grid,
    dt,
    by.x = c("id", "ref_date"),
    by.y = c(id_col, "ref_date"),
    all.x = TRUE
  )

  # Rename id column back to its original name
  data.table::setnames(expanded_dt, "id", id_col)

  expanded_dt <- convert_data(
    expanded_dt,
    data
  ) |>
    dplyr::mutate(
      expanded = dplyr::if_else(
        is.na(.data[["expanded"]]),
        TRUE,
        .data[["expanded"]]
      )
    )

  return(expanded_dt)
}

#' Convert Data to Match Original Class
#'
#' Converts a dataset to have the same class as another reference dataset.
#' This is useful for ensuring consistent output formats when performing
#' operations that temporarily convert data structures (e.g., between
#' `data.table`, `data.frame`, or `tibble`).
#'
#' @param data A dataset to be converted. Typically a `data.table` or `data.frame`.
#' @param data_original The original dataset whose class should be matched.
#'
#' @return The input \code{data} converted to the same class as \code{data_original}.
#'
#' @details
#' The function checks the class of \code{data_original} in the following order:
#' \itemize{
#'   \item If it is a tibble (`tbl_df`), \code{data} is converted using
#'     \code{tibble::as_tibble()}.
#'   \item If it is a base data frame but not a data.table, \code{data} is converted
#'     using \code{as.data.frame()}.
#'   \item Otherwise, \code{data} is returned unchanged (e.g., for data.table input).
#' }
#'
#' @examples
#' \dontrun{
#' df <- data.frame(x = 1:3)
#' dt <- data.table::as.data.table(df)
#'
#' # Convert dt back to data.frame to match df
#' convert_data(dt, df)
#'
#' # Convert to tibble if original was tibble
#' convert_data(dt, tibble::as_tibble(df))
#' }
#'
#' @importFrom tibble as_tibble
#'
convert_data <- function(data, data_original) {
  if ("tbl_df" %in% class(data_original)) {
    data <- tibble::as_tibble(data)
  } else if ("data.frame" %in% class(data_original) && !"data.table" %in% class(data_original)) {
    data <- as.data.frame(data)
  }
  return(data)
}

