reformat_urn <- function(urn) {
  urn <- stringr::str_replace(urn, "urn:cts:|urn.cts.", "")
  stringr::str_replace_all(urn, "[:.]", "/")
}

get_text_url <- function(text_urn, text_index) {
  BASE_URL <- "http://cts.perseids.org/api/cts"
  text_url <- httr::modify_url(BASE_URL,
                   query = list(
                     request = "GetPassage",
                     urn = paste(text_urn, text_index, sep = ":")
                     )
                   )
  text_url
}

#' Gets the full index of a text (start to finish)
#'
#' The API is flexible--you can append a text index to the end of your GET request
#' of varying length. Rather than make multiple calls and iterate through smaller chunks of texts,
#' why not get the entire work in one call?
#'
#' @param new_urn A reformatted urn
#'
#' @return a character index (e.g. "1-110", "1.1-4.5")
#'
#' @examples
#' \dontrun{
#' get_full_text_index("latinLit/stoa0215b/stoa003/opp-lat1")
#' }
get_full_text_index <- function(new_urn) {

  content_url <- paste("http://cts.perseids.org/read", new_urn, sep = "/")
  perseus_html <- httr::GET(content_url) %>%
    httr::content("text") %>%
    xml2::read_html()

  perseus_texts <- perseus_html %>%
    rvest::html_nodes(".col-md-1") %>%
    rvest::html_text() %>%
    as.character() %>%
    stringr::str_trim()

  texts <- stringr::str_split(perseus_texts, "-")
  initial_text <- texts[[1]][1]
  final_text <- texts[[length(texts)]][2]
  if (is.na(final_text)) {
    final_text <- texts[[length(texts)]]
  }
  index <- paste(initial_text, final_text, sep = "-")
  index
}

extract_text <- function(text_url) {

  res <- httr::GET(text_url,
                 httr::user_agent(
                   "rperseus - https://github.com/daranzolin/rperseus")
                 )
  if (res$status_code == 500) stop("Nothing available for that URN.")
  r_list <- res %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  text <- purrr::map(r_list$reply$passage$TEI$text$body$div,
                     ~paste(unlist(.), collapse = " "))
  text <- gsub("\\s+", " ", text)
  text <- gsub("\\*", "", text)
  text <- stringr::str_trim(text)
  text_df <- dplyr::data_frame(text = text) %>% dplyr::filter(text != "")
  text_df
}
