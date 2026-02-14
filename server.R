function(input, output, session) {
  
  # Create Ui Inputs -----------------------------------------------------------
  
  output$measure_selection_multiple <- renderUI({
    # Filter data to only include selected year
    Data <- Data %>%
      filter(display_year == selected_year())
    
    # Breaks text into paragraphs to stop them being cut off
    choices_with_breaks <- str_wrap(unique(Data$uptake_measure), width = 22)
    # Replaces break with html version
    choices_with_breaks <- str_replace_all(choices_with_breaks, "\\n", "<br>")
    
    pickerInput(inputId = "uptake_measure_selection_multiple",
                label = "Please select which uptake measures to include",
                choices = unique(Data$uptake_measure),
                selected = unique(Data$uptake_measure),
                options = list(`actions-box` = TRUE,
                               `selected-text-format` = 'count'),
                # Ensures visible choices are those with breaks
                choicesOpt = list(content = choices_with_breaks),
                multiple = TRUE)
  })
  
  output$measure_selection_single <- renderUI({
    
    req(selected_year())
    
    # Filter data to only include choices for selected year
    Data <- Data %>% 
      group_by(uptake_measure) %>% 
      filter(n_distinct(display_year) > 1) %>% 
      ungroup() %>% 
      filter(display_year == selected_year())
    
    # Breaks text into paragraphs to stop them being cut off
    choices_with_breaks <- str_wrap(unique(Data$uptake_measure), width = 22)
    # Replaces break with html version
    choices_with_breaks <- str_replace_all(choices_with_breaks, "\\n", "<br>")
    
    pickerInput(inputId = "uptake_measure_selection_single",
                label = "Please select an uptake measure to view",
                choices = unique(Data$uptake_measure),
                selected = unique(Data$uptake_measure)[1],
                choicesOpt = list(content = choices_with_breaks),
                options = list(`actions-box` = TRUE,
                               multiple = FALSE))
  })
  
  # Methodology info selection
  output$methodology_select <- renderUI({
    
    # get names
    choice_names <- excel_sheets("Helper Scripts/Methodology.xlsx")
    
    # Breaks text into paragraphs to stop them being cut off
    choices_with_breaks <- str_wrap(choice_names, width = 22)
    # Replaces break with html version
    choices_with_breaks <- str_replace_all(choices_with_breaks, "\\n", "<br>")
    
    pickerInput(
      inputId = "methodology_selection",
      label = "Please select an item for methodology information",
      choices = choice_names,
      selected = "General",
      choicesOpt = list(content = choices_with_breaks),
      options = list(`actions box` = TRUE, multiple = FALSE)
    )
    
  })
  
  # Reactive expressions to store input values ----------------------------------  
  
  # Reactive value for year selection - DZ Summary
  selected_year <- reactive({
    input$year_selection
  })
  
  # Reactive value for small area selection
  # Currently default to first small area in the data
  # This will update on user selection
  selected_small_area <- reactiveVal(first(Data$Datazone)) 
  
  # Reactive value for uptake measure selections - DZ summary
  selected_uptake_measures_multiple <- reactive({
    input$uptake_measure_selection_multiple
    })
  
  # Reactive value for individual measure selection - Change over time
  selected_uptake_measure_single <- reactive({
    input$uptake_measure_selection_single
  })
  
# Create data to use in map ----------------------------------   
  # map_data to join with shape files
  map_data_dz_summ <- reactive({
    
    validate(need(input$uptake_measure_selection_multiple != "",
                  "Uptake measure selections needed"))
    
    map_data <- Data %>% 
      # Filter to only include the year and uptake measures selected
      filter(display_year == selected_year() &
               uptake_measure %in% selected_uptake_measures_multiple()) %>% 
      select(Datazone, uptake_measure, outliers) %>% 
      pivot_wider(id_cols = Datazone, 
                  names_from = "uptake_measure", 
                  values_from = "outliers") %>% 
      rowwise() %>% 
      mutate(
        # Sum across different uptake measures to count status's
        n_higher = sum(c_across(where(is.character)) == "Higher", na.rm = TRUE),
        n_lower = sum(c_across(where(is.character)) == "Lower", na.rm = TRUE),
        n_normal = sum(c_across(where(is.character)) == "Normal", na.rm = TRUE),
        # add uptake measure status column
        uptake_status = ifelse(n_lower > 0 & n_higher > 0, "Lower",
                               ifelse(n_higher == 1, "Higher",
                                      ifelse(n_higher > 1, "Higher - multiple",
                                             ifelse(n_lower == 1, "Lower",
                                                    ifelse(n_lower > 1, 
                                                           "Lower - multiple",
                                                           ifelse(n_normal > 0, 
                                                                  "Normal", 
                                                                  "Data Suppressed"
                                                           ))))))) %>% 
      ungroup() %>% 
      select(-n_higher, -n_lower, -n_normal)
    
    # Create pop up messages to display which benefits are higher/lower
    pop_up_data <- map_data %>% 
      pivot_longer(cols = c(-Datazone, -uptake_status),
                   names_to = "uptake_measure",
                   values_to = "indi_benefit_status") %>% 
      # NA needs to be replaced with text here otherwise str_c won't work
      mutate(indi_benefit_status = replace_na(indi_benefit_status, "NA")) %>%
      group_by(Datazone) %>% 
      # If else statements tests checks what the overall status is for the datazone
      # If lower, higher or both, it then uses str_c to combine each of the individual
      # uptake measures that have that status and pastes it with a message
      mutate(pop_up = if_else(
        uptake_status %in% c("Lower", "Lower - multiple"),
        paste("<strong>Benefits with lower than expected uptake: </strong>", 
              str_c(uptake_measure[indi_benefit_status == "Lower"], 
                    collapse = ", ")),
        if_else(
          uptake_status %in% c("Higher", "Higher - multiple"),
          paste("<strong>Benefits with higher than expected uptake: </strong>",
                str_c(uptake_measure[indi_benefit_status == "Higher"], 
                      collapse = ", ")),
          if_else(
            uptake_status == "Both",
            paste("Benefits lower: ", 
                  str_c(uptake_measure[indi_benefit_status == "Lower"], 
                        collapse = ", "),
                  " Benefits higher : ",
                  str_c(uptake_measure[indi_benefit_status == "Higher"], 
                        collapse = ", ")),
            "")))) %>%
      # This filters the rows to only include one message per DZ, the same message
      # is in each of the rows so distinct will return one row per DZ
      group_by(Datazone) %>%
      distinct(pop_up)
    
    # Join pop up message to map data
    map_data <- map_data %>% 
      left_join(pop_up_data, by = "Datazone") 
    
    # Join map data with shape file
    map_data_merged <- sf_data %>%
      left_join(map_data, by = "Datazone")%>%
      # set geometry to WGS84 (required for sf)
      st_transform(., crs = 4326) %>%
      # set status message for pop-ups
      mutate(
        status_msg = case_when(
          uptake_status == "Lower - multiple" ~ "Lower than expected uptake in multiple uptake measures", 
          uptake_status == "Lower" ~ "Lower than expected uptake for one uptake measure",
          uptake_status == "Higher" ~ "Higher than expected uptake for one uptake measure",
          uptake_status == "Higher - multiple" ~ "Higher than expected uptake in multiple uptake measures",
          uptake_status == "Both" ~ "Higher/Lower expected uptake",
          uptake_status == "Normal" ~ "No difference to what is expected",
          uptake_status == "Data Suppressed" ~ "Data not available"
        )
      )
    
  }) %>%
    bindCache(selected_year(), selected_uptake_measures_multiple())
  
  # map data for change over time tab
  map_data_change_over_time <- reactive({
    
    validate(need(input$uptake_measure_selection_single != "",
                  "Uptake measure selection needed"))
    
    map_data <- Data %>%
      filter(display_year == selected_year(),
             uptake_measure == selected_uptake_measure_single()) %>%
      select(Datazone, uptake_measure, outliers) %>%
      mutate(uptake_status = outliers,
             uptake_status = case_when(
               is.na(uptake_status) ~ "Data Suppressed",
               TRUE ~ uptake_status)) %>%
      # If else statements tests to create pop up message based on uptake status
      mutate(pop_up = if_else(
        uptake_status  == "Lower",
        paste("<strong>Benefits with lower than expected uptake: </strong>", 
              uptake_measure),
        if_else(
          uptake_status == "Higher",
          paste("<strong>Benefits with higher than expected uptake: </strong>",
                uptake_measure),
          ""))) 
    
    map_data_merged <-  sf_data %>%
      left_join(map_data, by = "Datazone") %>%
      st_transform(4326) %>%
      # set status message for pop-ups
      mutate(
        status_msg = case_when(
          uptake_status == "Lower - multiple" ~ "Lower than expected uptake in multiple uptake measures", 
          uptake_status == "Lower" ~ "Lower than expected uptake for one uptake measure",
          uptake_status == "Higher" ~ "Higher than expected uptake for one uptake measure",
          uptake_status == "Higher - multiple" ~ "Higher than expected uptake in multiple uptake measures",
          uptake_status == "Both" ~ "Higher/Lower expected uptake",
          uptake_status == "Normal" ~ "No difference to what is expected",
          uptake_status == "Data Suppressed" ~ "Data not available"
        )
      )
    
  }) %>%
    bindCache(selected_year(), selected_uptake_measure_single())
  
  
  # Create Maps ------------------------------------------------------------------
  
  # renderLeaflet DZ Summary Map 
  output$map_dz_summ <- renderLeaflet({
    
    create_map(Data = map_data_dz_summ(),
               default_area = isolate(selected_small_area()))
    
  })
  
  # renderLeaflet Change over time Map
  output$map_change_over_time <- renderLeaflet({
    
    create_map(Data = map_data_change_over_time(),
               default_area = isolate(selected_small_area()))
  })
  
  # Observe map click ---------------------------------------------------------- 
  
  # observe clicks on DZ summary map
  observeEvent(input$map_dz_summ_shape_click, {
    
    req(!is.null(input$map_dz_summ_shape_click$id))
    
    event <- input$map_dz_summ_shape_click
    
    clicked_area <- event$id
    if(is.null(event)){
      return()}
    
    selected_small_area(clicked_area)
    
    # Geometry for DZ summ 
    selected_area_shape_DZ_summ <- map_data_dz_summ() %>%
      filter(Datazone == selected_small_area()) %>%
      pull(geometry)
    # extract geometry for popups
    centroid_selected_area_DZ_summ <- st_centroid(selected_area_shape_DZ_summ)
    coords_selected_area_DZ_summ <- st_coordinates(centroid_selected_area_DZ_summ)
    # Extract info on selected area to use in popup
    pop_up_data_DZ_summ <- map_data_dz_summ() %>%
      filter(Datazone == selected_small_area())
    
    # Highlight selected polygon and show popup in DZ summ map
    leafletProxy("map_dz_summ") %>%
      clearPopups() %>%
      addPopups(lng = coords_selected_area_DZ_summ[1],
                lat = coords_selected_area_DZ_summ[2],
                popup = paste0(
                  "<strong>DZ: </strong>", 
                  pop_up_data_DZ_summ$Datazone, 
                  "<br/><strong> Name: </strong>",
                  pop_up_data_DZ_summ$Name,
                  "<br/><strong> Uptake Status: </strong>",
                  pop_up_data_DZ_summ$uptake_status,
                  "<br/>",
                  pop_up_data_DZ_summ$status_msg,
                  "<br/>",
                  pop_up_data_DZ_summ$pop_up)) %>%
      # clear previous highlight
      clearGroup("highlighted_polygon") %>%
      addPolylines(stroke = TRUE,
                   data = selected_area_shape_DZ_summ,
                   group = "highlighted_polygon",
                   color = "orange",
                   weight = 3,
                   opacity = 0.7) 

    # Highlight selected polygon and show pop up in change over time map
    leafletProxy("map_change_over_time") %>%
      clearPopups() %>%
      clearGroup("highlighted_polygon") %>%
      addPolylines(stroke = TRUE,
                   data = selected_area_shape_DZ_summ,
                   group = "highlighted_polygon",
                   color = "orange",
                   weight = 3,
                   opacity = 0.7)
    
  })
  
  # observe clicks on change over time map
  observeEvent(input$map_change_over_time_shape_click, {
    
    req(!is.null(input$map_change_over_time_shape_click$id))
    
    event <- input$map_change_over_time_shape_click
    
    clicked_area <- event$id
    if(is.null(event)){
      return()}
    
    selected_small_area(clicked_area)
    
    # Geometry for change over time
    selected_area_shape_COT <- map_data_change_over_time() %>%
      filter(Datazone == selected_small_area()) %>%
      pull(geometry)
    # extract geometry for popups
    centroid_selected_area_COT <- st_centroid(selected_area_shape_COT)
    coords_selected_area_COT <- st_coordinates(centroid_selected_area_COT)
    # Extract info on selected area to use in popup
    pop_up_data_COT <- map_data_change_over_time() %>%
      filter(Datazone == selected_small_area())
    
    # Highlight selected polygon and show pop up in change over time map
    leafletProxy("map_change_over_time") %>%
      clearPopups() %>%
      addPopups(lng = coords_selected_area_COT[1],
                lat = coords_selected_area_COT[2],
                popup = paste0(
                  "<strong>DZ: </strong>", 
                  pop_up_data_COT$Datazone, 
                  "<br/><strong> Name: </strong>",
                  pop_up_data_COT$Name,
                  "<br/><strong> Uptake Status: </strong>",
                  pop_up_data_COT$uptake_status,
                  "<br/>",
                  pop_up_data_COT$status_msg,
                  "<br/>",
                  pop_up_data_COT$pop_up)) %>%
      # clear previous highlight
      clearGroup("highlighted_polygon") %>%
      addPolylines(stroke = TRUE,
                   data = selected_area_shape_COT,
                   group = "highlighted_polygon",
                   color = "orange",
                   weight = 3,
                   opacity = 0.7)
    
    # Highlight selected polygon and show popup in DZ summ map
    leafletProxy("map_dz_summ") %>%
      clearPopups() %>%
      # clear previous highlight
      clearGroup("highlighted_polygon") %>%
      addPolylines(stroke = TRUE,
                   data = selected_area_shape_COT,
                   group = "highlighted_polygon",
                   color = "orange",
                   weight = 3,
                   opacity = 0.7) 

  })
  
# Data table -------------------------------------------------------------------

# server = FALSE to make data download client side and allow all selected data
# to be downloaded
  output$summary_table <- DT::renderDT({
        summary_table
   }, server = FALSE) 
  

# Header for over time line plot -----------------------------------------------

  # Create header - 'Change over time' tab
  output$header_time <- renderText({
    # Filter shape data to get name of selected DZ
    selected_area <- sf_data %>%
      filter(Datazone == selected_small_area()) %>%
      pull(Name)
    text <- paste(selected_uptake_measure_single(), 
                  "in", 
                  selected_area, 
                  "over time")
    })
  
# Over time plot ---------------------------------------------------------------
  
  # Over time line plot
  output$line_graph <- renderPlotly({
    
    validate(need(input$uptake_measure_selection_single != "",
                  "Uptake measure selection needed"))

    # Set Uptake/Demand Meaure colours
    colour_measure <- c("uptake" = "lightblue", "demand" = "darkblue")
    # Set Uptake Status colours
    colour_status <- c( "Higher Uptake" = "#38df20",  
                        "Lower Uptake" = "#e02119", 
                        "As Expected" ="black")
    
    plot <- Data %>% 
      filter(Datazone == selected_small_area(), 
             uptake_measure == selected_uptake_measure_single()) %>% 
      pivot_longer(cols = starts_with(c("uptake", "demand")),
                   names_to = c("uptake_demand", ".value"),
                   names_pattern = "(.+)_(.+)") %>% 
      mutate(rate = round(rate * 100, 2), 
             # To highlight only where uptake status is Higher/Lower
             # And to improve presentation of legend entries
             outliers = case_when(uptake_demand == "demand" ~ "As Expected",
                                  outliers == "Normal" ~ "As Expected",
                                  outliers == "Higher" ~ "Higher Uptake",
                                  outliers == "Lower" ~ "Lower Uptake",
                                  TRUE ~ NA,
                                  TRUE ~ outliers)) %>% 
      ggplot(aes(x = display_year, 
                 y = rate, 
                 group = measure, 
                 text = paste("</br> Year:", display_year,
                              "</br> Measure:", measure,
                              "</br> Rate:", rate,
                              "</br> Uptake Status:", outliers))) +
      geom_line(aes(colour = uptake_demand), size = 1) +
      geom_point(aes(fill = outliers), size = 3, stroke = 0.5) +
      scale_fill_manual(values = colour_status) +
      scale_colour_manual(values = colour_measure) +
      scale_x_continuous(breaks = seq(min(Data$display_year), 
                                      max(Data$display_year), 
                                      by = 1), 
                         labels = scales::number_format(accuracy = 1)) +
      theme_minimal() +
      labs(x = "Year", 
           y = "Rate", 
           colour = "Uptake/Demand Measure", 
           fill = "Uptake Status") + 
      # removes '..1)' from legend output
      guides(color = "none")
    
    fig <- ggplotly(plot, tooltip = "text") %>% 
      add_trace(y = ~uptake_demand, 
                name = "Uptake Rate", 
                mode = 'lines',
                line = list(color = "lightblue", width = 4)) %>% 
      add_trace(y = ~uptake_demand, 
                name = "Demand Rate", 
                mode = 'lines',
                line = list(color = "darkblue", width = 4)) %>%
      config(displayModeBar = FALSE) %>% 
      layout(legend = list(x = 0, 
                           y = 1.3,
                           xanchor = "left",
                           yanchor = "top",
                           title = NA,
                           orientation = "h"))
    })
  
# Methodology Page ------------------------------------------------------------
  
  # Reactice methodology data
  methods_table_data <- reactive({
    
    read_xlsx("Helper Scripts/Methodology.xlsx", 
              sheet = input$methodology_selection)
    
  })
  
  # format title for each methodology page
  output$page_title <- renderUI({

    title_text <- names(methods_table_data())[2]

    tags$h2(title_text, class = "page-title")
    
  })
  
  # Render methodology table
  output$methodology_text <- renderDT({
    
    data <- methods_table_data()
    
    # convert 2nd column into HTML <p> blocks to format paragraphs
    data[[2]] <- paste0("<p>", gsub("\n", "</p><p>", data[[2]]), "</p>")
    
    # make colnames blank - not required when table renders
    colnames(data) <- rep("", ncol(data))
    
    methods_table <- datatable(data = data,
                               escape = FALSE,
                               rownames = FALSE,
                               # this option shows just the table with no additional features
                               options = list(dom = 't')) %>%
      # columns = TRUE specifies that the formatting be applied to all columns
      formatStyle(columns = TRUE)
  }) 
  
# Toggle sidebar --------------------------------------------------------------
  
  observeEvent(input$tabs,{
    sidebar_toggle(
      id = "sidebar",
      open = input$tabs %in% c("dz_summary", "change_over_time", "methodology")
    )
  })
  
# Navigate to tabs from Overview page -----------------------------------------
  goto_tabs <- list(
    goto_dz_summary = "dz_summary",
    goto_data_download = "data_table",
    goto_cot = "change_over_time",
    goto_methods = "methodology"
  )
  
  lapply(names(goto_tabs), function(btn){
    observeEvent(input[[btn]], {
      updateNavbarPage(session, "tabs", selected = goto_tabs[[btn]])
    }, ignoreInit = TRUE)
  })
  
} # Closing server bracket