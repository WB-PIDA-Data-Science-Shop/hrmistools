################################################################################
######### SOME FUNCTIONS TO SUPPORT HARMONIZATION OF HRMIS DATA ################
################################################################################

#' A function to translate a vector to language of choice
#'
#' This function vectorizes the `polyglotr::google_translate()` function to support
#' translation from `source_language` to any `target_language` of choice.
#'
#' @param vector object containing the list of characters to be translated
#' @param target_language two letter ISO language name for `vector` to be translated
#' into
#' @param source_language two letter ISO language name for `vector` to be translated
#' from
#'
#' @import polyglotr
#'
#' @export


vectorize_gt <- function(vector,
                         target_language = "en",
                         source_language){

  trans_obj <-
  lapply(X = vector,
         FUN = function(x){

           yy <- google_translate(text = x,
                                  target_language = target_language,
                                  source_language = source_language)

           return(yy)

         }) |>
    unlist()


  return(trans_obj)


}

#' A function to identify inconsistent column names across data frames
#'
#' This function checks for consistency in column names across a list of data frames.
#' It returns the symmetric difference between the shared columns (those present in all data frames)
#' and the union of all column names (those present in any data frame).
#'
#' @param data_list A list of data frames to check.
#'
#' @return A character vector of column names that are not shared across all data frames.
#' These are the inconsistent or unique column names that appear in only some of the data frames.
#'
#' @examples
#' df1 <- data.frame(a = 1, b = 2)
#' df2 <- data.frame(a = 3, c = 4)
#' df_list <- list(df1, df2)
#' find_inconsistent_colnames(df_list)
#' # Returns: "b" "c"
#'
#' @importFrom tibble tibble
#' @importFrom dplyr intersect union symdiff
#' @export
find_inconsistent_colnames <- function(data_list) {
  shared_cols <- data_list |>
    purrr::map(
      \(data) tibble::tibble(colnames = colnames(data))
    ) |>
    purrr::reduce(
      dplyr::intersect
    )

  all_cols <- data_list |>
    purrr::map(
      \(data) tibble::tibble(colnames = colnames(data))
    ) |>
    purrr::reduce(
      dplyr::union
    )

  dplyr::symdiff(shared_cols, all_cols)
}

#' Detect Inconsistent Columns in a Data Frame
#'
#' This function checks whether any of the specified column names appear in a given data frame.
#' It is typically used to identify the presence of inconsistent or unexpected column names across multiple data frames.
#'
#' @param data A data frame to inspect.
#' @param inconsistent_cols A character vector of column names considered inconsistent.
#'
#' @return A logical value: `TRUE` if any inconsistent columns are present in the data frame, `FALSE` otherwise.
#'
#' @examples
#' df <- data.frame(a = 1:3, b = 4:6)
#' detect_inconsistent_cols(df, c("c", "d")) # returns FALSE
#' detect_inconsistent_cols(df, c("a", "c")) # returns TRUE
#'
#' @importFrom dplyr select if_else
#' @importFrom tidyselect any_of
#' @export
detect_inconsistent_cols <- function(data, inconsistent_cols) {
  n_inconsistent_cols <- data |>
    dplyr::select(
      tidyselect::any_of(inconsistent_cols)
    ) |>
    ncol()

  dplyr::if_else(
    n_inconsistent_cols > 0,
    TRUE,
    FALSE
  )
}

#' Harmonize column names based on a dictionary
#'
#' This function standardizes column names in a data frame using a dictionary
#' that maps inconsistent or time-varying column names to a standardized set of column names.
#'
#' @param data A data frame whose columns need to be renamed.
#' @param dict Either a named character vector (names are the desired standardized
#'   column names and values are the original column names), or a data frame with
#'   two columns: `from` (original column names) and `to` (standardized names).
#'
#' @return A data frame with harmonized column names.
#'
#' @examples
#' # Using a named character vector
#' dict <- c("age" = "Q1_age", "gender" = "Q2_sex", "income" = "Q3_income")
#' df <- data.frame(Q1_age = 25, Q2_sex = "M", Q3_income = 50000)
#' harmonize_columns(df, dict)
#'
#' # Using a data frame dictionary
#' dict_df <- data.frame(
#'   from = c("Q1_age", "Q2_sex", "Q3_income"),
#'   to = c("age", "gender", "income")
#' )
#' harmonize_columns(df, dict_df)
#'
#' @import dplyr
#' @importFrom purrr set_names
#' @importFrom rlang := !!!
#' @export
harmonize_columns <- function(data, dictionary) {
  # If a data frame is supplied as dict, convert to named vector
  if (is.data.frame(dictionary)) {
    dictionary <- set_names(dictionary$from, dictionary$to)
  }

  # Only include dict entries whose values are actual column names
  available_dictionary <- dictionary[dictionary %in% names(data)]

  # Rename using dplyr::rename and !!! unquoting for tidy evaluation
  data_renamed <- data %>%
    dplyr::rename(
      !!!set_names(available_dictionary, names(available_dictionary))
    ) |>
    select(
      any_of(
        names(available_dictionary)
      )
    )

  return(data_renamed)
}

#' Find Duplicate Identifiers in a Data Frame
#'
#' Identifies duplicated values of a specified identifier column in a data frame or tibble.
#' Returns a tibble with the identifier values that appear more than once and their counts.
#'
#' @param data A data frame or tibble.
#' @param identifier The column to check for duplicates. This should be passed as a bare (unquoted) column name using tidy evaluation.
#'
#' @return A tibble with the identifier column and a count column `n` indicating the number of times each duplicate appears.
#'
#' @importFrom dplyr count filter
#'
#' @examples
#' library(dplyr)
#' library(tibble)
#'
#' df <- tibble(id = c(1, 2, 2, 3, 3, 3, 4))
#' find_duplicate_ids(df, id)
#'
#' @export
find_duplicate_ids <- function(data, identifier){
  data |>
    count({{ identifier }}) |>
    filter(n > 1)
}

