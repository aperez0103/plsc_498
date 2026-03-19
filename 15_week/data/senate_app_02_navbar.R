# APPROACH 2: Shiny App with navbarPage for Multi-Tab Navigation
# US Senate Ideology Visualization
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(dplyr)
library(ggplot2)

# Load data
senate_data <- readRDS("senate_ideology.rds")

# Define UI with navbarPage
ui <- navbarPage(
  title = "Senate Ideology Explorer",
  theme = bslib::bs_theme(version = 4, primary = "#003366"),

  # Tab 1: Main visualization
  tabPanel(
    "Visualization",
    br(),
    fluidRow(
      column(
        3,
        h4("Controls"),
        selectInput(
          "congress_select",
          "Congress:",
          choices = sort(unique(senate_data$congress), decreasing = TRUE),
          selected = max(senate_data$congress)
        ),
        checkboxGroupInput(
          "party_filter",
          "Parties:",
          choices = c("Democrat" = "D", "Republican" = "R"),
          selected = c("D", "R")
        ),
        sliderInput(
          "min_ideology",
          "Ideology Range:",
          min = -1,
          max = 1,
          value = c(-1, 1)
        ),
        actionButton("reset_filters", "Reset Filters", class = "btn-primary")
      ),
      column(
        9,
        plotOutput("ideology_plot", height = "600px"),
        p(
          em("Hover over points to see senator names. Red = Republican, Blue = Democrat."),
          style = "font-size: 11px; color: #666;"
        )
      )
    )
  ),

  # Tab 2: Aggregate statistics
  tabPanel(
    "Statistics",
    br(),
    fluidRow(
      column(4, wellPanel(
        h4("Mean Ideology by Party"),
        textOutput("mean_ideology_dem"),
        textOutput("mean_ideology_rep")
      )),
      column(4, wellPanel(
        h4("Polarization Metric"),
        textOutput("polarization")
      )),
      column(4, wellPanel(
        h4("N Senators"),
        textOutput("n_senators_text")
      ))
    ),
    br(),
    h4("Party-State Breakdown"),
    tableOutput("state_stats")
  ),

  # Tab 3: Data explorer
  tabPanel(
    "Data Table",
    br(),
    fluidRow(
      column(12,
        p("Download the filtered dataset:"),
        downloadButton("download_data", "Download as CSV")
      )
    ),
    br(),
    dataTableOutput("full_table")
  ),

  # Tab 4: About
  tabPanel(
    "About",
    br(),
    h3("US Senate Ideology Explorer"),
    p(
      "This application visualizes ideological positions of US Senators using",
      strong("DW-NOMINATE scores"),
      "from the Rvoteview package."
    ),
    h4("What are DW-NOMINATE scores?"),
    p(
      "DW-NOMINATE (Dynamic Weighted NOMINATE) scores are a measure of ideology",
      "estimated from legislative voting records. Negative scores indicate liberal positions,",
      "while positive scores indicate conservative positions."
    ),
    h4("Data Source"),
    p(
      "Data: ",
      a("VoteView/Rvoteview", href = "https://voteview.com/"),
      br(),
      "Updated: 2024"
    ),
    h4("How to Use"),
    tags$ol(
      tags$li("Select a Congress from the Visualization tab"),
      tags$li("Filter by party affiliation"),
      tags$li("Adjust the ideology range slider to focus on certain ideological positions"),
      tags$li("View aggregate statistics in the Statistics tab"),
      tags$li("Download the data using the Data Table tab")
    )
  )
)

# Define server
server <- function(input, output, session) {
  # Reactive data filtering
  filtered_data <- reactive({
    senate_data %>%
      filter(
        congress == input$congress_select,
        party %in% input$party_filter,
        dwnom1 >= input$min_ideology[1],
        dwnom1 <= input$min_ideology[2]
      ) %>%
      arrange(dwnom1)
  })

  # Reset filters action
  observeEvent(input$reset_filters, {
    updateSelectInput(session, "congress_select", selected = max(senate_data$congress))
    updateCheckboxGroupInput(session, "party_filter", selected = c("D", "R"))
    updateSliderInput(session, "min_ideology", value = c(-1, 1))
  })

  # Main ideology plot
  output$ideology_plot <- renderPlot({
    df <- filtered_data()

    if (nrow(df) == 0) {
      plot(NA, xlim = 0:1, ylim = 0:1, bty = "n", axes = FALSE)
      text(0.5, 0.5, "No senators match current filters", cex = 1.5)
    } else {
      ggplot(df, aes(x = dwnom1, y = dwnom2, color = party, size = 3)) +
        geom_point(alpha = 0.7) +
        scale_color_manual(
          name = "Party",
          values = c("D" = "#1f77b4", "R" = "#d62728"),
          labels = c("D" = "Democrat", "R" = "Republican")
        ) +
        scale_size_identity() +
        labs(
          title = paste("Senate Ideology -", input$congress_select, "Congress"),
          x = "Liberal → Conservative",
          y = "Racial Dimension",
          caption = "Source: VoteView/Rvoteview"
        ) +
        xlim(-1, 1) +
        ylim(-1, 1) +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 16, face = "bold"),
          legend.position = "bottomright",
          panel.grid = element_line(color = "gray90")
        )
    }
  })

  # Summary statistics
  output$mean_ideology_dem <- renderText({
    df <- filtered_data() %>% filter(party == "D")
    if (nrow(df) == 0) {
      "Democrat: N/A"
    } else {
      sprintf("Democrat: %.3f", mean(df$dwnom1, na.rm = TRUE))
    }
  })

  output$mean_ideology_rep <- renderText({
    df <- filtered_data() %>% filter(party == "R")
    if (nrow(df) == 0) {
      "Republican: N/A"
    } else {
      sprintf("Republican: %.3f", mean(df$dwnom1, na.rm = TRUE))
    }
  })

  output$polarization <- renderText({
    df <- filtered_data()
    if (nrow(df) < 2) {
      "Polarization: N/A"
    } else {
      dem_mean <- mean(df[df$party == "D", "dwnom1"]$dwnom1, na.rm = TRUE)
      rep_mean <- mean(df[df$party == "R", "dwnom1"]$dwnom1, na.rm = TRUE)
      sprintf("Gap: %.3f", abs(dem_mean - rep_mean))
    }
  })

  output$n_senators_text <- renderText({
    sprintf("Total: %d", nrow(filtered_data()))
  })

  # State statistics table
  output$state_stats <- renderTable({
    filtered_data() %>%
      group_by(state, party) %>%
      summarize(
        n = n(),
        mean_ideology = round(mean(dwnom1, na.rm = TRUE), 3),
        .groups = "drop"
      ) %>%
      pivot_wider(
        names_from = party,
        values_from = c(n, mean_ideology),
        values_fill = list(n = 0, mean_ideology = NA)
      ) %>%
      rename(
        "State" = state,
        "D Count" = "n_D",
        "R Count" = "n_R",
        "D Ideology" = "mean_ideology_D",
        "R Ideology" = "mean_ideology_R"
      )
  })

  # Full data table
  output$full_table <- renderDataTable({
    filtered_data() %>%
      mutate(
        party_name = ifelse(party == "D", "Democrat", "Republican"),
        dwnom1 = round(dwnom1, 3),
        dwnom2 = round(dwnom2, 3)
      ) %>%
      select(name, state, party_name, congress, dwnom1, dwnom2) %>%
      rename(
        "Name" = name,
        "State" = state,
        "Party" = party_name,
        "Congress" = congress,
        "Lib-Con" = dwnom1,
        "Racial" = dwnom2
      )
  })

  # Download handler
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("senate_ideology_", input$congress_select, ".csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
