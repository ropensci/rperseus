reformat_urn <- function(urn) {
  stringr::str_replace(urn, "urn:cts:|urn.cts.", "") %>%
  stringr::str_replace_all("[:.]", "/")
}

get_text_url <- function(text_urn, text_index) {
  BASE_URL <- "http://cts.perseids.org/api/cts"
  httr::modify_url(BASE_URL,
                   query = list(
                     request = "GetPassage",
                     urn = paste(text_urn, text_index, sep = ":")))
}

# This function returns the full index of a text.
#
# The API is flexible--you can append a text index to the end of your GET request
# of varying length. Rather than make multiple calls and iterate through smaller chunks of texts,
# why not get the entire work in one call? Only useful within the package.
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
  paste(initial_text, final_text, sep = "-")
}

extract_text <- function(text_url) {

  res <- httr::GET(text_url,
                 httr::user_agent(
                   "rperseus - https://github.com/daranzolin/rperseus")
                 )
  if (res$status_code == 500) stop("Nothing available for that URN or excerpt.",
                                   call. = FALSE)
  httr::stop_for_status(res)
  r_list <- res %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  text <- purrr::map(r_list$reply$passage$TEI$text$body$div,
                     ~ paste(unlist(.), collapse = " ")) %>%
    stringr::str_replace_all("\\s+", " ") %>%
    stringr::str_replace_all("\\*", "") %>%
    stringr::str_replace_all("/", "") %>%
    stringr::str_trim() %>%
    purrr::discard(~.=="")
  dplyr::data_frame(text = text)
}

split_every <- function(x, n, pattern, collapse = pattern, ...) {
  x_split <- strsplit(x, pattern, perl = TRUE, ...)[[1]]
  out <- character(ceiling(length(x_split) / n))
  for (i in seq_along(out)) {
    entry <- x_split[seq((i - 1) * n + 1, i * n, by = 1)]
    out[i] <- paste0(entry[!is.na(entry)], collapse = collapse)
  }
  out
}
