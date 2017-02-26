#' Get a primary text by urn
#'
#' @importFrom magrittr "%>%"
#' @param urn resource identifier obtained from get_perseus_catalog()
#' @param lang which language to be returned. "grc" for Greek, "lat" for Latin, and "eng" for English
#' @param text a precise text citation, e.g. '1.1-1.10'. If left NULL, the whole work is returned.
#'
#' @return character vector of primary text
#' @export
#'
#' @examples
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg013", lang = "grc", text = "1.1-1.10")
get_perseus_text <- function(urn, language, text = NULL) {

  lang <- switch(language,
                 grc = "perseus-grc",
                 lat = "perseus-lat",
                 eng = "perseus-eng")

  if (is.null(text)) {

    urn_parts <- stringr::str_split(urn, ":")[[1]]
    perseus_lang <- urn_parts[3]
    ids <- stringr::str_split(urn_parts[4], "\\.")[[1]]

    possible_urls <- sprintf("http://cts.perseids.org/read/%s/%s/%s/%s%d", perseus_lang, ids[1], ids[2], lang, 1:6)
    resp <- get_ok_response(possible_urls)

    perseus_html <- resp %>%
      httr::content("text") %>%
      xml2::read_html()

    perseus_texts <- perseus_html %>%
      rvest::html_nodes(".col-md-1") %>%
      rvest::html_text() %>%
      as.character() %>%
      stringr::str_trim()

    final_text <- stringr::str_split(perseus_texts[length(perseus_texts)], "-")[[1]][2]
    possible_text1 <- paste("1.1", final_text, sep = "-")
    possible_text2 <- paste("1", final_text, sep = "-")

    xml_urls <- c(sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s.%s%d:%s", urn, lang, 1:5, possible_text1),
                  sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s.%s%d:%s", urn, lang, 1:5, possible_text2))
  } else {
    xml_urls <- sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s.%s%d:%s", urn, lang, 1:5, text)
  }

  resp <- get_ok_response(xml_urls)

  r_list <- resp %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  text <- purrr::map(r_list$reply$passage$TEI$text$body$div, ~paste(unlist(.), collapse = " "))
  text <- gsub("\\s+", " ", text)
  text <- gsub("\\*", "", text)
  text <- stringr::str_trim(text)
  text_df <- dplyr::data_frame(urn = urn, text = text) %>%
    filter(text != "")

  return(text_df)
}
