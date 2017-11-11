context("get_perseus_text")

test_that("Can download Aristotle's Physica", {
  skip_on_cran()

  aristotle <- get_perseus_text(urn = "urn:cts:greekLit:tlg0086.tlg031.1st1K-grc1")

  expect_is(aristotle, "tbl_df")
})

test_that("Unaccounted for URNs throw error", {
  skip_on_cran()

  expect_error(
    get_perseus_text(urn = "wrong urn"),
    "invalid text_urn argument: check perseus_catalog for valid URNs")
})
