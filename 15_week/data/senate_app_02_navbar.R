# APPROACH 2: Shiny App with navbarPage for Multi-Tab Navigation
# 2020 US Presidential Election Explorer  (American Politics dataset #2)
#
# Data: election_2020.rds
#   Built in create_data.R from 09_week/data/state_df.rds
#   (State-level 2020 presidential election returns plus COVID deaths.)
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)

# Load data -------------------------------------------------------------------
data_file <- if (file.exists("election_2020.rds")) {
  "election_2020.rds"
} else {
  "15_week/data/election_2020.rds"
}
election <- readRDS(data_file)

# UI --------------------------------------------------------------------------
ui <- navbarPage(
  title = "2020 Election Explorer",
  theme = bslib::bs_theme(version = 4, primary = "#003366"),

  # ---- Tab 1: Visualization ----
  tabPanel(
    "Visualization",
    br(),
    fluidRow(
      column(
        3,
        h4("Controls"),
        checkboxGroupInput(
          "winner_filter",
          "Show states where winner was:",
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
          "min_votes",
          "Minimum total votes cast:",
          min   = 0,
          max   = max(election$total_votes),
          value = 0,
          step  = 1e5
        ),
        actionButton("reset_filters", "Reset Filters", class = "btn-primary")
      ),
      column(
        9,
        plotOutput("margin_plot", height = "600px"),
        p(em("States ranked by Biden's vote margin. Blue = Biden won, Red = Trump won."),
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
        h4("Biden states"),
        textOutput("n_biden"),
        textOutput("biden_total_votes")
      )),
      column(4, wellPanel(
        h4("Trump states"),
        textOutput("n_trump"),
        textOutput("trump_total_votes")
      )),
      column(4, wellPanel(
        h4("Mean COVID deaths"),
        textOutput("mean_covid_biden"),
        textOutput("mean_covid_trump")
      ))
    ),
    br(),
    h4("COVID deaths vs. Biden vote share"),
    plotOutput("covid_scatter", height = "450px")
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
    h3("2020 US Presidential Election Explorer"),
    p("This application visualizes the 2020 US presidential election by state",
      "along with COVID-19 mortality as of Election Day."),
    h4("Data source"),
    p("State-level vote totals come from the MIT Election Lab / state_df.rds",
      "dataset used in Week 9 of PLSC 498. COVID deaths are cumulative",
      "through 2020-11-07."),
    h4("How to use"),
    tags$ol(
      tags$li("Filter by which candidate won the state."),
      tags$li("Narrow the Biden-margin slider to focus on swing states."),
      tags$li("Use the Statistics tab to compare COVID mortality across red and blue states."),
      tags$li("Download the filtered data from the Data Table tab.")
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered <- reactive({
    election %>%
      filter(
        winner        %in% input$winner_filter,
        biden_margin  >= input$margin_range[1],
        biden_margin  <= input$margin_range[2],
        total_votes   >= input$min_votes
      )
  })

  observeEvent(input$reset_filters, {
    updateCheckboxGroupInput(session, "winner_filter",
                             selected = c("Biden", "Trump"))
    updateSliderInput(session, "margin_range",
                      value = c(round(min(election$biden_margin), 2),
                                round(max(election$biden_margin), 2)))
    updateSliderInput(session, "min_votes", value = 0)
  })

  output$margin_plot <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No states match the current filters."))

    ggplot(df, aes(x = biden_margin,
                   y = reorder(state, biden_margin),
                   fill = winner)) +
      geom_col(alpha = 0.85) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
      scale_fill_manual(values = c("Biden" = "#1f77b4", "Trump" = "#d62728")) +
      labs(
        title   = "2020 presidential election: Biden margin by state",
        x       = "Biden - Trump vote share",
        y       = NULL,
        fill    = "Winner",
        caption = "Source: state_df.rds (Week 9)"
      ) +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(face = "bold"))
  })

  output$n_biden <- renderText({
    sprintf("States won: %d", sum(filtered()$winner == "Biden"))
  })
  output$n_trump <- renderText({
    sprintf("States won: %d", sum(filtered()$winner == "Trump"))
  })
  output$biden_total_votes <- renderText({
    sprintf("Biden votes: %s",
            format(sum(filtered()$biden_votes, na.rm = TRUE), big.mark = ","))
  })
  output$trump_total_votes <- renderText({
    sprintf("Trump votes: %s",
            format(sum(filtered()$trump_votes, na.rm = TRUE), big.mark = ","))
  })
  output$mean_covid_biden <- renderText({
    x <- filtered() %>% filter(winner == "Biden") %>% pull(covid_deaths)
    if (length(x) == 0) "Biden: N/A"
    else sprintf("Biden states: %s", format(round(mean(x, na.rm = TRUE)), big.mark = ","))
  })
  output$mean_covid_trump <- renderText({
    x <- filtered() %>% filter(winner == "Trump") %>% pull(covid_deaths)
    if (length(x) == 0) "Trump: N/A"
    else sprintf("Trump states: %s", format(round(mean(x, na.rm = TRUE)), big.mark = ","))
  })

  output$covid_scatter <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No states match the current filters."))

    ggplot(df, aes(x = biden_share, y = covid_deaths, color = winner)) +
      geom_point(size = 3.5, alpha = 0.8) +
      geom_smooth(method = "lm", se = FALSE, color = "grey40", linewidth = 0.6) +
      scale_color_manual(values = c("Biden" = "#1f77b4", "Trump" = "#d62728")) +
      labs(
        x       = "Biden share of the two-party vote",
        y       = "Cumulative COVID deaths (2020-11-07)",
        color   = "Winner",
        caption = "Source: state_df.rds"
      ) +
      theme_minimal(base_size = 13)
  })

  output$full_table <- renderDataTable({
    filtered() %>%
      mutate(
        biden_share  = round(biden_share, 3),
        trump_share  = round(trump_share, 3),
        biden_margin = round(biden_margin, 3)
      ) %>%
      rename(
        "State"       = state,
        "PO"          = state_po,
        "Total votes" = total_votes,
        "Biden"       = biden_votes,
        "Trump"       = trump_votes,
        "Biden %"     = biden_share,
        "Trump %"     = trump_share,
        "Margin"      = biden_margin,
        "Winner"      = winner,
        "COVID deaths" = covid_deaths,
        "Pneumonia deaths" = pneumonia_deaths
      )
  })

  output$download_data <- downloadHandler(
    filename = function() "election_2020_filtered.csv",
    content  = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
