# Helper script to render cover page content

# define labels for table defining uptake status colours
colour_labels <- c(
  "Lower", "Lower Multiple", "Higher", "Higher Multiple",
  "Normal", "Data Suppressed"
)

# convert to factor
colour_labels <- factor(colour_labels, levels = colour_labels)

# Data frame to define uptake status colours
uptake_status_colours <- data.frame(
  Uptake_Status = colour_labels,
  Definition = c(
    "Data zones where only one benefit has lower than estimated uptake.",
    "Data zones where multiple benefits have lower than estimated uptake.",
    "Data zones where only one benefit has higher than estimated uptake.",
    "Data zones where multiple benefits have higher than estimated uptake.",
    "Data zones where uptake lies within the normal range of estimated uptake.", 
    "Data zones where due to data suppression estimated uptake can not be calculated."
  )
)


# function to render cover page content
cover_page <- function(video_id = "vid_id", colour_data, colour_domain){
  
  tagList(
    
    fluidRow(
      column( width = 12,
              
    div( class = "coverpage_layout",   
         
    # title
    h4("What is meant by 'Unmet Need'?"),
    
    p("This dashboard aims to support users to identify local areas where there 
    may be unmet need in relation to child poverty. Unmet need is defined as cases 
    where families eligible for support, such as social security, do not access this."), 
    
    p("The dashboard highlights data zones that may have unmet need. That is, it highlights 
    areas where the actual rates of uptake for benefits and support related to child 
    poverty differ significantly from the modelled estimated uptake of these. To model estimated uptake, 
    we compare each benefit against a measure of demand, for example, Clothing Grant against the child poverty rate
    for 5 to 15 year olds, and where the child poverty rate is high, we would expect to see higher uptake of a benefit.
    The dashboard is a tool for identifying those areas where uptake differs notably from demand."),
    
    p("Data zones on the map are coloured according to uptake status to show how actual uptake compares against modelled estimated
      uptake. The table below defines the colours used to show whether a data zone has higher or lower uptake for single or multiple
      benefits." ),
    
    p("Also included on this page is a guidance video demonstrating how the dashboard can be used effectively to extract insight from the data 
      and brief explanations about what each page of the dashboard does.")
  )

  ),
  
  
  fluidRow(
         column(
           width = 5,
           div( class = "cover_section",
           h5("Data zone map colour key"),
           div(class = "table_wrapper",
                div( class = "gt_table",
                     colour_data %>% 
                       gt() %>% 
                       data_color(
                         columns = Uptake_Status,
                         method = "factor",
                         palette = c("#f2a8a5", # colour Uptake Status cells
                                     "#e02119",
                                     "#a1f096",
                                     "#38df20",
                                     "white",
                                     "grey"),
                         domain = colour_domain) %>% 
                       cols_label(
                         Uptake_Status = "Uptake Status"
                       ) %>% 
                       tab_style( # format column names and column name cell borders
                         style = list(cell_text(weight = "bold"), 
                                      cell_fill(color = "#f3f3f3"),
                                      cell_borders(sides = c("all"), color = "#003a60", weight = px(3))
                         ),
                         locations = cells_column_labels(columns = c(Uptake_Status, Definition)
                         ) 
                       ) %>% 
                       tab_style( # format cell borders
                         cell_borders(sides = c("all"), color = "#003a60", weight = px(3)),
                         locations = cells_body(columns = c(Uptake_Status, Definition)
                         )
                       ) %>% 
                       tab_style( # format Definition cells
                         cell_fill(color = "#f3f3f3"),
                         locations = cells_body(
                           columns = Definition
                         )
                       ) %>% 
                       tab_style( # format text in Uptake Status column
                         style = cell_text(
                           weight = "bold"
                         ),
                         locations = cells_body(columns = Uptake_Status)
                       ) 
                )
           )),
         
         
      div(class = "cover_section", 
           # video embedding
       h5("Watch the video on how to use the dashboard"),
       div( class = "video_wrapper",
        tags$iframe(
          src = paste0("https://www.youtube.com/embed/", video_id),
          class = "guidance-video",
          frameborder = "0",
          allow = "accelerometer; autoplay; clipboard-write; encrypted-media;
          gyroscope; picture-in-picture; fullscreen",
          allowfullscreen = NA
        )
       )
       )
      ),
      
      column(
        width = 7,
    
      div( class = "coverpage_text",
           
        cover_section(
        title = "1. Data Zone Summary",
        description = "Use the map to explore data zones of interest. You can view uptake for
        all benefits or change selections to look at different combinations or view single benefits. 
        Clicking on the map gives summary information for a data zone which can be 
        explored further in the Data Download tab.",
        button_id = "goto_dz_summary",
        open_tab = "Go to DZ Summary"
      ),
      
      cover_section(
        title = "2. Data Table",
        description = "Use the Data Table tab to find detailed information on areas of interest.
        Each column can be filtered to specific combinations and the data downloaded by clicking on the 
        'Download selected data' button.",
        button_id = "goto_data_download",
        open_tab = "Go to Data Table"
      ),
      
      cover_section(
        title = "3. Change over time",
        description = "Explore how uptake for single benefits has changed over time (currently for education benefits only).
        Select a data zone on the map and use the interactive plot to see how uptake and demand have changed over time.
        More detailed exploration of selected areas can be carried out using the Data Table tab.",
        button_id = "goto_cot",
        open_tab = "Go to Change over Time"
      ),
      
      cover_section(
        title = "4. Methodology",
        description = "This tab contains pages that provide the methods used to create the dashboard, the type of data used, and
        an explanation of how the data is modelled to identify areas where benefit uptake is different to what is expected.
        Each uptake measure has its own page explaining the datasets used to create the uptake and demand measures, the data sources
        and information on which year data was published.",
        button_id = "goto_methods",
        open_tab = "Go to Methodology"
        
        )
      
      
      ),
        div( class = "contact_link", 
        tags$a(href = "mailto:mcm.gw@outlook.com", 
               div(class = "contact_link_text", 
                 tags$strong("Contact us")), target = "_blank")
       )
       )
      
      )
  )
  )
    
  
}



# reusable helper for action buttons
cover_section <- function(title, description, button_id, open_tab){
   div(
     class = "cover_section",
     h5(title),
     p(description),
     actionButton(button_id, open_tab, class = "btn-primary")
   )
}


