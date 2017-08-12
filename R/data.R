#' Metadata for texts available via the Perseus Digital Library.
#'
#' A dataset containing the texts available from the Perseus Digital Library.
#'
#' @format A data frame with 1246 rows and 6 variables:
#' \describe{
#'   \item{lang}{language, "lat"(Latin)/"grc"(Greek)}
#'   \item{groupname}{Could refer to author (e.g. "Aristotle") or corpus (e.g. "New Testament")}
#'   \item{urn}{Uniform Resource Number}
#'   \item{project}{Project identifier, truncated from urn}
#'   \item{label}{Text title, e.g. "Phaedrus"}
#'   \item{description}{text description}
#'   ...
#' }
#' @source \url{http://cts.perseids.org/}
"perseus_catalog"
