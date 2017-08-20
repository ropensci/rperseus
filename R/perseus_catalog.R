# Parses the Catalog XML
# The catalog is now included in /data and is lazily loaded.
# You can do a manual search of the stylized and human-readable catalog here: http://cts.perseids.org/

get_urns <- function(x) {
  urns <- purrr::modify_depth(x, 2, purrr::attr_getter("urn")) %>%
    purrr::flatten() %>%
    purrr::keep(~ !is.null(.)) %>%
    purrr::flatten_chr()
  return(urns)
}

get_labels <- function(x) {
  labels <- purrr::map(purrr::flatten(x), ~.["label"]) %>%
    purrr::flatten() %>%
    purrr::flatten() %>%
    purrr::flatten() %>%
    purrr::keep(~!is.na(.)) %>%
    purrr::flatten_chr()
  return(labels)
}

get_descriptions <- function(x) {
  descriptions <- purrr::map(purrr::flatten(x), ~.["description"]) %>%
    purrr::flatten() %>%
    purrr::flatten() %>%
    purrr::flatten() %>%
    purrr::keep(~!is.na(.)) %>%
    purrr::flatten_chr()
  return(descriptions)
}

get_languages <- function(x) {
  urns <- purrr::modify_depth(x, 2, purrr::attr_getter("urn")) %>%
    purrr::map(make.names) %>%
    purrr::map(~.[-1]) %>%
    purrr::keep(~ length(.) > 0) %>%
    purrr::flatten_chr() %>%
    purrr::keep( ~ nchar(.) > 5)
  lang_regex <- "eng|lat|grc|heb"
  lang_parts <- stringr::str_sub(urns, start = -4L)
  langs <- stringr::str_extract(lang_parts, lang_regex)
  return(langs)
}

get_catalog_data <- function(x) {
  tibble::tibble(
    urn = get_urns(x),
    #title = x$work$title[[1]],
    label = get_labels(x),
    description = get_descriptions(x),
    #language = attributes(x$work)$lang,
    language = get_languages(x)
  )
}

extract_and_recombine <- function(x) {
  xlist <- list()
  for (i in seq_along(x)) {
    xlist[[i]] <- x[i]
  }
  return(xlist)
}

iterate_and_get_catalog_data <- function(x) {
  obj <- x
  groupname <- x$groupname[[1]]
  works <- sum(attributes(obj)$names == "work")
  if (works > 1) {
    obj <- extract_and_recombine(obj[which(names(obj) %in% "work")])
    df <- purrr::map_df(obj, get_catalog_data)
  } else {
    df <- get_catalog_data(obj)
  }
  df <- dplyr::mutate(df, groupname = groupname)
  return(df)
}
