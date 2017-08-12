context("get_perseus_text")

test_that("A text is returned", {
  skip_on_cran()

  random_urn <- sample(perseus_catalog$urn, 1)
  expect_success(get_perseus_text(random_urn))
})
