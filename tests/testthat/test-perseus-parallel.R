context("perseus_parallel")

test_that("Can plot a perseus text parallel", {
  skip_on_cran()

  x <- tibble::tibble(label = c("Colossians", rep("1 Thessalonians", 2), "Romans"),
              excerpt = c("1.4", "1.3", "5.8", "8.35-8.39")) %>%
    dplyr::left_join(perseus_catalog) %>%
    dplyr::filter(language == "grc") %>%
    dplyr::select(urn, excerpt) %>%
    as.list() %>%
    purrr::pmap_df(get_perseus_text) %>%
    perseus_parallel()

  expect_is(x, "ggplot")
})
