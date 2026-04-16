# APPROACH 2: Shiny App with navbarPage for Multi-Tab Navigation
# US Senate Ideology Explorer  (American Politics dataset)
#
# Data: senate_ideology.rds
#   Built in create_data.R from 04_week/data/Sall_members.csv
#   (Voteview DW-NOMINATE scores for Senators, 110th Congress onward.)
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

# Install any missing packages automatically --------------------------------
required_packages <- c("shiny", "dplyr", "ggplot2", "bslib")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(shiny)
library(dplyr)
library(ggplot2)

# Load data -------------------------------------------------------------------
data_file <- if (file.exists("senate_ideology.rds")) {
  "senate_ideology.rds"
} else {
  "15_week/data/senate_ideology.rds"
}
senate_data <- readRDS(data_file)

party_labels <- c("D" = "Democrat", "R" = "Republican", "I" = "Independent")
party_colors <- c("D" = "blue", "R" = "red", "I" = "grey30")

# UI --------------------------------------------------------------------------
ui <- navbarPage(
  title = "US Senate Ideology Explorer",
  theme = bslib::bs_theme(version = 4, primary = "#003366"),

  # ---- Tab 1: Visualization ----
  tabPanel(
    "Visualization",
    br(),
    fluidRow(
      column(
        3,
        h4("Controls"),
        selectInput(
          "congress_select",
          "Select Congress:",
          choices  = sort(unique(senate_data$congress)),
          selected = max(senate_data$congress)
        ),
        checkboxGroupInput(
          "party_filter",
          "Include parties:",
          choices  = c("Democrat" = "D", "Republican" = "R", "Independent" = "I"),
          selected = c("D", "R", "I")
        ),
        sliderInput(
          "ideology_range",
          "DW-NOMINATE 1st dimension range:",
          min   = -1,
          max   = 1,
          value = c(-1, 1),
          step  = 0.05
        ),
        actionButton("reset_filters", "Reset Filters", class = "btn-primary")
      ),
      column(
        9,
        plotOutput("ideology_scatter", height = "550px"),
        p(em("Each point is a Senator. X-axis = liberal-conservative dimension; ",
             "Y-axis = second (racial/regional) dimension."),
          style = "font-size: 11px; color: #666;")
      )
    )
  ),

  # ---- Tab 2: Statistics ----
  tabPanel(
    "Statistics",
    br(),
    fluidRow(
      column(4, wellPanel(
        h4("Democrats"),
        textOutput("n_dems"),
        textOutput("mean_ideology_d")
      )),
      column(4, wellPanel(
        h4("Republicans"),
        textOutput("n_reps"),
        textOutput("mean_ideology_r")
      )),
      column(4, wellPanel(
        h4("Independents"),
        textOutput("n_ind"),
        textOutput("mean_ideology_i")
      ))
    ),
    br(),
    h4("Distribution of DW-NOMINATE scores by party"),
    plotOutput("ideology_density", height = "400px"),
    br(),
    h4("State-level breakdown"),
    dataTableOutput("state_table")
  ),

  # ---- Tab 3: Data Table ----
  tabPanel(
    "Data Table",
    br(),
    fluidRow(column(12,
      p("Download the filtered dataset:"),
      downloadButton("download_data", "Download as CSV")
    )),
    br(),
    dataTableOutput("full_table")
  ),

  # ---- Tab 4: About ----
  tabPanel(
    "About",
    br(),
    h3("US Senate Ideology Explorer"),
    p("This application visualizes US Senate members' ideological positions",
      "using DW-NOMINATE scores from the Voteview project."),
    h4("Data source"),
    p("DW-NOMINATE scores from Voteview (Sall_members.csv), filtered to the",
      "110th Congress onward. The first dimension captures the",
      "liberal-conservative spectrum; the second dimension historically",
      "captures racial/regional divisions."),
    h4("How to use"),
    tags$ol(
      tags$li("Select a Congress to view its membership."),
      tags$li("Filter by party to compare ideological distributions."),
      tags$li("Use the ideology range slider to zoom into moderates or extremes."),
      tags$li("Check the Statistics tab for party-level summaries and state breakdowns."),
      tags$li("Download the filtered data from the Data Table tab.")
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered <- reactive({
    senate_data %>%
      filter(
        congress == input$congress_select,
        party    %in% input$party_filter,
        dwnom1   >= input$ideology_range[1],
        dwnom1   <= input$ideology_range[2]
      )
  })

  observeEvent(input$reset_filters, {
    updateSelectInput(session, "congress_select",
                      selected = max(senate_data$congress))
    updateCheckboxGroupInput(session, "party_filter",
                             selected = c("D", "R", "I"))
    updateSliderInput(session, "ideology_range", value = c(-1, 1))
  })

  # ---- Visualization tab ----
  output$ideology_scatter <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No senators match the current filters."))

    ggplot(df, aes(x = dwnom1, y = dwnom2, color = party, shape = party)) +
      geom_point(size = 4, alpha = 0.75) +
      geom_rug(sides = "b", alpha = 0.3) +
      scale_color_manual(
        name   = "Party",
        values = party_colors,
        labels = party_labels
      ) +
      scale_shape_manual(
        name   = "Party",
        values = c("D" = 16, "R" = 17, "I" = 15),
        labels = party_labels
      ) +
      labs(
        title   = paste("Senate Ideology -", input$congress_select,
                        "Congress"),
        x       = "Liberal-Conservative (DW-NOMINATE 1st Dimension)",
        y       = "Racial/Regional (DW-NOMINATE 2nd Dimension)",
        caption = "Data: Voteview (Sall_members.csv)"
      ) +
      xlim(-1, 1) + ylim(-1, 1) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )
  })

  # ---- Statistics tab ----
  output$n_dems <- renderText({
    sprintf("Senators: %d", sum(filtered()$party == "D"))
  })
  output$n_reps <- renderText({
    sprintf("Senators: %d", sum(filtered()$party == "R"))
  })
  output$n_ind <- renderText({
    sprintf("Senators: %d", sum(filtered()$party == "I"))
  })
  output$mean_ideology_d <- renderText({
    x <- filtered() %>% filter(party == "D") %>% pull(dwnom1)
    if (length(x) == 0) "Mean ideology: N/A"
    else sprintf("Mean ideology: %.3f", mean(x, na.rm = TRUE))
  })
  output$mean_ideology_r <- renderText({
    x <- filtered() %>% filter(party == "R") %>% pull(dwnom1)
    if (length(x) == 0) "Mean ideology: N/A"
    else sprintf("Mean ideology: %.3f", mean(x, na.rm = TRUE))
  })
  output$mean_ideology_i <- renderText({
    x <- filtered() %>% filter(party == "I") %>% pull(dwnom1)
    if (length(x) == 0) "Mean ideology: N/A"
    else sprintf("Mean ideology: %.3f", mean(x, na.rm = TRUE))
  })

  output$ideology_density <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No senators match the current filters."))

    ggplot(df, aes(x = dwnom1, fill = party)) +
      geom_density(alpha = 0.5) +
      scale_fill_manual(
        name   = "Party",
        values = party_colors,
        labels = party_labels
      ) +
      labs(
        x       = "DW-NOMINATE 1st Dimension (Liberal-Conservative)",
        y       = "Density",
        caption = "Data: Voteview"
      ) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom")
  })

  output$state_table <- renderDataTable({
    filtered() %>%
      group_by(state) %>%
      summarize(
        Senators       = n(),
        `Mean Ideology` = round(mean(dwnom1, na.rm = TRUE), 3),
        `Min Ideology`  = round(min(dwnom1, na.rm = TRUE), 3),
        `Max Ideology`  = round(max(dwnom1, na.rm = TRUE), 3),
        Parties         = paste(sort(unique(party)), collapse = ", "),
        .groups = "drop"
      ) %>%
      rename(State = state)
  })

  # ---- Data table tab ----
  output$full_table <- renderDataTable({
    filtered() %>%
      mutate(
        party  = recode(party, "D" = "Democrat", "R" = "Republican",
                        "I" = "Independent"),
        dwnom1 = round(dwnom1, 3),
        dwnom2 = round(dwnom2, 3)
      ) %>%
      select(name, state, party, congress, dwnom1, dwnom2) %>%
      rename(
        "Name"               = name,
        "State"              = state,
        "Party"              = party,
        "Congress"           = congress,
        "Ideology (Lib-Con)" = dwnom1,
        "Ideology (2nd dim)" = dwnom2
      )
  })

  output$download_data <- downloadHandler(
    filename = function() paste0("senate_ideology_", input$congress_select,
                                 ".csv"),
    content  = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
