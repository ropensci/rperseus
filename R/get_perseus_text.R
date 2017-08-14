#' Get a primary text by urn.
#'
#' @param urn resource number obtained from perseus_catalog
#' @param language which language to be returned. "grc" for Greek, "lat" for Latin, and "eng" for English.
#' @param text a precise text citation, e.g. '1.1-1.10'. If left NULL, the whole work is returned.
#'
#' @return a six column tbl_df
#' @import dplyr
#' @export
#'
#' @examples
#' \dontrun{
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg013", language = "grc", text = "1.1-1.10")
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg002")
#' get_perseus_text(urn = "urn:cts:latinLit:stoa0104p.stoa006", language = "lat")
#' }
get_perseus_text <- function(urn, language = "eng", text = NULL) {

  if (!urn %in% perseus_catalog$urn) stop("invalid urn: check perseus_catalog for valid urns")

  lang_paths <- build_possible_lang_paths(language)
  new_urn <- reformat_urn(urn)
  possible_index_urls <- build_possible_urls(new_urn, lang_paths)
  contents_page <- get_response(possible_index_urls)
  text_index <- get_full_text_index(contents_page)
  if (grepl("NA", text_index)) stop("No text available.")
  correct_lang <- stringr::str_split(contents_page$url, "/")[[1]][8]

  if (is.null(text)) text <- text_index

  text_url <- sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s.%s:%s", urn, correct_lang, text)
  text_df <- extract_text(text_url) %>%
    mutate(urn = urn) %>%
    left_join(perseus_catalog, by = "urn")
  return(text_df)
}
