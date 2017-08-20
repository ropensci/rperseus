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

#get_titles <- function(x) {
#  titles <- purrr::modify_depth(s3, 1, ~.$title)
#  titles <- purrr::map(titles, ~.[[1]]) %>% purrr::discard(~is.null(.))
#  return(titles)
#}

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


#eng_available <- function(x) {
#  eng <- TRUE
#  eng_check <- attributes(x$work$translation)$lang
#  if (is.null(eng_check)) {
#    eng <- FALSE
#  }
#  eng
#}

#replace_with_eng <- function(x) {
#  gsub("grc|lat|heb", "eng", x)
#}

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

#perseus_xml <- httr::GET("http://cts.perseids.org/api/cts/?request=GetCapabilities") %>%
#  httr::content("raw") %>%
#  xml2::read_xml() %>%
#  xml2::as_list()

#perseus_xml <- perseus_xml$reply$TextInventory

#perseus_catalog <- purrr::map_df(perseus_xml, iterate_and_get_catalog_data)

#for (i in 1:nrow(perseus_catalog)) {
#  english <- perseus_catalog$english_translation_available[i]
#  if (english) {
#    urn <- replace_with_eng(perseus_catalog$urn[i])
#    title <- perseus_catalog$title[i]
#    label <- perseus_catalog$label[i]
#    description <- perseus_catalog$description[i]
#    groupname <- perseus_catalog$groupname[i]
#    lang <- "eng"
#    perseus_catalog <- tibble::add_row(perseus_catalog,
#                                       urn = urn,
#                                       title = title,
#                                       label = label,
#                                       description = description,
#                                       lang = lang,
#                                       groupname = groupname)
#  }
#}

#get_perseus_catalog <- function() {
#  options(warn = -1)
#
#  parse_nested_xml <- function(x) {
#    attr <- c(attributes(x), attributes(x$work))
#    items <- unlist(x)
#    c(attr, items) %>%
#      purrr::discard( ~length(.) > 1) %>%
#      data.frame()
#  }
#
#  parse_perseus_xml <- function(x) {
#    works <- sum(attributes(x)$names == "work")
#    if (works > 1) {
#      dat <- purrr::map_df(x, parse_nested_xml) %>%
#        dplyr::select(1:3, 6:7)
#    } else {
#      dat <- parse_nested_xml(x) %>%
#        dplyr::select(1:3, 6:7)
#    }
#    names(dat) <- c("lang", "groupname", "urn", "label", "description")
#    return(dat)
#  }
#
#  perseus_xml <- httr::GET("http://cts.perseids.org/api/cts/?request=GetCapabilities") %>%
#    httr::content("raw") %>%
#    xml2::read_xml() %>%
#    xml2::as_list()
#  return(perseus_xml)
#}
#
#  perseus_catalog <- perseus_xml %>%
#    purrr::keep(~ "work" %in% names(.)) %>%
#    purrr::map_df(parse_perseus_xml) %>%
#    tidyr::fill(groupname) %>%
#    dplyr::filter(stats::complete.cases(.),
#           nchar(lang) == 3)
#  return(perseus_catalog)
#}


#for (i in 1:length(perseus_xml)) {
#  print(i)
#  df <- iterate_and_get_catalog_data(perseus_xml[[i]])
#}
