### CPAF DASHBOARD: ISSUE #1 - Create Rates

library(tidyverse)
library(readxl)

# list all the files in the uptake numbers folder
uptake_no <- list.files("Data/Uptake Numbers/", full.names = TRUE) %>% 
  # map applys the read_xlsx function to each of the files passed from the list
  map(., read_xlsx) %>% 
  # list_rbind appends the rows of the different files read in 
  list_rbind() %>% 
  select(-publication_year)

# Do the same for eligibility numbers
eligibility_no <- list.files("Data/Eligibility Numbers/", full.names = TRUE) %>% 
  map(., read_xlsx) %>% 
  list_rbind() %>% 
  select(-publication_year)

# Do the same for demand numbers
demand_no <- list.files("Data/Demand Numbers/", full.names = TRUE) %>% 
  map(., read_xlsx) %>% 
  list_rbind() %>% select(-publication_year)

# Do the same for demand denominators
demand_den <- list.files("Data/Demand Denominators/", full.names = TRUE) %>%
  map(., read_xlsx) %>%
  list_rbind() %>% 
  select(-publication_year)

# Do the same for precalculated uptake rates
precalc_uptake_rate <- list.files("Data/Precalculated uptake rates/", full.names = TRUE) %>% 
  map(., read_xlsx) %>%
  list_rbind() # %>% select(-publication_year) (uncomment once we have pre-calculated uptake rates)

# Do the same for precalculated demand rates - includes FV Index
precalc_demand_rate <- list.files("Data/Precalculated demand rates/", full.names = TRUE) %>% 
  map(., read_xlsx) %>% 
  list_rbind() # %>% select(-publication_year) (uncomment once we have pre-calculated demand rates)

# Read in lookup file
lookup_file <- list.files("Data/lookup_file/", full.names = TRUE) %>%
  map(., read_xlsx) %>% 
  list_rbind() 

# calculate uptake rate using eligibility numbers as denominator
uptake_rates <- uptake_no %>% 
  merge(eligibility_no) %>% 
  # uptake rate then calculated
  mutate(uptake_rate = uptake_number/eligibility_number)

# calculate demand rate using demand_denominator_number as denominator
demand_rates <- demand_no %>%
  merge(demand_den) %>%
  # demand rate then calculated
  mutate(demand_rate = demand_measure_number/demand_denominator_number) 


# merge FV Index with uptake (Advice) measure
precalc_uptake_demand_rates <- uptake_rates %>%
  filter(uptake_measure == "advice") %>%
  select(Datazone, uptake_measure, uptake_rate) %>% 
  left_join(precalc_demand_rate, by = "Datazone")


# Final rates for comparison of uptake rates vs associated demand rates
uptake_demand_rates <- uptake_rates %>%
  merge(lookup_file) %>%
  merge(demand_rates) %>%
  select(Datazone, 
         uptake_measure, 
         uptake_rate, 
         demand_measure, 
         demand_rate, 
         display_year) %>% rbind(precalc_uptake_demand_rates)

# save as .csv to output file
write_csv(uptake_demand_rates, "Data/output_file/uptake_demand_rates.csv")
