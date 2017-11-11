#' perseus theme
#'
#' @param base_size base_size
#' @param base_family base_family
#'
#' @return a `ggplot2` theme
#' @noRd
#'
#' @import ggplot2
#'
theme_perseus <- function(base_size = 12, base_family = "Helvetica"){
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      strip.text = element_text(face = "italic"),
      legend.key=element_rect(colour = NA, fill = NA),
      strip.background = element_rect(colour="black", fill="lightgrey"),
      panel.grid = element_blank(),
      panel.border = element_rect(fill = NA, colour = "lightblue", size = 1),
      panel.spacing.x = unit(0, "lines")
    )
}
