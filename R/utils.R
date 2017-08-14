get_response <- function(urls) {
  for (url in urls) {
    resp <- httr::GET(url)
    if (resp$status_code == 200) break
  }
  if (resp$status_code == 404) {
    stop("No text available. Try changing the language argument.")
  }
  resp
}

build_possible_lang_paths <- function(x) {
  prefixes <- c("1st1K", "opp", "perseus")
  langs <- sprintf("%s-%s", prefixes, x)
  langs <- purrr::map(langs, ~paste0(., 1:6))
  unlist(langs)
}

reformat_urn <- function(urn) {
  urn <- gsub("urn:cts:", "", urn)
  urn <- gsub("[:.]", "/", urn)
  return(urn)
}

build_possible_urls <- function(urn, langs) {
  BASE_URL <- paste("http://cts.perseids.org/read", urn, sep = "/")
  possible_urls <- paste(BASE_URL, langs, sep = "/")
  return(possible_urls)
}

get_full_text_index <- function(resp) {
  perseus_html <- resp %>%
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
  index <- paste(initial_text, final_text, sep = "-")
  return(index)
}

extract_text <- function(url) {

  r_list <- url %>%
    httr::GET() %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  text <- purrr::map(r_list$reply$passage$TEI$text$body$div, ~paste(unlist(.), collapse = " "))
  text <- gsub("\\s+", " ", text)
  text <- gsub("\\*", "", text)
  text <- stringr::str_trim(text)
  text_df <- data_frame(text = text) %>% filter(text != "")
  return(text_df)
}
