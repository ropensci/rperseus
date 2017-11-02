
<!-- README.md is generated from README.Rmd. Please edit that file -->
rperseus
--------

------------------------------------------------------------------------

[![Build Status](https://travis-ci.org/ropensci/rperseus.svg?branch=master)](https://travis-ci.org/ropensci/rperseus) [![codecov](https://codecov.io/gh/ropensci/rperseus/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/rperseus) [![](https://badges.ropensci.org/145_status.svg)](https://github.com/ropensci/onboarding/issues/145)

![](http://www.infobiblio.es/wp-content/uploads/2015/06/perseus-logo.png)

Author: David Ranzolin

License: MIT

Goal
----

The goal of `rperseus` is to furnish classicists, textual critics, and R enthusiasts with texts from the Classical World. While the English translations of most texts are available through `gutenbergr`, `rperseus`returns these works in their original language--Greek, Latin, and Hebrew.

Description
-----------

`rperseus` provides access to classical texts within the [Perseus Digital Library's](http://www.perseus.tufts.edu/hopper/) CapiTainS environment. A wealth of Greek, Latin, and Hebrew texts are available, from Homer to Cicero to Boetheius. The Perseus Digital Library includes English translations in some cases. The base API url is `http://cts.perseids.org/api/cts`.

Installation
------------

`rperseus` is not on CRAN, but can be installed via:

``` r
devtools::install_github("ropensci/rperseus")
```

Usage
-----

[See the vignette to get started.](https://daranzolin.github.io/rperseus//articles/rperseus-vignette.html)

To obtain a particular text, you must first know its full Uniform Resource Name (URN). URNs can be perused in the `perseus_catalog`, a data frame lazily loaded into the package. For example, say I want a copy of Virgil's *Aeneid*:

``` r
library(dplyr)
library(purrr)
library(rperseus)

aeneid_latin <- perseus_catalog %>% 
  filter(group_name == "Virgil",
         label == "Aeneid",
         language == "lat") %>% 
  pull(urn) %>% 
  get_perseus_text()
```

You can also request an English translation for some texts:

``` r
aeneid_english <- perseus_catalog %>% 
  filter(group_name == "Virgil",
         label == "Aeneid",
         language == "eng") %>% 
  pull(urn) %>% 
  get_perseus_text()
```

Refer to the language variable in `perseus_catalog` for translation availability.

tidyverse and tidytext
----------------------

`rperseus` plays well with the `tidyverse` and `tidytext`. Here I obtain all of Plato's works that have English translations available:

``` r
library(purrr)
plato <- perseus_catalog %>% 
  filter(group_name == "Plato",
         language == "eng") %>% 
  pull(urn) %>% 
  map_df(get_perseus_text)
```

And here's how to retrieve the Greek text from Sophocles' underrated *Philoctetes* before unleashing the `tidytext` toolkit:

``` r
library(tidytext)

philoctetes <- perseus_catalog %>% 
  filter(group_name == "Sophocles",
         label == "Philoctetes",
         language == "grc") %>% 
  pull(urn) %>%
  get_perseus_text()

philoctetes %>% 
  unnest_tokens(word, text) %>% 
  count(word, sort = TRUE)
#> # A tibble: 3,667 x 2
#>           word     n
#>          <chr> <int>
#>  1 νεοπτόλεμος   164
#>  2  φιλοκτήτης   141
#>  3         καὶ   128
#>  4           ὦ   119
#>  5          δʼ   118
#>  6         γὰρ    90
#>  7        ἀλλʼ    86
#>  8          τί    77
#>  9          μʼ    74
#> 10        πρὸς    70
#> # ... with 3,657 more rows
```

While there's no obvious way to filter out the Greek stop words and prepositions, or recognize the various moods and tenses of Greek verbs, the text is ripe for analysis!

Meta
----

-   [Report bugs or issues here.](https://github.com/daranzolin/rperseus/issues)
-   If you'd like to contribute to the development of `rperseus`, first get acquainted with the Perseus Digital Library, fork the repo, and send a pull request.
-   This project is released with a [Contributor Code of Conduct.](https://github.com/daranzolin/rperseus/blob/master/CONDUCT.md) By participating in this project, you agree to abide by its terms.

[![ropensci\_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
