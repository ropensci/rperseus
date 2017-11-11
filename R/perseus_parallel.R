#' Render a text parallel with ggplot2
#'
#' @param perseus_df a data frame obtained from \code{get_perseus_text}. Can contain multiple texts.
#' @param words_per_row adjusts the words displayed per "row".
#'
#' @return a ggplot object
#' @export
#'
#' @examples
#' \dontrun{
#' tibble::tibble(label = c("Colossians", rep("1 Thessalonians", 2), "Romans"),
#'                excerpt = c("1.4", "1.3", "5.8", "8.35-8.39")) %>%
#'  dplyr::left_join(perseus_catalog) %>%
#'  dplyr::filter(language == "grc") %>%
#'  dplyr::select(urn, excerpt) %>%
#'  as.list() %>%
#'  purrr::pmap_df(get_perseus_text) %>%
#'  perseus_parallel()
#' }
perseus_parallel <- function(perseus_df, words_per_row = 6) {
  tdf <- perseus_df %>%
    dplyr::rowwise() %>%
    dplyr::mutate(uid = sprintf("%s %s (%s)", label, section, language)) %>%
    split(.$uid) %>%
    purrr::map_df(function(x) {
      tibble::tibble(
        title = x$label,
        section = x$section,
        text = split_every(x$text, words_per_row, " "),
        language = x$language,
        urn = x$urn,
        uid = x$uid,
        x = 1
      )
    }) %>%
    split(.$uid) %>%
    purrr::map_df(function(x) {
      nr <- nrow(x)
      x$y <- 20:(20 - (nr - 1))
      x
    }) %>%
    split(.$uid) %>%
    purrr::map_df(function(x) {
      if (unique(x$language) %in% c("hpt", "hct") || any(is.na(x$language))) {
        x$text <- stringr::str_split(x$text, " ") %>%
          purrr::modify_depth(1, stringi::stri_reverse) %>%
          purrr::map(rev) %>%
          purrr::map(paste, collapse = " ") %>%
          purrr::flatten_chr()
        x
      } else {
        x
      }
    })

    ggplot2::ggplot(tdf, ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_text(ggplot2::aes(label = text, hjust = 0)) +
      ggplot2::xlim(1, 10) +
      ggplot2::ylim(-5, 20) +
      ggplot2::facet_wrap(~uid, nrow = 1) +
      theme_perseus()
}
