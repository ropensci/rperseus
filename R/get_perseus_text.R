#' Get a primary text by urn.
#'
#' @param text_urn resource number obtained from perseus_catalog
#'
#' @return a seven column tbl_df
#' @import dplyr
#' @export
#'
#' @examples
#' \dontrun{
#' get_perseus_text("urn:cts:greekLit:tlg0013.tlg028.perseus-eng2")
#' get_perseus_text("urn:cts:greekLit:tlg0013.tlg028.perseus-grc2")
#' get_perseus_text("urn:cts:latinLit:stoa0215b.stoa003.opp-lat1")
#' }
get_perseus_text <- function(text_urn) {

  if (!text_urn %in% internal_perseus_catalog$urn) stop("invalid text_urn argument: check perseus_catalog for valid URNs")

  new_urn <- reformat_urn(text_urn)
  text_index <- get_full_text_index(new_urn)
  if (grepl("NA", text_index)) stop("No text available.")
  text_url <- sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s:%s", text_urn, text_index)
  text_df <- extract_text(text_url) %>%
    dplyr::mutate(urn = text_urn) %>%
    dplyr::left_join(internal_perseus_catalog, by = "urn") %>%
    dplyr::mutate(section = row_number())
  return(text_df)
}
