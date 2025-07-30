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
#' @importFrom purrr map reduce
#' @importFrom tibble tibble
#' @export
find_inconsistent_colnames <- function(data_list) {
  shared_cols <- data_list |>
    map(\(data) tibble(colnames = colnames(data))) |>
    reduce(intersect)

  all_cols <- data_list |>
    map(\(data) tibble(colnames = colnames(data))) |>
    reduce(union)

  symdiff(shared_cols, all_cols)
}

