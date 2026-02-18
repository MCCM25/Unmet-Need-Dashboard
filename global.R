# CPAF Dashboard - Issue # 3 - set up Global script ----------------------------

#libraries
library(shiny)
library(shinydashboard)
library(shinycssloaders)
library(shinyWidgets)
library(bslib)
library(bsicons)
library(htmltools)
library(DT)
library(tidyverse)
library(readr)
library(readxl)
library(leaflet)
library(RColorBrewer)
library(sp)
library(sf)
library(plotly)
library(scales)
library(waiter)
library(gt)

# read in data
Data <- read.csv("Data/comparative_analysis_of_uptake_demand.csv")

# Tidy uptake and demand measure display names
Data <- Data %>% 
  mutate(uptake_measure = case_when(
    uptake_measure == "FSM" ~ "Free School Meals",
    uptake_measure == "CG" ~ "Clothing Grant",
    uptake_measure == "EMA" ~ "Education Maintenance Allowance",
    uptake_measure == "UC" ~ "Universal Credit",
    uptake_measure == "advice" ~ "Money and Welfare Advice",
    TRUE ~ uptake_measure
  ),
  demand_measure = case_when(
    demand_measure == "cilif_age_5_15" ~ "Child poverty rate ages 5-15",
    demand_measure == "cilif_age_10_18" ~ "Child poverty rate ages 10-18",
    demand_measure == "cilif_age_16_18" ~ "Child poverty rate ages 16-18",
    demand_measure == "unemployed_households_with_children" ~ "Unemployed households with children",
    demand_measure == "FV_index" ~ "Financial Vulnerability Index",
    TRUE ~ demand_measure
  )
  ) %>% relocate(display_year, .before = Datazone) %>% # make display_year first column
  arrange(desc(display_year)) # most recent data is default selection

# read in shape files
sf_data <- readRDS("Data/DZ2011_sf.rds")

# read in higher geography data (for IGZs)
dtaGeoHigher <- read_excel("Data/HigherGeos2011.xlsx", sheet = "Data Zones")

# merge sf_data with dtaGeoHigher and filter by West Lothian
sf_data <- sf_data %>% 
  left_join(dtaGeoHigher, by = c("DataZone" = "Datazone")) %>% 
  select("Datazone" = DataZone, Name, geometry, Council) %>% 
  filter(Council == "West Lothian")

# Join names from sf_data to Data for selection in Data Download tab
names <- sf_data %>% select(-Council)
names$geometry <- NULL # remove geometry column

Data <- Data %>% 
  left_join(names, by = "Datazone") %>% 
  relocate(Name, .after = Datazone)

# Data Table Data --------------------------------------------------------------

data_table <- Data %>%
  # set NAs in outliers to "Data Suppressed" for filtering
  mutate(outliers = case_when( 
    is.na(outliers) ~ "Data Suppressed",
    TRUE ~ outliers
  ),
  # covert year to character to generate drop-down selection
  display_year = as.character(display_year)
  ) %>% 
  rename("Year" = "display_year",
         "Datazone name" = "Name",
         "Uptake measure" = "uptake_measure",
         "Actual uptake rate" = "uptake_rate",
         "Measure of demand" = "demand_measure",
         "Demand rate" = "demand_rate",
         "Estimated uptake rate" = "predicted_uptake_rate",
         "How does actual uptake compare to estimated uptake?" = "outliers") %>%
  # Set text columns as factors to enable filtering within the table
  mutate_if(is.character, as.factor) %>%
  mutate(across(c(`Actual uptake rate`, 
                  `Demand rate`, 
                  `Estimated uptake rate`), 
                ~case_when(
                  `Measure of demand` == "Financial Vulnerability Index" & cur_column() == "Demand rate" ~
                    as.character(round(.x, 1)),
                  TRUE ~ paste0(round(.x * 100, 1), "%"))))



# DT datatable function -------------------------------------------------------

# To render Data Table Data in Data Download tab
# Note renderDT() function in server set to server = FALSE to make data download
# client side and allow for all selected data to be downloaded.

summary_table <- datatable(data = data_table,
                           rownames = FALSE,
                           # Adds a filter to each column
                           filter = "top",
                           # Adds download button
                           extensions = 'Buttons',
                           selection = 'none',
                           options = list(
                             # Includes download button, table, info and pages
                             dom = 'Bfrtip',
                             pageLength = 10,
                             buttons = list(
                               list(
                                 extend = "collection",
                                 text = "Download selected data",
                                 buttons = list(
                                   list(
                                     extend = "csv",
                                     filename = "Unmet need data download",
                                     exportOptions = list(
                                       modifier = list(page = "all")
                                     )
                                   ),
                                   list(
                                     extend = "excel",
                                     filename = "Unmet need data download",
                                     exportOptions = list(
                                       modifier = list(page = "all")
                                     )
                                   ),
                                   list(
                                     extend = "pdf",
                                     filename = "Unmet need data download",
                                     exportOptions = list(
                                       modifier = list(page = "all")
                                     )
                                   )
                                 )
                               )
                             ),
                             
                             columnDefs = list(
                               list( # columns narrower: Year and Demand Rate
                                 # Demand rate,
                                 targets = list(0,6,7), # col index starts at zero
                                 width = "25px"
                               ),
                               list( # Datazone, Measure of Demand and 
                                 # Status column widths adjusted
                                 targets = list(1,5,8),
                                 width = "50px"
                               ),
                               list(# columns wider: DZ name, Uptake Measure 
                                 # and Demand Measure
                                 targets = list(2,3,5),
                                 width = "120px"
                               ),
                               list(# narrowed Actual Uptake Rate column
                                 targets = list(4),
                                 width = "20px")
                             )
                           )
) %>%
  # columns = TRUE specifies that the formatting be applied to all columns
  formatStyle(columns = TRUE,
              # valueColumns specify which column to base colours on
              valueColumns = 'How does actual uptake compare to estimated uptake?',
              backgroundColor = styleEqual(c("Higher", "Lower"), 
                                           c('green', 'red')),
              color = styleEqual(c("Higher", "Lower"),
                                 c("white", "white")
              )
            )


# Create map function-------------------------------------------------------

create_map <- function(Data, default_area){
  
  DataMp <- Data
  
  # Set colours 
  clrs <- c("white", 
            "grey",  
            "orange", 
            "#e02119", 
            "#f2a8a5",
            "#a1f096",
            "#38df20")
  
  # set uptake_status to factor to keep values in correct order
  DataMp$uptake_status <- factor(DataMp$uptake_status, 
                                 levels = c("Normal", 
                                            "Data Suppressed",
                                            "Both",
                                            "Lower - multiple",
                                            "Lower",
                                            "Higher",
                                            "Higher - multiple"))
  
  # Assign colours to uptake_status
  pal <- colorFactor(palette = clrs, domain = DataMp$uptake_status)
  
  # Save default selected area for shape boundary
  default_selected_area <- DataMp %>%
    filter(Datazone == default_area) %>%
    pull(geometry)
  
  # Plot map 
  leaflet(DataMp, options = leafletOptions(zoomControl = FALSE)) %>%
    addTiles(urlTemplate = "https://api.os.uk/maps/raster/v1/zxy/Outdoor_3857/{z}/{x}/{y}.png?key=18rIg7nvIh7JPVpMptepmBawj9yMAXv8" , 
             attribution = paste0("Contains <a href='https://www.ordnancesurvey.co.uk/' target='_blank'>OS</a> data © Crown copyright and database right 2024. OS licence number AC0000807570"), 
             group = "OS Basemap",
             options = tileOptions(opacity = 1)) %>% 
    addPolygons(smoothFactor = 1,
                weight = 1.5,
                fillOpacity = 0.6,
                layerId = ~DataMp$Datazone,
                color = "black",
                fillColor = ~pal(DataMp$uptake_status),
                highlightOptions = highlightOptions(color = "white", 
                                                    weight = 3,
                                                    bringToFront = FALSE)) %>% 
    addLegend("bottomright",
              pal = pal,
              values = unique(DataMp$uptake_status),
              title = "Uptake Status",
              opacity = 1) %>%
    htmlwidgets::onRender("function(el, x) {
                  L.control.zoom({ position: 'topright' }).addTo(this)
               }") %>%
    addPolylines(stroke = TRUE,
                 data = default_selected_area,
                 group = "highlighted_polygon",
                 color = "orange",
                 weight = 3,
                 opacity = 0.7)
  
}
