#' Get the Perseus Catalog
#'
#' Returns the Perseus catalog, including urn lookups. You can do a manual search here: http://cts.perseids.org/
#'
#' @return catalog data frame
#' @export
#'
#' @examples
#' \dontrun{
#' get_perseus_catalog()
#' }
get_perseus_catalog <- function() {
  options(warn = -1)

  parse_nested_xml <- function(x) {
    attr <- c(attributes(x), attributes(x$work))
    items <- unlist(x)
    c(attr, items) %>%
      purrr::discard( ~length(.) > 1) %>%
      data.frame()
  }

  parse_perseus_xml <- function(x) {
    works <- sum(attributes(x)$names == "work")
    if (works > 1) {
      dat <- purrr::map_df(x, parse_nested_xml) %>%
        dplyr::select(1:7)
    } else {
      dat <- parse_nested_xml(x) %>%
        dplyr::select(1:7)
    }
    names(dat) <- c("lang", "groupname", "urn", "project", "title", "label", "description")
    return(dat)
  }

  perseus_xml <- httr::GET("http://cts.perseids.org/api/cts/?request=GetCapabilities") %>%
    httr::content("raw") %>%
    xml2::read_xml() %>%
    xml2::as_list()

  perseus_catalog <- perseus_xml$reply$TextInventory %>%
    purrr::keep(~ "work" %in% names(.)) %>%
    purrr::map_df(parse_perseus_xml) %>%
    tidyr::fill(groupname) %>%
    dplyr::filter(complete.cases(.),
           nchar(lang) == 3)
  return(perseus_catalog)
}

