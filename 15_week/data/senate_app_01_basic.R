# APPROACH 1: Basic Shiny App with Sidebar Layout
# US Senate Ideology Visualization (American Politics dataset #1)
#
# Data: senate_ideology.rds
#   Built in create_data.R from 04_week/data/Sall_members.csv
#   (Voteview DW-NOMINATE scores for Senators, 110th congress onward.)
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(dplyr)
library(ggplot2)

# Load data -------------------------------------------------------------------
# Work whether the app is launched from the data/ folder or the project root.
data_file <- if (file.exists("senate_ideology.rds")) {
  "senate_ideology.rds"
} else {
  "15_week/data/senate_ideology.rds"
}
senate_data <- readRDS(data_file)

# UI --------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("US Senate Ideology Visualization"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "congress_select",
        "Select Congress:",
        choices  = sort(unique(senate_data$congress)),
        selected = max(senate_data$congress)
      ),
      checkboxGroupInput(
        "party_filter",
        "Include Parties:",
        choices  = c("Democrat" = "D", "Republican" = "R", "Independent" = "I"),
        selected = c("D", "R", "I")
      ),
      sliderInput(
        "n_senators",
        "Number of Senators to Display:",
        min   = 5,
        max   = 100,
        value = 100
      ),
      hr(),
      p(
        "This app visualizes US Senate members' ideological positions using",
        "DW-NOMINATE scores. The horizontal axis is the liberal-conservative",
        "dimension; the vertical axis is the second (racial/regional) dimension."
      )
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Scatterplot",  plotOutput("ideology_scatter", height = "500px")),
        tabPanel("Distribution", plotOutput("ideology_dist",    height = "500px")),
        tabPanel("Data Table",   tableOutput("senate_table"))
      )
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered_data <- reactive({
    senate_data %>%
      filter(
        congress == input$congress_select,
        party    %in% input$party_filter
      ) %>%
      arrange(dwnom1) %>%
      slice_head(n = input$n_senators)
  })

  output$ideology_scatter <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No senators match the current filters."))

    ggplot(df, aes(x = dwnom1, y = dwnom2, color = party, shape = party)) +
      geom_point(size = 4, alpha = 0.75) +
      geom_rug(sides = "b", alpha = 0.3) +
      scale_color_manual(
        name   = "Party",
        values = c("D" = "blue", "R" = "red", "I" = "grey30"),
        labels = c("D" = "Democrat", "R" = "Republican", "I" = "Independent")
      ) +
      scale_shape_manual(
        name   = "Party",
        values = c("D" = 16, "R" = 17, "I" = 15),
        labels = c("D" = "Democrat", "R" = "Republican", "I" = "Independent")
      ) +
      labs(
        title   = paste("Senate Ideology -", input$congress_select, "Congress"),
        x       = "Liberal-Conservative (DW-NOMINATE 1st Dimension)",
        y       = "Racial/Regional (DW-NOMINATE 2nd Dimension)",
        caption = "Data: Voteview (Sall_members.csv)"
      ) +
      xlim(-1, 1) +
      ylim(-1, 1) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )
  })

  output$ideology_dist <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No senators match the current filters."))

    ggplot(df, aes(x = dwnom1, fill = party)) +
      geom_histogram(alpha = 0.65, bins = 20, position = "identity") +
      scale_fill_manual(
        name   = "Party",
        values = c("D" = "blue", "R" = "red", "I" = "grey30"),
        labels = c("D" = "Democrat", "R" = "Republican", "I" = "Independent")
      ) +
      labs(
        title   = paste("Liberal-Conservative distribution -",
                        input$congress_select, "Congress"),
        x       = "DW-NOMINATE 1st Dimension",
        y       = "Frequency",
        caption = "Data: Voteview"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  output$senate_table <- renderTable({
    filtered_data() %>%
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
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
