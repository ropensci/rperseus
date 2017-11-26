#' Parse a Greek excerpt
#'
#' This function parses a Greek excerpt from the Perseus Digital Library. Parsing includes
#' part of speech, gender, case, mood, voice, tense, person, number, and degree.
#'
#' @param urn a valid urn from the perseus_catalog object.
#' @param excerpt a valid excerpt, e.g. 5.1-5.5
#'
#' @return a data frame
#' @export
#'
#' @examples
#' parse_excerpt("urn:cts:greekLit:tlg0031.tlg002.perseus-grc2", "5.1-5.4")
parse_excerpt <- function(urn, excerpt) {
  get_lemmatized_greek_text(urn) %>%
    filter_list(excerpt) %>%
    purrr::map_df(parse_form)
}
