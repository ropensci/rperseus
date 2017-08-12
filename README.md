
![](https://www.lib.uchicago.edu/efts/PERSEUS/newbanner.png)

[![Build Status](https://travis-ci.org/daranzolin/rperseus.svg?branch=master)](https://travis-ci.org/daranzolin/rperseus.svg?branch=master)

## Description

`rperseus` taps into the API end points at the [Perseus Digital Library's CapiTainS environment.](cts.perseids.org) A wealth of primary texts and translations are available, from Homer to Cicero to Boetheius.

## Installation

`rperseus` is not on CRAN, but can be installed via:

```
devtools::install_github("daranzolin/rperseus")
library(rperseus)
```

## Usage

To obtain a particular text, you must first know its full Uniform Resource Name (urn). Urns can be accessed with a call to `get_perseus_catalog`. For example, say I want to see the opening Latin text of Virgil's *Aeneid:*

```
library(tidyverse)

perseus_catalog <- get_perseus_catalog()

aeneid_urn <- perseus_catalog %>% 
  filter(groupname == "Virgil",
         label == "Aeneid") %>% 
  .$urn

aeneid <- get_perseus_text(urn = aeneid_urn, language = "lat", text = "1.1")
aeneid$text
[1] "Arma virumque cano, Troiae qui primus ab oris"

```

You can request the English translation by changing the `language` argument:

```
aeneid_eng <- get_perseus_text(aeneid_urn, "eng", "1.1")
aeneid_eng$text
[1] "Arms and the man I sing, who first made way, predestined exile, from the Trojan shore to Italy , the blest Lavinian strand. Smitten of storms he was on land and sea by violence of Heaven, to satisfy stern Juno's sleepless wrath; and much in war he suffered, seeking at the last to found the city, and bring o'er his fathers' gods to safe abode in Latium ; whence arose the Latin race, old Alba's reverend lords, and from her hills wide-walled, imperial Rome ."

```

As you can see, the amount of text returned for each language is unstable. To get the equivilent amount of Latin from that passage, you could set the `text` argument to "1.1-1.7". Furthermore, the indexing scheme varies from work to work. The API can require combinations like "1.1-1.5", "1-7", or even "21a-25a". You may have to visit the actual page from time to time to check the scheme.

To obtain the entire work, leave the `text` argument `NULL`. Here's how to retrieve the full greek text from Sophocles' underrated *Philoctetes*:

```
philoctetes <- perseus_catalog %>% 
  filter(groupname == "Sophocles",
         label == "Philoctetes") %>% 
  .$urn %>%
  get_perseus_text("grc")

```

And with the text in hand, you can unleash the `tidytext` tool kit:

```
library(tidytext)

philoctetes %>% 
  unnest_tokens(word, text) %>% 
  count(word, sort = TRUE)
  
# A tibble: 3,667 × 2
          word     n
         <chr> <int>
1  νεοπτόλεμος   164
2   φιλοκτήτης   141
3          καὶ   128
4            ὦ   119
5           δʼ   118
6          γὰρ    90
7         ἀλλʼ    86
8           τί    77
9           μʼ    74
10        πρὸς    70
# ... with 3,657 more rows

```

While there's no obvious way to filter out the Greek stop words and prepositions or recognize the various moods and tenses of Greek verbs, there's still fun to be had.
