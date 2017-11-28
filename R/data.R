#' Metadata for texts available via the Perseus Digital Library.
#'
#' A dataset containing the texts available from the Perseus Digital Library.
#'
#' @format A data frame with 2291 rows and 5 variables:
#' \describe{
#'   \item{urn}{Uniform Resource Number}
#'   \item{group_name}{Could refer to author (e.g. "Aristotle") or corpus (e.g. "New Testament")}
#'   \item{label}{Text label, e.g. "Phaedrus"}
#'   \item{description}{Text description}
#'   \item{language}{Text language, e.g. "grc" = Greek, "lat" = Latin, "eng" = English, "hpt" = Hebrew pointed text, "hct" = Hebrew consonantal text, "ger" = German, "oth" = other}
#' }
#' @source \url{http://cts.perseids.org/api/cts/?request=GetCapabilities}
"perseus_catalog"

#' A dictionary of Greek stop words
#'
#' @format A data frame with 223 rows and 1 variable:
#' \describe{
#'   \item{word}{Greek stop word}
#' }
#' @source Compiled manually by filtering prepositions, pronouns, conjunctions, particles, and articles.
"greek_stop_words"
