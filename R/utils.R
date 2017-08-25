reformat_urn <- function(urn) {
  urn <- gsub("urn:cts:|urn.cts.", "", urn)
  urn <- gsub("[:.]", "/", urn)
  return(urn)
}

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
  return(index)
}

extract_text <- function(url) {

  r <- httr::GET(url,
                 httr::user_agent(
                   "rperseus - https://github.com/daranzolin/rperseus")
                 )
  if (r$status_code == 500) stop("Nothing available for that URN.")
  r_list <- r %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  text <- purrr::map(r_list$reply$passage$TEI$text$body$div,
                     ~paste(unlist(.), collapse = " "))
  text <- gsub("\\s+", " ", text)
  text <- gsub("\\*", "", text)
  text <- stringr::str_trim(text)
  text_df <- data_frame(text = text) %>% filter(text != "")
  return(text_df)
}
