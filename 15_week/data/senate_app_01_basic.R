# APPROACH 1: Basic Shiny App with Sidebar Layout
# US Senate Ideology Visualization
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(dplyr)
library(ggplot2)

# Load data
senate_data <- readRDS("senate_ideology.rds")

# Define UI
ui <- fluidPage(
  # App title
  titlePanel("US Senate Ideology Visualization"),

  # Sidebar layout
  sidebarLayout(
    # Sidebar panel for controls
    sidebarPanel(
      # Congress selector
      selectInput(
        "congress_select",
        "Select Congress:",
        choices = sort(unique(senate_data$congress)),
        selected = max(senate_data$congress)
      ),

      # Party filter
      checkboxGroupInput(
        "party_filter",
        "Include Parties:",
        choices = c("Democrat" = "D", "Republican" = "R"),
        selected = c("D", "R")
      ),

      # Number of senators to show
      sliderInput(
        "n_senators",
        "Number of Senators to Display:",
        min = 5,
        max = 100,
        value = 50
      ),

      hr(),

      # Help text
      p(
        "This app visualizes US Senate members' ideological positions using",
        "DW-NOMINATE scores. The horizontal axis shows the traditional",
        "liberal-conservative dimension."
      )
    ),

    # Main panel for displaying outputs
    mainPanel(
      # Two tabs
      tabsetPanel(
        tabPanel(
          "Scatterplot",
          plotOutput("ideology_scatter", height = "500px")
        ),
        tabPanel(
          "Distribution",
          plotOutput("ideology_dist", height = "500px")
        ),
        tabPanel(
          "Data Table",
          tableOutput("senate_table")
        )
      )
    )
  )
)

# Define server
server <- function(input, output) {
  # Reactive data filtering
  filtered_data <- reactive({
    senate_data %>%
      filter(
        congress == input$congress_select,
        party %in% input$party_filter
      ) %>%
      arrange(dwnom1) %>%
      slice_head(n = input$n_senators)
  })

  # Scatterplot output
  output$ideology_scatter <- renderPlot({
    df <- filtered_data()

    ggplot(df, aes(x = dwnom1, y = dwnom2, color = party, shape = party)) +
      geom_point(size = 4, alpha = 0.7) +
      geom_rug(sides = "b", alpha = 0.3) +
      scale_color_manual(
        name = "Party",
        values = c("D" = "blue", "R" = "red"),
        labels = c("D" = "Democrat", "R" = "Republican")
      ) +
      scale_shape_manual(
        name = "Party",
        values = c("D" = 16, "R" = 17),
        labels = c("D" = "Democrat", "R" = "Republican")
      ) +
      labs(
        title = paste("Senate Ideology -", input$congress_select, "Congress"),
        x = "Liberal-Conservative (DW-NOMINATE 1st Dimension)",
        y = "Racial (DW-NOMINATE 2nd Dimension)",
        caption = "Data from Rvoteview"
      ) +
      xlim(-1, 1) +
      ylim(-1, 1) +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 14, face = "bold"),
        axis.title = element_text(size = 11),
        legend.position = "bottomright"
      )
  })

  # Distribution plot
  output$ideology_dist <- renderPlot({
    df <- filtered_data()

    ggplot(df, aes(x = dwnom1, fill = party)) +
      geom_histogram(alpha = 0.6, bins = 15) +
      scale_fill_manual(
        name = "Party",
        values = c("D" = "blue", "R" = "red"),
        labels = c("D" = "Democrat", "R" = "Republican")
      ) +
      labs(
        title = paste("Distribution of Liberal-Conservative Ideology -", input$congress_select, "Congress"),
        x = "DW-NOMINATE 1st Dimension",
        y = "Frequency",
        caption = "Data from Rvoteview"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 14, face = "bold"),
        axis.title = element_text(size = 11)
      )
  })

  # Data table output
  output$senate_table <- renderTable({
    filtered_data() %>%
      select(name, state, party, congress, dwnom1, dwnom2) %>%
      mutate(
        party = ifelse(party == "D", "Democrat", "Republican"),
        dwnom1 = round(dwnom1, 3),
        dwnom2 = round(dwnom2, 3)
      ) %>%
      rename(
        "Name" = name,
        "State" = state,
        "Party" = party,
        "Congress" = congress,
        "Ideology (Lib-Con)" = dwnom1,
        "Ideology (Racial)" = dwnom2
      )
  })
}

# Run the application
shinyApp(ui = ui, server = server)
