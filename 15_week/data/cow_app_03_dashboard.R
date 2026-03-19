# APPROACH 3: Shiny Dashboard for Correlates of War Data
# Interstate Conflicts Explorer
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(plotly)

# Load data
cow_data <- readRDS("cow_wars.rds")

# Prepare data
cow_data <- cow_data %>%
  mutate(
    year = as.numeric(year),
    war_type = coalesce(cow_war_wartype, "Unknown"),
    initiator = ifelse(cow_war_initiator == 1, "Initiator", "Participant")
  ) %>%
  filter(!is.na(cow_war_warnum))

# Define UI
ui <- dashboardPage(
  # Header
  dashboardHeader(
    title = "Correlates of War Explorer",
    titleWidth = 300
  ),

  # Sidebar
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem(
        "Overview",
        tabName = "overview",
        icon = icon("chart-line")
      ),
      menuItem(
        "Conflict Analysis",
        tabName = "conflicts",
        icon = icon("exclamation-triangle")
      ),
      menuItem(
        "Countries",
        tabName = "countries",
        icon = icon("globe")
      ),
      menuItem(
        "Data Explorer",
        tabName = "data",
        icon = icon("table")
      )
    ),
    hr(),
    h4("Filters", style = "padding: 10px;"),
    sliderInput(
      "year_range",
      "Year Range:",
      min = min(cow_data$year, na.rm = TRUE),
      max = max(cow_data$year, na.rm = TRUE),
      value = c(min(cow_data$year, na.rm = TRUE), max(cow_data$year, na.rm = TRUE)),
      step = 1
    ),
    checkboxGroupInput(
      "war_type_filter",
      "War Type:",
      choices = unique(cow_data$war_type),
      selected = unique(cow_data$war_type)
    ),
    selectInput(
      "country_filter",
      "Country (Optional):",
      choices = c("All", sort(unique(cow_data$state_name))),
      selected = "All"
    )
  ),

  # Body
  dashboardBody(
    tabItems(
      # Tab 1: Overview
      tabItem(
        tabName = "overview",
        h2("Conflict Overview"),
        fluidRow(
          valueBoxOutput("total_wars", width = 3),
          valueBoxOutput("total_deaths", width = 3),
          valueBoxOutput("avg_duration", width = 3),
          valueBoxOutput("countries_involved", width = 3)
        ),
        fluidRow(
          box(
            title = "Conflicts Over Time",
            plotOutput("conflicts_timeline", height = "400px"),
            width = 12
          )
        ),
        fluidRow(
          box(
            title = "War Type Distribution",
            plotOutput("wartype_dist", height = "350px"),
            width = 6
          ),
          box(
            title = "Deadliest Conflicts",
            tableOutput("deadliest_conflicts"),
            width = 6
          )
        )
      ),

      # Tab 2: Conflict Analysis
      tabItem(
        tabName = "conflicts",
        h2("Interstate Conflict Analysis"),
        fluidRow(
          box(
            title = "Fatalities by War Type",
            plotlyOutput("fatalities_wartype", height = "400px"),
            width = 6
          ),
          box(
            title = "Conflict Duration Distribution",
            plotlyOutput("duration_dist", height = "400px"),
            width = 6
          )
        ),
        fluidRow(
          box(
            title = "Initiators vs Participants",
            plotOutput("initiator_pie", height = "350px"),
            width = 6
          ),
          box(
            title = "Wars by Year",
            plotOutput("wars_year_count", height = "350px"),
            width = 6
          )
        )
      ),

      # Tab 3: Countries
      tabItem(
        tabName = "countries",
        h2("Country-Level Analysis"),
        fluidRow(
          box(
            title = "Most Involved Countries",
            tableOutput("top_countries"),
            width = 6
          ),
          box(
            title = "Conflict Participation by Country",
            plotOutput("country_involvement", height = "400px"),
            width = 6
          )
        )
      ),

      # Tab 4: Data Explorer
      tabItem(
        tabName = "data",
        h2("Raw Data Explorer"),
        fluidRow(
          column(
            12,
            downloadButton("download_data", "Download Filtered Data"),
            br(), br()
          )
        ),
        dataTableOutput("data_table")
      )
    )
  )
)

# Define server
server <- function(input, output) {
  # Reactive filtered data
  filtered_data <- reactive({
    df <- cow_data %>%
      filter(
        year >= input$year_range[1],
        year <= input$year_range[2],
        war_type %in% input$war_type_filter
      )

    if (input$country_filter != "All") {
      df <- df %>% filter(state_name == input$country_filter)
    }

    df
  })

  # ===== Value Boxes =====
  output$total_wars <- renderValueBox({
    n_wars <- length(unique(filtered_data()$cow_war_warnum))
    valueBox(
      value = n_wars,
      subtitle = "Interstate Wars",
      icon = icon("crosshairs"),
      color = "red"
    )
  })

  output$total_deaths <- renderValueBox({
    total_deaths <- sum(filtered_data()$cow_war_fatalities, na.rm = TRUE)
    valueBox(
      value = format(total_deaths, big.mark = ","),
      subtitle = "Total Fatalities",
      icon = icon("heartbeat"),
      color = "maroon"
    )
  })

  output$avg_duration <- renderValueBox({
    avg_dur <- mean(filtered_data()$cow_war_duration, na.rm = TRUE)
    valueBox(
      value = round(avg_dur, 1),
      subtitle = "Avg Duration (years)",
      icon = icon("hourglass-end"),
      color = "orange"
    )
  })

  output$countries_involved <- renderValueBox({
    n_countries <- length(unique(filtered_data()$state_name))
    valueBox(
      value = n_countries,
      subtitle = "Countries Involved",
      icon = icon("flag"),
      color = "blue"
    )
  })

  # ===== Plots =====
  output$conflicts_timeline <- renderPlot({
    df <- filtered_data() %>%
      group_by(year) %>%
      summarize(n_wars = n_distinct(cow_war_warnum), .groups = "drop")

    ggplot(df, aes(x = year, y = n_wars)) +
      geom_line(color = "#d62728", size = 1) +
      geom_point(color = "#d62728", size = 3) +
      labs(
        title = "",
        x = "Year",
        y = "Number of Wars"
      ) +
      theme_minimal() +
      theme(plot.margin = margin(10, 10, 10, 10))
  })

  output$wartype_dist <- renderPlot({
    df <- filtered_data() %>%
      group_by(war_type) %>%
      summarize(n = n_distinct(cow_war_warnum), .groups = "drop")

    ggplot(df, aes(x = reorder(war_type, -n), y = n, fill = war_type)) +
      geom_col() +
      scale_fill_brewer(palette = "Set2", guide = "none") +
      labs(x = "", y = "Count") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })

  output$deadliest_conflicts <- renderTable({
    filtered_data() %>%
      group_by(cow_war_warnum, state_name, year, war_type) %>%
      summarize(
        fatalities = sum(cow_war_fatalities, na.rm = TRUE),
        duration = first(cow_war_duration),
        .groups = "drop"
      ) %>%
      arrange(desc(fatalities)) %>%
      slice_head(n = 10) %>%
      rename(
        "War #" = cow_war_warnum,
        "Country" = state_name,
        "Year" = year,
        "Type" = war_type,
        "Deaths" = fatalities,
        "Duration" = duration
      ) %>%
      mutate(Deaths = format(Deaths, big.mark = ","))
  })

  output$fatalities_wartype <- renderPlotly({
    df <- filtered_data() %>%
      group_by(war_type) %>%
      summarize(total_deaths = sum(cow_war_fatalities, na.rm = TRUE), .groups = "drop")

    plot_ly(df, x = ~war_type, y = ~total_deaths, type = "bar",
            marker = list(color = ~total_deaths, colorscale = "Reds")) %>%
      layout(
        title = "",
        xaxis = list(title = ""),
        yaxis = list(title = "Total Fatalities"),
        showlegend = FALSE
      )
  })

  output$duration_dist <- renderPlotly({
    df <- filtered_data() %>%
      filter(!is.na(cow_war_duration)) %>%
      group_by(cow_war_warnum) %>%
      slice_head(n = 1)

    plot_ly(df, x = ~cow_war_duration, type = "histogram",
            marker = list(color = "#1f77b4")) %>%
      layout(
        title = "",
        xaxis = list(title = "Duration (years)"),
        yaxis = list(title = "Frequency"),
        showlegend = FALSE
      )
  })

  output$initiator_pie <- renderPlot({
    df <- filtered_data() %>%
      filter(!is.na(cow_war_initiator)) %>%
      group_by(initiator) %>%
      summarize(n = n_distinct(cow_war_warnum), .groups = "drop")

    if (nrow(df) == 0) {
      plot.new()
      text(0.5, 0.5, "No data available")
    } else {
      pie(df$n, labels = df$initiator, col = c("#d62728", "#1f77b4"),
          main = "")
    }
  })

  output$wars_year_count <- renderPlot({
    df <- filtered_data() %>%
      group_by(year) %>%
      summarize(n_wars = n_distinct(cow_war_warnum), .groups = "drop")

    ggplot(df, aes(x = year, y = n_wars, fill = n_wars)) +
      geom_col() +
      scale_fill_gradient(low = "#fee5d9", high = "#d62728", guide = "none") +
      labs(x = "Year", y = "Number of Wars") +
      theme_minimal()
  })

  output$top_countries <- renderTable({
    filtered_data() %>%
      group_by(state_name) %>%
      summarize(
        n_wars = n_distinct(cow_war_warnum),
        total_deaths = sum(cow_war_fatalities, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(n_wars)) %>%
      slice_head(n = 10) %>%
      rename(
        "Country" = state_name,
        "Wars" = n_wars,
        "Deaths" = total_deaths
      ) %>%
      mutate(Deaths = format(Deaths, big.mark = ","))
  })

  output$country_involvement <- renderPlot({
    df <- filtered_data() %>%
      group_by(state_name) %>%
      summarize(n_wars = n_distinct(cow_war_warnum), .groups = "drop") %>%
      arrange(desc(n_wars)) %>%
      slice_head(n = 15)

    ggplot(df, aes(x = reorder(state_name, n_wars), y = n_wars)) +
      geom_col(fill = "#1f77b4") +
      coord_flip() +
      labs(x = "", y = "Number of Wars") +
      theme_minimal()
  })

  output$data_table <- renderDataTable({
    filtered_data() %>%
      select(state_name, year, cow_war_warnum, war_type, cow_war_duration,
             cow_war_fatalities, initiator) %>%
      rename(
        "Country" = state_name,
        "Year" = year,
        "War #" = cow_war_warnum,
        "Type" = war_type,
        "Duration" = cow_war_duration,
        "Fatalities" = cow_war_fatalities,
        "Role" = initiator
      )
  })

  output$download_data <- downloadHandler(
    filename = function() {
      paste0("cow_wars_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(filtered_data(), file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
