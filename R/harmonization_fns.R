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
