context("Utility functions")

test_that("Correct index is scraped and returned by get_full_text_index", {
  skip_on_cran()

  ind <- get_full_text_index("greekLit/tlg0059/tlg011/perseus-grc2")
  expect_equal(ind, "172-223")
})

test_that("Lots Jesus talk extracted from the Gospel of Matthew", {
  skip_on_cran()

  BASE_URL <- "http://cts.perseids.org/api/cts/"
  text_url <- httr::modify_url(
    BASE_URL,
    query = list(
      request = "GetPassage",
      urn = "urn:cts:greekLit:tlg0031.tlg001.perseus-eng2:1.1-28.20"
    )
  )

  jc <- extract_text(text_url)
  jc <- length(purrr::flatten_chr(stringr::str_extract_all(jc$text, "Jesus")))
  expect_gt(jc, 100)

})
