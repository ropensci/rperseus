context("get_perseus_text")

library(stringr)

test_that("Can download Aristotle's Physica", {
  skip_on_cran()

  aristotle <- get_perseus_text("urn:cts:greekLit:tlg0086.tlg031", language = "grc")

  expect_is(aristotle, "tbl_df")
})

test_that("Error thrown when text isn't available for that language", {
  skip_on_cran()

  expect_error(get_perseus_text(urn = "urn:cts:latinLit:stoa0121i.stoa003", language = "eng"),
               "No text available. Try changing the language argument.")

})

test_that("Error thrown when text indices unavailable", {
  skip_on_cran()

  expect_error(get_perseus_text(urn = "urn:cts:greekLit:tlg0031.tlg013", lang = "grc", text = "1.1-1.100"),
               "Nothing available for that text index. Try changing the text argument or leaving it NULL")
})

test_that("Can download the Gospels in English", {
  skip_on_cran()

  g <- perseus_catalog %>%
    filter(grepl("Gospel", label)) %>%
    pull(urn) %>%
    map_df(get_perseus_text, "eng")

  #Should have a lot of God and Jesus talk
  expect_true(sum(str_detect(g$text, "God")) > 50)
  expect_true(sum(str_detect(g$text, "Jesus")) > 50)
})
