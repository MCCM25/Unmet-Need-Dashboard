# Helper script to render cover page content

cover_page <- function(video_id = "vid_id"){
  
  tagList(
    
    # title
    h1("Dashboard Overview"),
    
    p("Watch the short video below on how to use the dashboard"),
    
    # video embedding
    fluidRow(
      column(
        8, offset = 2,
        tags$iframe(
          width = "100%",
          height = "500",
          src = paste0("https://www.youtube.com/embed/", video_id),
          class = "guidance-video",
          frameborder = "0",
          allow = "accelerometer; autoplay; clipboard-write; encrypted-media;
          gyroscope; picture-in-picture; fullscreen",
          allowfullscreen = NA
        )
      )
    ),
    
    br(),
    h3("What is meant by 'Unmet Need'?"),
    
    p("This dashboard aims to support users to identify local areas where there 
    may be unmet need in relation to child poverty. Unmet need is defined as cases 
    where families eligible for support, such as social security, do not access this."), 
    
    p("The dashboard highlights data zones that may have unmet need. That is, it highlights 
    areas where the actual rates of uptake for benefits and support related to child 
    poverty differ significantly from modelled estimated uptake of these. To model estimated uptake, 
    we compare each benefit against a measure of demand, for example, Clothing Grant against the child poverty rate
    for 5 to 15 year olds, and where the child poverty rate is high, we would expect to see higher uptake of a benefit.
    The dashboard is a tool for identifying those areas where uptake differs notably from demand."),
    
    p("Data zones coloured red are areas identified as having recorded benefit uptake notably 
    lower than what has been estimated. Light red data zones highlight areas where only one benefit has lower uptake 
    and dark red data zones highlight areas where multiple benefits have lower uptake."), 
    
    p("Data zones coloured green show areas identified as having recorded benefit uptake notably higher than what has been estimated. Light green data zones highlight
    areas where only one benefit has higher uptake and dark green data zones highlight areas where multiple 
    benefits have higher uptake."), 
    
    p("Although the purpose of the dashboard is identification of areas where households may
    not be claiming the benefits they are entitled to, the dashboard displays data for areas with higher uptake as 
    comparison of these higher uptake areas with lower uptake areas may help to inform why uptake is lower in some areas."),
    
    p("Data zones coloured white are those areas where uptake lies within the normal range."),
    
    br(), br(),
    
    # tab navigation
    fluidRow(
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
    )
    
  )
  
}



# reusable helper for action buttons
cover_section <- function(title, description, button_id, open_tab){
  
 column(
   width = 6,
   div(
     class = "cover-section",
     h3(title),
     p(description),
     actionButton(button_id, open_tab, class = "btn-primary")
   )
 ) 
}