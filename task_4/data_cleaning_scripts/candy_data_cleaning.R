library(tidyverse)
library(janitor)
library(here)
library(readxl)
library(lubridate)
#Import the raw data

candy_2015 <- read_excel(here::here("raw_data/boing-boing-candy-2015.xlsx")) %>%
  clean_names()

candy_2016 <- read_excel(here::here("raw_data/boing-boing-candy-2016.xlsx")) %>%
  clean_names()

candy_2017 <- read_excel(here::here("raw_data/boing-boing-candy-2017.xlsx")) %>%
  clean_names()

#remove q1_ prefix from 2017 data
c17_names_removed<- str_remove_all(names(candy_2017), "q[0-9]+_")
names(candy_2017) <- c17_names_removed

#Rename columns so they match, add a column for year
candy_2015 <- candy_2015 %>%
  rename(age = how_old_are_you,
         going_out = are_you_going_actually_going_trick_or_treating_yourself) %>%
  mutate(year = year(timestamp))


candy_2016 <- candy_2016 %>%
  rename(age = how_old_are_you,
         going_out = are_you_going_actually_going_trick_or_treating_yourself,
         country = which_country_do_you_live_in,
         state = which_state_province_county_do_you_live_in,
         gender = your_gender) %>%
  mutate(year = year(timestamp))

candy_2017 <- candy_2017 %>%
  rename(state = state_province_county_etc) %>%
  mutate(year = 2017)

#Combine 3 tables 
candy <- bind_rows(candy_2015, candy_2016, candy_2017)

#Clean up country data
candy <- candy %>%
  mutate(country = str_to_lower(country),
         country = str_remove_all(country, "[:punct:]|the "),
         country = case_when(
           str_detect(country, "united stat|merica|states|u.s.a|^us$|usa") ~ "usa",
           str_detect(country, "united kin|england|scotland") ~ "uk",
           str_detect(country, "[0-9]") ~ "NA",
           TRUE ~ country
         ))

#Locate candy columns as colums that contain JOY, DESPAIR, MEH or NA
candy_columns <-  candy %>%
  #Replace NA with MISSING so that it comes up as a string
  mutate_if(is.character, ~replace(., is.na(.), "MISSING")) %>% 
  mutate_all(~str_detect(. , "JOY|DESPAIR|MISSING|MEH")) %>%
  summarise_all(~sum(., na.rm = TRUE)) %>%
  pivot_longer(cols = everything(), names_to = 'col_names', values_to = 'values') %>%
  filter(values == nrow(candy)) %>%
  select(col_names) %>%
  pull()


#Select relevant columns
candy_clean <- candy %>% select(
  internal_id,
  age,
  going_out,
  timestamp,
  country,
  state,
  gender,
  year,
  all_of(candy_columns))

#Pivot candy columns longer
candy_pivot <- candy_clean %>%
  pivot_longer(
    cols = all_of(candy_columns),
    names_to = "candy",
    values_to = "response"
  )