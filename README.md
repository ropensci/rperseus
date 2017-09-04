
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/daranzolin/rperseus.svg?branch=master)](https://travis-ci.org/daranzolin/rperseus) [![codecov](https://codecov.io/gh/daranzolin/rperseus/branch/master/graph/badge.svg)](https://codecov.io/gh/daranzolin/rperseus)

Author: David Ranzolin

License: MIT

![](http://www.infobiblio.es/wp-content/uploads/2015/06/perseus-logo.png)

Description
-----------

`rperseus` taps into the API endpoints at the [Perseus Digital Library's](http://www.perseus.tufts.edu/hopper/) CapiTainS environment. A wealth of primary texts and translations are available, from Homer to Cicero to Boetheius.

Installation
------------

`rperseus` is not on CRAN, but can be installed via:

``` r
devtools::install_github("daranzolin/rperseus")
```

Usage
-----

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
