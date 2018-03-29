context("parse_excerpt")

test_that("Can parse an excerpt", {
  skip_on_cran()

  x <- parse_excerpt("urn:cts:greekLit:tlg0031.tlg007.perseus-grc2", "1.1-1.5")
  expect_is(x, "data.frame")
})
