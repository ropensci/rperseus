![](https://www.lib.uchicago.edu/efts/PERSEUS/newbanner.png)

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
  .$full_urn

get_perseus_text(urn = aeneid_urn, language = "lat", text = "1.1")
[1] "Arma virumque cano, Troiae qui primus ab oris"

```

You can request the English translation by changing the `language` argument:

```
> get_perseus_text(aeneid_urn, "eng", "1.1")
[1] "Arms and the man I sing, who first made way, predestined exile, from the Trojan shore to Italy , the blest Lavinian strand. Smitten of storms he was on land and sea by violence of Heaven, to satisfy stern Juno's sleepless wrath; and much in war he suffered, seeking at the last to found the city, and bring o'er his fathers' gods to safe abode in Latium ; whence arose the Latin race, old Alba's reverend lords, and from her hills wide-walled, imperial Rome ."

```

As you can see, the amount of text returned for each language is unstable. To get the equivilent amount of Latin from that passage, you could set the `text` argument to "1.1-1.7".

How about some Greek from an underrated play?

```
philoctetes_urn <- perseus_catalog %>% 
  filter(groupname == "Sophocles",
         label == "Philoctetes") %>% 
  .$full_urn

get_perseus_text(philoctetes_urn, "grc", "1-7")
[1] "ἀκτὴ μὲν ἥδε τῆς περιρρύτου χθονὸς Λήμνου, βροτοῖς ἄστιπτος οὐδʼ οἰκουμένη, ἔνθʼ, ὦ κρατίστου πατρὸς Ἑλλήνων τραφεὶς Ἀχιλλέως παῖ Νεοπτόλεμε, τὸν Μηλιᾶ Ποίαντος υἱὸν ἐξέθηκʼ ἐγώ ποτε, ταχθεὶς τόδʼ ἔρδειν τῶν ἀνασσόντων ὕπο, νόσῳ καταστάζοντα διαβόρῳ πόδα·"

```





