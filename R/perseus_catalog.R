# Parses the Catalog XML
# The catalog is now included in /data and is lazily loaded.
# You can do a manual search of the stylized and human-readable catalog here: http://cts.perseids.org/

get_urn <- function(x) {
  urn <- attributes(x$work$edition)$urn
  if (is.null(urn)) {
    urn <- purrr::pluck(x$work$translation, attr_getter("urn"))
  }
  return(urn)
}

get_title <- function(x) {
  title <- x$work$title[[1]]
  return(title)
}

get_label <- function(x) {
  label <- x$work$edition$label[[1]]
  if (is.null(label)) {
    label <- x$work$translation$label[[1]]
  }
  return(label)
}

get_description <- function(x) {
  description <- x$work$edition$description[[1]]
  if (is.null(description)) {
    description <- x$work$translation$description[[1]]
  }
  return(description)
}

eng_available <- function(x) {
  eng <- TRUE
  eng_check <- attributes(x$work$translation)$lang
  if (is.null(eng_check)) {
    eng <- FALSE
  }
  eng
}

get_catalog_data <- function(x) {
  tibble::tibble(
    urn = get_urn(x),
    title = x$work$title[[1]],
    label = get_label(x),
    description = get_description(x),
    lang = attributes(x$work)$lang,
    english_translation_available = eng_available(x)
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

perseus_xml <- httr::GET("http://cts.perseids.org/api/cts/?request=GetCapabilities") %>%
  httr::content("raw") %>%
  xml2::read_xml() %>%
  xml2::as_list()

perseus_xml <- perseus_xml$reply$TextInventory

perseus_catalog <- map_df(perseus_xml, iterate_and_get_catalog_data)

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

