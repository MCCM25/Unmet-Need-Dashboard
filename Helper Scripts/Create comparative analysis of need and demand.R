library(tidyverse)
library(readxl)

# Read in data ----------------------------------------

uptake_demand_rates <- read_csv("Data/output_file/uptake_demand_rates.csv")

lookup_file <- read_xlsx("Data/lookup_file/lookup_file.xlsx")

# Create unique uptake measure, demand measure and display year combinations
distinct_list <- uptake_demand_rates %>%
  distinct(uptake_measure, demand_measure, display_year)

uptake_measures_list <- distinct_list$uptake_measure
demand_measures_list <- distinct_list$demand_measure
display_year_list <- distinct_list$display_year

# Create a function to carry out regression analysis --------------------

run_regression <- function(uptake_measure_name, 
                           demand_measure_name,
                           year_name) {
  
  data <- uptake_demand_rates %>%
    # Filter data to match an individual uptake demand pair 
    filter(uptake_measure == uptake_measure_name & 
             demand_measure == demand_measure_name &
             display_year == year_name) 
  
  # Run a regression for the uptake demand pair, excluding missing values
  regression <- lm(uptake_rate ~ demand_rate, 
                   data = data, 
                   na.action = na.exclude)
  
  data <- data %>%
    # Add predicted values, residuals and standardized residuals
    mutate("predicted_uptake_rate" = predict(regression, .)) %>%
    mutate("residuals" = residuals(regression)) %>%
    mutate("standardised_residuals" = 
             round(residuals/sd(residuals, na.rm = TRUE), 2)) %>%
    # Add a column to signal where standardised residuals are outliers 
    mutate("outliers" = if_else(standardised_residuals >= 2, 
                                "Higher", 
                                if_else(standardised_residuals <= -2,
                                        "Lower",
                                        "Normal"))) %>%
    select(-residuals, -standardised_residuals)
}

# Run analysis for all uptake demand pairs and combine into one df ---------------

# pmap loops through the uptake, demand and display year combinations and runs 
# the regression analysis
# list_rbind combines the outputs into one long dataframe
combined_analysis <- list_rbind(pmap(list(uptake_measures_list, 
                                     demand_measures_list,
                                     display_year_list),
                                     run_regression))

# Write data -----------------------------------------------------------------
write.csv(combined_analysis, 
          "Data/comparative_analysis_of_uptake_demand.csv",
          row.names = FALSE)
