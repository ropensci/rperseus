#' Get a primary text by urn
#'
#' @param urn resource identifier obtained from get_perseus_catalog()
#' @param text a precise text citation, e.g. '1.1-1.10'
#'
#' @return character vector of primary text
#' @export
#' @examples
#' get_perseus_text("urn:cts:greekLit:tlg0031.tlg013", "1.1-1.10")
get_perseus_text <- function(urn, text) {
  url <- sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s:%s", urn, text)
  resp <- httr::GET(url)
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
