source("Helper Scripts/cover_page_content.R")
source("Helper Scripts/dashboard_theme.R")

ui <- page_fillable(
  
  theme = dashboard_theme(),
  
  div(class = "header-bar",
      # Left side (IS logo + title)
      div(class = "header-left",
          img(src = "IS Logo RED AND WHITE ONLY.png",class = "logo-is"),
          div(class = "logo-spacer"),
          span("West Lothian Unmet Need Dashboard",class = "header-title")),
      # Right side - WLC logo
      img(src = "wlc logo.png", class = "logo-wlc")),
  
  layout_sidebar(sidebar = sidebar(
    id = "sidebar",
    conditionalPanel(condition = "input.tabs == 'dz_summary' || input.tabs == 'change_over_time'",
                     # to sync year selection across tabs
                     selectInput(inputId = "year_selection",
                                 label = "Please select which year to view",
                                 choices = unique(Data$display_year))),
    # multiple selections for DZ Summary tab
    conditionalPanel(condition = "input.tabs == 'dz_summary'",
                     uiOutput("measure_selection_multiple")),
   # single selections for CoT tab
   conditionalPanel(condition = "input.tabs == 'change_over_time'",
                    uiOutput("measure_selection_single")),
   conditionalPanel(condition = "input.tabs == 'methodology'",
                    uiOutput("methodology_select"))
  ),
    # UI - main body
    navset_tab(id = "tabs",
               
               nav_panel(
                 title = "Overview",
                 value = "cover",
                 cover_page(video_id = "hTRIfY89mk0")
               ),
               
               nav_panel(
                 title = "DZ Summary",
                 value  = "dz_summary",
                 # Card for dz summary map
                 card(full_screen = TRUE, 
                      card_header("Map"),
                      card_body(div(id = "panel_map_dz_summ",
                                    addSpinner(leafletOutput("map_dz_summ", 
                                                  width = "100%", 
                                                  height = "100%"),
                                               spin = "circle")))
                      )
               ),
               nav_panel(title = "Data Table",
                         value = "data_table",
                         # Card for table
                         withSpinner(DTOutput("summary_table"), 
                                     type = 5, 
                                     color = "black")),
               nav_panel(
                 title = "Change over time",
                 value = "change_over_time",
                 card(card_header(textOutput("header_time"))),
                 layout_column_wrap(
                   # Card for change over time map
                   card(full_screen = TRUE, 
                        card_header("Map"),
                        addSpinner(leafletOutput("map_change_over_time", 
                                      width = "100%", 
                                      height = "100%"),
                                   spin = "circle")), 
                   div(class = "plotlyOutput",
                       addSpinner(plotlyOutput(outputId = "line_graph"),
                                  spin = "circle")))
                 ),
               nav_panel(title = "Methodology",
                         value = "methodology",
                         uiOutput("page_title"),
                         withSpinner(DTOutput("methodology_text"),
                                     type = 5, 
                                     color = "black")
                         )
  
               )
    )
  )