library(readxl)
library(janitor)
library(tidyverse)
library(assertr)

# Read in data and clean variable names

ship_data <- read_excel("raw_data/seabirds.xls", 
                        sheet = "Ship data by record ID") %>% 
  clean_names()

seabirds_data <- read_excel("raw_data/seabirds.xls", 
                            sheet = "Bird data by record ID") %>% 
  clean_names()

# Select variables needed for analysis and rename long column names

seabirds_data <- seabirds_data %>% 
  rename(species_common_name = species_common_name_taxon_age_sex_plumage_phase,
         species_scientific_name = 
           species_scientific_name_taxon_age_sex_plumage_phase,
         bird_record_id = record) %>%
  select(bird_record_id,
         record_id, 
         species_common_name, 
         species_scientific_name,
         species_abbreviation,
         count)

ship_data <- ship_data %>%
  rename(ship_record_id = record) %>%
  select(ship_record_id,
         record_id,
         date,
         lat)

# Join ship to bird data
seabirds_data_full <- seabirds_data %>%
  left_join(ship_data, by = "record_id")

# Count NAs in each column
seabirds_data_full %>%
  is.na() %>%
  colSums()

#Investigate NAs in species_abbreviation
species_abbr_na <- seabirds_data_full %>%
  filter(is.na(species_abbreviation)) %>%
  distinct(species_common_name)%>%
  pull()

#Delete rows containing 'NO BIRDS RECORDED' as species_abbreviation
seabirds_data_full <- seabirds_data_full %>%
  mutate(
    species_abbreviation = na_if(species_abbreviation, species_abbr_na)) %>%
  drop_na(species_abbreviation, count)

#Remove age and plumage phases from species name variables
seabirds_data_full <- seabirds_data_full %>% 
  mutate(
    species_common_name = str_remove_all(
      species_common_name, "[A-Z]$|sensu lato|[1-9]| [A-Z]+"),
    species_scientific_name = str_remove_all(
      species_scientific_name, "[A-Z]$|sensu lato|[1-9]| [A-Z]+"),
    species_abbreviation = str_remove_all(
      species_abbreviation, " .*")
  ) 

#Add a genus column
seabirds_data_full <- seabirds_data_full %>% 
  mutate(genus = str_extract(species_scientific_name, "[A-Z][a-z]*"))

#Verify count and latitude variables
seabirds_cleaned <- seabirds_data_full %>%
  verify(count >= 0 & count <= 99999) %>%
  verify((lat >= -90 & lat <= 90) | is.na(lat))
 
#Write to csv
write_csv(seabirds_cleaned, "clean_data/seabirds_cleaned.csv")
