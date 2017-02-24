#' Get a primary text by urn
#'
#' @importFrom magrittr "%>%"
#' @param urn resource identifier obtained from get_perseus_catalog()
#' @param lang which language to be returned. "grc" for Greek, "lat" for Latin, and "eng" for English
#' @param text a precise text citation, e.g. '1.1-1.10'
#'
#' @return character vector of primary text
#' @export
#'
#' @examples
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg013", lang = "grc", text = "1.1-1.10")
get_perseus_text <- function(urn, language, text) {
  lang <- switch(language,
                 grc = "perseus-grc",
                 lat = "perseus-lat",
                 eng = "perseus-eng")
  possible_urls <- sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s.%s%d:%s", urn, lang, 1:5, text)
  for (url in possible_urls) {
    resp <- httr::GET(url)
    if (resp$status_code == 200) break
  }
  if (resp$status_code == 500) stop("No text available")
  r_list <- resp %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()
  text <- purrr::map(r_list$reply$passage$TEI$text$body$div, ~paste(unlist(.), collapse = " "))
  text <- gsub("\\s+", " ", text)
  text <- gsub("\\*", "", text)
  text <- stringr::str_trim(text)
  return(text)
}
