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

#Rename columns so they match
candy_2015 <- candy_2015 %>%
  rename(timestamp_id = timestamp,
         age = how_old_are_you,
         going_out = are_you_going_actually_going_trick_or_treating_yourself)


candy_2016 <- candy_2016 %>%
  rename(timestamp_id = timestamp,
         age = how_old_are_you,
         going_out = are_you_going_actually_going_trick_or_treating_yourself,
         country = which_country_do_you_live_in,
         state = which_state_province_county_do_you_live_in)

candy_2017 <- candy_2017 %>%
  rename(timestamp_id = internal_id,
         state = state_province_county_etc)
