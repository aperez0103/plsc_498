# APPROACH 1: Basic Shiny App with Sidebar Layout
# 2020 Election Returns & COVID Deaths by State
#
# Data: election_2020.rds
#   Built in create_data.R from 09_week/data/state_df.rds
#   (State-level 2020 presidential election returns plus COVID deaths.)
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

# Install any missing packages automatically --------------------------------
required_packages <- c("shiny", "dplyr", "ggplot2")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(shiny)
library(dplyr)
library(ggplot2)

# Load data -------------------------------------------------------------------
data_file <- if (file.exists("election_2020.rds")) {
  "election_2020.rds"
} else {
  "15_week/data/election_2020.rds"
}
election <- readRDS(data_file)

# UI --------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("2020 Election Returns & COVID Deaths by State"),

  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "winner_filter",
        "Show states won by:",
        choices  = c("Biden", "Trump"),
        selected = c("Biden", "Trump")
      ),
      sliderInput(
        "margin_range",
        "Biden vote margin:",
        min   = round(min(election$biden_margin), 2),
        max   = round(max(election$biden_margin), 2),
        value = c(round(min(election$biden_margin), 2),
                  round(max(election$biden_margin), 2)),
        step  = 0.01
      ),
      sliderInput(
        "min_covid",
        "Minimum COVID deaths:",
        min   = 0,
        max   = max(election$covid_deaths, na.rm = TRUE),
        value = 0,
        step  = 500
      ),
      hr(),
      p(
        "This app visualizes state-level results from the 2020 US presidential",
        "election alongside cumulative COVID-19 deaths through Election Day",
        "(November 7, 2020). Use the controls above to filter states by",
        "winner, margin, and COVID severity."
      )
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Vote Margins",
                 plotOutput("margin_plot", height = "550px")),
        tabPanel("COVID vs. Vote Share",
                 plotOutput("covid_scatter", height = "500px")),
        tabPanel("COVID Deaths",
                 plotOutput("covid_bar", height = "550px")),
        tabPanel("Data Table",
                 tableOutput("election_table"))
      )
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered_data <- reactive({
    election %>%
      filter(
        winner       %in% input$winner_filter,
        biden_margin >= input$margin_range[1],
        biden_margin <= input$margin_range[2],
        covid_deaths >= input$min_covid
      )
  })

  # Tab 1: Horizontal bar chart of Biden margin by state
  output$margin_plot <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No states match the current filters."))

    ggplot(df, aes(x = biden_margin,
                   y = reorder(state, biden_margin),
                   fill = winner)) +
      geom_col(alpha = 0.85) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
      scale_fill_manual(
        values = c("Biden" = "#1f77b4", "Trump" = "#d62728"),
        name   = "Winner"
      ) +
      labs(
        title   = "2020 Presidential Election: Biden Margin by State",
        x       = "Biden - Trump vote share",
        y       = NULL,
        caption = "Source: 09_week/data/state_df.rds"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )
  })

  # Tab 2: Scatter of COVID deaths vs Biden vote share
  output$covid_scatter <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No states match the current filters."))

    ggplot(df, aes(x = biden_share, y = covid_deaths, color = winner)) +
      geom_point(size = 4, alpha = 0.8) +
      geom_smooth(method = "lm", se = TRUE, color = "grey40",
                  linewidth = 0.6, alpha = 0.2) +
      geom_text(aes(label = state_po), size = 2.8, vjust = -0.8,
                show.legend = FALSE) +
      scale_color_manual(
        values = c("Biden" = "#1f77b4", "Trump" = "#d62728"),
        name   = "Winner"
      ) +
      labs(
        title   = "COVID Deaths vs. Biden Vote Share",
        x       = "Biden share of the two-party vote",
        y       = "Cumulative COVID deaths (through 2020-11-07)",
        caption = "Source: 09_week/data/state_df.rds"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )
  })

  # Tab 3: COVID deaths bar chart ranked
  output$covid_bar <- renderPlot({
    df <- filtered_data()
    validate(need(nrow(df) > 0, "No states match the current filters."))

    ggplot(df, aes(x = covid_deaths,
                   y = reorder(state, covid_deaths),
                   fill = winner)) +
      geom_col(alpha = 0.85) +
      scale_fill_manual(
        values = c("Biden" = "#1f77b4", "Trump" = "#d62728"),
        name   = "Winner"
      ) +
      scale_x_continuous(labels = scales::comma) +
      labs(
        title   = "Cumulative COVID Deaths by State (through Election Day)",
        x       = "COVID deaths",
        y       = NULL,
        caption = "Source: 09_week/data/state_df.rds"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        plot.title      = element_text(face = "bold"),
        legend.position = "bottom"
      )
  })

  # Tab 4: Data table
  output$election_table <- renderTable({
    filtered_data() %>%
      mutate(
        biden_share  = round(biden_share, 3),
        trump_share  = round(trump_share, 3),
        biden_margin = round(biden_margin, 3)
      ) %>%
      select(state, state_po, total_votes, biden_votes, trump_votes,
             biden_share, trump_share, biden_margin, winner,
             covid_deaths, pneumonia_deaths) %>%
      rename(
        "State"             = state,
        "PO"                = state_po,
        "Total Votes"       = total_votes,
        "Biden Votes"       = biden_votes,
        "Trump Votes"       = trump_votes,
        "Biden %"           = biden_share,
        "Trump %"           = trump_share,
        "Biden Margin"      = biden_margin,
        "Winner"            = winner,
        "COVID Deaths"      = covid_deaths,
        "Pneumonia Deaths"  = pneumonia_deaths
      )
  })
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
