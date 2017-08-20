#' Metadata for texts available via the Perseus Digital Library.
#'
#' A dataset containing the texts available from the Perseus Digital Library.
#'
#' @format A data frame with 2291 rows and 5 variables:
#' \describe{
#'   \item{groupname}{Could refer to author (e.g. "Aristotle") or corpus (e.g. "New Testament")}
#'   \item{label}{Text label, e.g. "Phaedrus"}
#'   \item{urn}{Uniform Resource Number}
#'   \item{language}{language, "lat"(Latin)/"grc"(Greek)"heb"(Hebrew)}
#'   \item{description}{Text description}
#'   ...
#' }
#' @source \url{http://cts.perseids.org/api/cts/?request=GetCapabilities}
"perseus_catalog"
