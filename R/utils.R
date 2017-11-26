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

parse_form <- function(x) {
  form <- x$f[[1]]
  word <- ifelse(!is.null(x$l$l1[[1]]), x$l$l1[[1]],
                 ifelse(!is.null(x$l$l2[[1]]), x$l$l2[[1]], NA))
  verse <- attr(x, "p")
  parts <- strsplit(attr(x, "o"), "")[[1]]
  tibble::tibble(
    word = word,
    form = form,
    verse = verse,
    part_of_speech = parts[1],
    person = parts[2],
    number = parts[3],
    tense = parts[4],
    mood = parts[5],
    voice = parts[6],
    gender = parts[7],
    case = parts[8],
    degree = parts[9]
  ) %>%
    dplyr::mutate(
      part_of_speech = dplyr::case_when(
        part_of_speech == "n" ~ "noun",
        part_of_speech == "v" ~ "verb",
        part_of_speech == "a" ~ "adjective",
        part_of_speech == "d" ~ "adverb",
        part_of_speech == "l" ~ "article",
        part_of_speech == "g" ~ "particle",
        part_of_speech == "c" ~ "conjunction",
        part_of_speech == "r" ~ "preposition",
        part_of_speech == "p" ~ "pronoun",
        part_of_speech == "m" ~ "numeral",
        part_of_speech == "i" ~ "interjection",
        part_of_speech == "u" ~ "punctuation"
      ),
      person = dplyr::case_when(
        person == "1" ~ "first",
        person == "2" ~ "second",
        person == "3" ~ "third"
      ),
      number = dplyr::case_when(
        number == "s" ~ "singular",
        number == "p" ~ "plural",
        number == "d" ~ "dual"
      ),
      tense = dplyr::case_when(
        tense == "p" ~ "present",
        tense == "i" ~ "imperfect",
        tense == "r" ~ "perfect",
        tense == "l" ~ "pluperfect",
        tense == "t" ~ "future perfect",
        tense == "f" ~ "future",
        tense == "a" ~ "aorist"
      ),
      mood = dplyr::case_when(
        mood == "i" ~ "indicative",
        mood == "s" ~ "sunjunctive",
        mood == "o" ~ "optative",
        mood == "n" ~ "infinitive",
        mood == "m" ~ "imperative",
        mood == "p" ~ "participle"
      ),
      voice = dplyr::case_when(
        voice == "a" ~ "active",
        voice == "p" ~ "passive",
        voice == "m" ~ "middle",
        voice == "e" ~ "medio-passive"
      ),
      gender = dplyr::case_when(
        gender == "m" ~ "masculine",
        gender == "f" ~ "feminine",
        gender == "n" ~ "neuter"
      ),
      case = dplyr::case_when(
        case == "n" ~ "nominative",
        case == "g" ~ "genative",
        case == "d" ~ "dative",
        case == "a" ~ "accusative",
        case == "v" ~ "vocative",
        case == "l" ~ "locative"
      ),
      degree = dplyr::case_when(
        degree == "c" ~ "comparative",
        degree == "s" ~ "superlative"
      )
    )
}

get_lemmatized_greek_text <- function(urn) {
  if (!stringr::str_detect(urn, "-grc")) stop("Only lemmatized Greek texts available.", call. = FALSE)
  urn <- stringr::str_replace(urn, "urn:cts:greekLit:", "")
  url <- sprintf("https://raw.githubusercontent.com/daranzolin/LemmatizedAncientGreekXML/master/texts/%s.xml", urn)
  r <- xml2::read_xml(url)
  xml2::as_list(r)
}

filter_list <- function(text_list, excerpt) {
  p <- strsplit(excerpt, "-")[[1]]
  p1 <- as.numeric(p[1])
  p2 <- as.numeric(p[2])
  vv <- seq(p1, p2, by = 0.01)
  purrr::flatten(text_list) %>%
    purrr::keep(~attr(.x, "p") %in% vv)
}
