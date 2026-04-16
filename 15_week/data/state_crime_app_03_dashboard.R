# APPROACH 3: Shiny Dashboard with shinydashboard
# US State Crime and Demographics Explorer  (American Politics dataset #3)
#
# Data: state_crime.rds
#   Built in create_data.R from
#     13_week/data/us_arrests.rds  (1973 arrests per 100k)
#   and
#     13_week/data/state_data.rds  (state demographics from state.x77).
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

# Install any missing packages automatically --------------------------------
required_packages <- c("shiny", "shinydashboard", "dplyr", "ggplot2", "plotly")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)

# Load data -------------------------------------------------------------------
data_file <- if (file.exists("state_crime.rds")) {
  "state_crime.rds"
} else {
  "15_week/data/state_crime.rds"
}
state_crime <- readRDS(data_file)

region_choices <- sort(unique(state_crime$region))
crime_metrics  <- c("Murder" = "murder",
                    "Assault" = "assault",
                    "Rape"   = "rape")

# UI --------------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "US State Crime Explorer", titleWidth = 300),

  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Overview",  tabName = "overview", icon = icon("chart-line")),
      menuItem("Crime",     tabName = "crime",    icon = icon("exclamation-triangle")),
      menuItem("Contexts",  tabName = "context",  icon = icon("balance-scale")),
      menuItem("Data",      tabName = "data",     icon = icon("table"))
    ),
    hr(),
    h4("Filters", style = "padding: 10px;"),
    checkboxGroupInput(
      "region_filter", "Region:",
      choices  = region_choices,
      selected = region_choices
    ),
    selectInput(
      "crime_metric", "Crime metric:",
      choices  = crime_metrics,
      selected = "murder"
    ),
    sliderInput(
      "urban_range", "Urban population (%):",
      min   = min(state_crime$urban_pop, na.rm = TRUE),
      max   = max(state_crime$urban_pop, na.rm = TRUE),
      value = c(min(state_crime$urban_pop, na.rm = TRUE),
                max(state_crime$urban_pop, na.rm = TRUE)),
      step  = 1
    )
  ),

  dashboardBody(
    tabItems(
      # ---- Overview ----
      tabItem(
        tabName = "overview",
        h2("State overview"),
        fluidRow(
          valueBoxOutput("n_states",      width = 3),
          valueBoxOutput("mean_crime",    width = 3),
          valueBoxOutput("mean_income",   width = 3),
          valueBoxOutput("mean_life_exp", width = 3)
        ),
        fluidRow(
          box(title = paste0("Top 10 states by selected crime metric"),
              plotOutput("top_states_plot", height = "420px"), width = 12)
        ),
        fluidRow(
          box(title = "Crime by region",
              plotOutput("region_box", height = "350px"), width = 6),
          box(title = "Most violent states (all crimes)",
              tableOutput("most_violent"), width = 6)
        )
      ),

      # ---- Crime analysis ----
      tabItem(
        tabName = "crime",
        h2("Crime analysis"),
        fluidRow(
          box(title = "Crime vs. urbanization",
              plotlyOutput("crime_urban", height = "400px"), width = 6),
          box(title = "Crime vs. income",
              plotlyOutput("crime_income", height = "400px"), width = 6)
        ),
        fluidRow(
          box(title = "Correlation matrix of crime metrics",
              plotOutput("crime_corr", height = "350px"), width = 12)
        )
      ),

      # ---- Contextual variables ----
      tabItem(
        tabName = "context",
        h2("Socio-economic context"),
        fluidRow(
          box(title = "Life expectancy by region",
              plotOutput("life_exp_region", height = "400px"), width = 6),
          box(title = "Education (% HS graduates) vs. illiteracy",
              plotlyOutput("education_plot", height = "400px"), width = 6)
        )
      ),

      # ---- Raw data ----
      tabItem(
        tabName = "data",
        h2("Raw data"),
        fluidRow(column(12,
          downloadButton("download_data", "Download filtered CSV"),
          br(), br()
        )),
        dataTableOutput("data_table")
      )
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered <- reactive({
    state_crime %>%
      filter(
        region     %in% input$region_filter,
        urban_pop  >= input$urban_range[1],
        urban_pop  <= input$urban_range[2]
      )
  })

  # ---- Value boxes ----
  output$n_states <- renderValueBox({
    valueBox(nrow(filtered()), "States shown",
             icon = icon("flag-usa"), color = "blue")
  })
  output$mean_crime <- renderValueBox({
    v <- mean(filtered()[[input$crime_metric]], na.rm = TRUE)
    valueBox(round(v, 1),
             paste("Mean", names(crime_metrics)[crime_metrics == input$crime_metric]),
             icon = icon("crosshairs"), color = "red")
  })
  output$mean_income <- renderValueBox({
    v <- mean(filtered()$income, na.rm = TRUE)
    valueBox(format(round(v), big.mark = ","), "Mean income",
             icon = icon("dollar-sign"), color = "green")
  })
  output$mean_life_exp <- renderValueBox({
    v <- mean(filtered()$life_exp, na.rm = TRUE)
    valueBox(sprintf("%.1f", v), "Mean life expectancy",
             icon = icon("heartbeat"), color = "maroon")
  })

  # ---- Top states bar ----
  output$top_states_plot <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No states match the current filters."))
    metric <- input$crime_metric

    df %>%
      arrange(desc(.data[[metric]])) %>%
      slice_head(n = 10) %>%
      ggplot(aes(x = reorder(state, .data[[metric]]),
                 y = .data[[metric]], fill = region)) +
      geom_col(alpha = 0.85) +
      coord_flip() +
      labs(
        x = NULL,
        y = paste(names(crime_metrics)[crime_metrics == metric],
                  "(arrests per 100k)"),
        fill = "Region"
      ) +
      theme_minimal(base_size = 13)
  })

  output$region_box <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No states match the current filters."))
    ggplot(df, aes(x = region, y = .data[[input$crime_metric]], fill = region)) +
      geom_boxplot(alpha = 0.75, show.legend = FALSE) +
      labs(x = NULL,
           y = names(crime_metrics)[crime_metrics == input$crime_metric]) +
      theme_minimal(base_size = 13)
  })

  output$most_violent <- renderTable({
    filtered() %>%
      mutate(total = murder + assault + rape) %>%
      arrange(desc(total)) %>%
      slice_head(n = 10) %>%
      transmute(
        State   = state,
        Region  = region,
        Murder  = murder,
        Assault = assault,
        Rape    = rape,
        Total   = round(total, 1)
      )
  })

  # ---- Crime tab plots ----
  output$crime_urban <- renderPlotly({
    df <- filtered()
    validate(need(nrow(df) > 0, "No data."))
    plot_ly(df, x = ~urban_pop, y = ~.data[[input$crime_metric]],
            type = "scatter", mode = "markers",
            text = ~state, color = ~region,
            marker = list(size = 10, opacity = 0.8)) %>%
      layout(xaxis = list(title = "Urban population (%)"),
             yaxis = list(title = names(crime_metrics)[crime_metrics == input$crime_metric]))
  })

  output$crime_income <- renderPlotly({
    df <- filtered()
    validate(need(nrow(df) > 0, "No data."))
    plot_ly(df, x = ~income, y = ~.data[[input$crime_metric]],
            type = "scatter", mode = "markers",
            text = ~state, color = ~region,
            marker = list(size = 10, opacity = 0.8)) %>%
      layout(xaxis = list(title = "Per-capita income"),
             yaxis = list(title = names(crime_metrics)[crime_metrics == input$crime_metric]))
  })

  output$crime_corr <- renderPlot({
    df <- filtered() %>% select(murder, assault, rape, urban_pop,
                                income, illiteracy, life_exp, hs_grad)
    validate(need(nrow(df) > 1, "Need at least 2 states for correlations."))
    cm <- cor(df, use = "pairwise.complete.obs")
    corr_df <- as.data.frame(as.table(cm))
    ggplot(corr_df, aes(x = Var1, y = Var2, fill = Freq)) +
      geom_tile(color = "white") +
      geom_text(aes(label = sprintf("%.2f", Freq)), size = 3) +
      scale_fill_gradient2(low = "#1f77b4", mid = "white", high = "#d62728",
                           midpoint = 0, limits = c(-1, 1)) +
      labs(x = NULL, y = NULL, fill = "r") +
      theme_minimal(base_size = 12) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  # ---- Context tab ----
  output$life_exp_region <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No data."))
    ggplot(df, aes(x = region, y = life_exp, fill = region)) +
      geom_boxplot(alpha = 0.75, show.legend = FALSE) +
      labs(x = NULL, y = "Life expectancy (years)") +
      theme_minimal(base_size = 13)
  })

  output$education_plot <- renderPlotly({
    df <- filtered()
    validate(need(nrow(df) > 0, "No data."))
    plot_ly(df, x = ~hs_grad, y = ~illiteracy,
            type = "scatter", mode = "markers",
            text = ~state, color = ~region,
            marker = list(size = 10, opacity = 0.8)) %>%
      layout(xaxis = list(title = "% HS graduates"),
             yaxis = list(title = "Illiteracy (%)"))
  })

  # ---- Data tab ----
  output$data_table <- renderDataTable({
    filtered() %>%
      rename(
        State      = state,
        Region     = region,
        Murder     = murder,
        Assault    = assault,
        Rape       = rape,
        "Urban %"  = urban_pop,
        Population = population,
        Income     = income,
        Illiteracy = illiteracy,
        "Life Exp" = life_exp,
        "HS Grad"  = hs_grad,
        Frost      = frost,
        Area       = area
      )
  })

  output$download_data <- downloadHandler(
    filename = function() paste0("state_crime_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
