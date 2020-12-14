library(readxl)
library(janitor)
library(tidyverse)

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
