#' Get a primary text by urn.
#'
#' @param urn resource number obtained from perseus_catalog
#' @param language which language to be returned. "grc" for Greek, "lat" for Latin, "eng" for English, "heb" for Hebrew.
#'
#' @return a six column tbl_df
#' @import dplyr
#' @export
#'
#' @examples
#' \dontrun{
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg013", language = "grc")
#' get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg002")
#' get_perseus_text(urn = "urn:cts:latinLit:stoa0104p.stoa006", language = "lat")
#' }
get_perseus_text2 <- function(urn, language) {

  if (!urn %in% perseus_catalog$urn) stop("invalid urn: check perseus_catalog for valid urns")
  if (!language %in% c("grc", "lat", "eng", "heb")) stop("language must be one of 'lat', 'grc', 'eng', or 'heb'.")

  new_urn_and_lang <- reformat_urn(urn)

  text_index <- get_full_text_index(new_urn_and_lang["urn"], new_urn_and_lang["lang_part"])
  if (grepl("NA", text_index)) stop("No text available.")

  text_url <- sprintf("http://cts.perseids.org/api/cts/?request=GetPassage&urn=%s:%s", urn, text_index)
  text_df <- extract_text(text_url) %>%
    mutate(urn = urn)
  return(text_df)
}
