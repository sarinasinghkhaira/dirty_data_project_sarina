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

#Clean up country variable
candy_clean <- candy %>%
  mutate(country_fix = str_to_lower(country),
         country_fix = str_remove_all(country_fix, "[:punct:]|the "),
         country_fix = case_when(
           str_detect(
             country_fix, 
             "united s|m[a-z]*ri[ck]a|states|u.s.a|^us[ ]*|usa") ~ "usa",
           str_detect(country_fix, "united kin|england|scotland") ~ "uk",
           str_detect(country_fix, "[0-9]") ~ "NA",
           TRUE ~ country_fix
         ))

#Run this code to check country names 
#candy_clean %>%
#  select(country, country_fix) %>%
#  group_by(country, country_fix) %>%
# summarise(count = n()) %>% view()

#Run this code to check final country names
#unique(candy_clean$country_fix)

#Locate candy columns as columns that contain JOY, DESPAIR, MEH or NA
candy_columns <-  candy_clean %>%
  #Replace NA with MISSING so that it comes up as a string
  mutate_if(is.character, ~replace(., is.na(.), "MISSING")) %>% 
  mutate_all(~str_detect(. , "JOY|DESPAIR|MISSING|MEH")) %>%
  summarise_all(~sum(., na.rm = TRUE)) %>%
  pivot_longer(cols = everything(), 
               names_to = 'col_names', 
               values_to = 'values') %>%
  filter(values == nrow(candy_clean)) %>%
  select(col_names) %>%
  pull()

#Make a unique identifier to replace timestamp and internal_id
candy_clean <- candy_clean %>% 
  rowid_to_column(var = "participant_id")

#Convert going_out to logical
candy_clean <- candy_clean %>% mutate(
  going_out = case_when(
    going_out == "No" ~ FALSE,
    going_out == "Yes" ~ TRUE,
    TRUE ~ NA
  )
)

#Remove noise from age column
candy_clean <- candy_clean %>%
  mutate(age = str_remove_all(age, "[``+``>``<``':,]")) %>%
  mutate(age_fix = case_when(
      as.numeric(age) <= 100 & as.numeric(age) >=4  ~ as.numeric(age),
      TRUE ~ as.numeric(NA)
    ))

    
#Select relevant columns
candy_clean <- candy_clean %>% select(
  participant_id,
  age_fix,
  going_out,
  country_fix,
  gender,
  year,
  all_of(candy_columns)) %>%
  rename(country = country_fix,
         age = age_fix)

#Pivot candy columns longer, drop rows with NA as response
candy_pivot <- candy_clean %>%
  pivot_longer(
    cols = all_of(candy_columns),
    names_to = "candy",
    values_to = "response"
  ) %>%
  drop_na(response)


#Cleaning candy names 
candy_pivot <- candy_pivot %>% 
  mutate(is_candy = case_when(
    str_detect(candy, "cash|dental|acetaminophen|glow_stick|creepy_|healthy_fr_|
               hugs_|bottle_caps|lapel_pins|vicodin|white_bread|
               bonkers_the_board|chardonnay|person_of_interest|
               real_house_wives|sandwich_sized") ~ FALSE,
    TRUE ~ TRUE
  ))

#Write to csv
write_csv(candy_pivot, here::here("clean_data/candy_clean.csv"))

          