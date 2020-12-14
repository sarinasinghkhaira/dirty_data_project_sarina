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

