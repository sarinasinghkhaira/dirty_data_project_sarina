library(tidyverse)
library(janitor)
library(here)
library(readxl)
#Import the raw data

candy_2015 <- read_excel(here("raw_data/boing-boing-candy-2015.xlsx")) %>%
  clean_names()

candy_2016 <- read_excel(here("raw_data/boing-boing-candy-2016.xlsx")) %>%
  clean_names()

candy_2017 <- read_excel(here("raw_data/boing-boing-candy-2017.xlsx")) %>%
  clean_names()

#remove q1_ prefix from 2017 data
c17_names_removed<- str_remove_all(names(candy_2017), "q[0-9]+_")
names(candy_2017) <- c17_names_removed

#

