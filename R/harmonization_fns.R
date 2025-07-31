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



#' Harmonize Column Classes Across Existing Columns in a List of Data Frames
#'
#' This function takes a list of data frames and ensures that any columns shared
#' across two or more data frames have consistent classes. If a column has
#' different classes across data frames, it is coerced to character in those
#' data frames. Columns that are missing from a data frame are left untouched
#' (i.e., no new columns are added).
#'
#' @param df_list A list of data frames to harmonize.
#'
#' @return A list of data frames with shared columns coerced to the same class if needed.
#'
#' @examples
#' df1 <- data.frame(a = 1:3, b = letters[1:3])
#' df2 <- data.frame(b = factor(letters[4:6]), c = c("x", "y", "z"))
#' result <- harmonize_col_class(list(df1, df2))
#' lapply(result, str)
#'
#' @export
harmonize_col_class <- function(df_list) {
  all_cols <- unique(unlist(lapply(df_list, names)))

  # Step 1: Determine column classes for all existing columns
  col_classes <-
    lapply(df_list,
           function(df) {

              setNames(lapply(names(df),
                              function(col) class(df[[col]])[1]), names(df))

             })

  # Step 2: Find which columns appear in multiple data frames with differing classes
  all_class_info <-
    do.call(rbind, lapply(seq_along(col_classes),
                          function(i) {
                            df_class <- col_classes[[i]]
                            data.frame(df = i,
                                       variable = names(df_class),
                                       class = unlist(df_class),
                                       stringsAsFactors = FALSE)
                            }))

  col_mixed_class <-
    all_class_info |>
    dplyr::group_by(variable) |>
    dplyr::summarise(n = dplyr::n_distinct(class), .groups = "drop") |>
    dplyr::filter(n > 1) |>
    dplyr::pull(variable)

  # Step 3: Harmonize classes for conflicting columns
  df_list <-
    lapply(df_list,
           function(df) {
    for (col in intersect(col_mixed_class, names(df))) {
      df[[col]] <- as.character(df[[col]])
    }
    return(df)
  })

  return(df_list)
}














