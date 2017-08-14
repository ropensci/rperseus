context("get_perseus_text")

test_that("Can download Aristotle's Physica", {
  skip_on_cran()

  aristotle <- get_perseus_text("urn:cts:greekLit:tlg0086.tlg031", language = "grc")

  expect_is(aristotle, "tbl_df")
})

test_that("Can download the Gospels in English", {
  skip_on_cran()

  gospels <- perseus_catalog %>%
    filter(grepl("Gospel", label)) %>%
    pull(urn) %>%
    map_df(get_perseus_text, "eng")

  #Should have a lot of God and Jesus talk
  expect_gt(sum(stringr::str_detect(gospels$text, "God")), 50)
  expect_gt(sum(stringr::str_detect(gospels$text, "Jesus")), 50)
})

test_that("Error thrown when text isn't available for that language", {
  skip_on_cran()

  expect_error(get_perseus_text(urn = "urn:cts:latinLit:stoa0121i.stoa003", language = "eng"),
               "No text available. Try changing the language argument.")

})
