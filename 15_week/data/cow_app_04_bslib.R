# APPROACH 4: Modern Shiny App with bslib Theming
# Interstate Conflicts Dashboard
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(bslib)
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

# Define custom theme
theme <- bs_theme(
  version = 5,
  primary = "#1f77b4",
  secondary = "#d62728",
  success = "#2ca02c",
  danger = "#ff7f0e",
  base_font = font_google("Roboto")
)

# Define UI
ui <- page_navbar(
  title = "Interstate Conflicts Explorer",
  theme = theme,
  bg = "#ffffff",
  underline = TRUE,

  # Page 1: Dashboard
  nav_panel(
    "Dashboard",
    layout_sidebar(
      sidebar = sidebar(
        h4("Filters"),
        sliderInput(
          "year_range_dash",
          "Year Range:",
          min = min(cow_data$year, na.rm = TRUE),
          max = max(cow_data$year, na.rm = TRUE),
          value = c(1945, max(cow_data$year, na.rm = TRUE)),
          step = 1
        ),
        checkboxGroupInput(
          "war_type_filter_dash",
          "War Type:",
          choices = unique(cow_data$war_type),
          selected = unique(cow_data$war_type)[1:min(2, length(unique(cow_data$war_type)))]
        ),
        hr(),
        p("This dashboard provides interactive exploration of interstate conflicts",
          "from the Correlates of War project.", style = "font-size: 0.9em;")
      ),
      navset_card_tab(
        nav_panel(
          "Overview",
          layout_column_wrap(
            value_box(
              title = "Total Conflicts",
              value = textOutput("total_conflicts_dash"),
              theme = "primary"
            ),
            value_box(
              title = "Total Fatalities",
              value = textOutput("total_fatalities_dash"),
              theme = "danger"
            ),
            value_box(
              title = "Countries Involved",
              value = textOutput("countries_involved_dash"),
              theme = "success"
            ),
            col_widths = c(4, 4, 4)
          ),
          br(),
          plotOutput("timeline_dash", height = "400px"),
          br(),
          layout_column_wrap(
            card(
              full_screen = TRUE,
              card_header("Fatalities by Year"),
              plotlyOutput("fatalities_over_time_dash")
            ),
            card(
              full_screen = TRUE,
              card_header("War Type Distribution"),
              plotOutput("wartype_pie_dash")
            ),
            col_widths = c(6, 6)
          )
        ),
        nav_panel(
          "Trends",
          br(),
          card(
            full_screen = TRUE,
            card_header("Conflict Intensity Over Time"),
            plotlyOutput("intensity_plot_dash", height = "500px")
          ),
          br(),
          layout_column_wrap(
            card(
              full_screen = TRUE,
              card_header("Duration Distribution"),
              plotlyOutput("duration_plot_dash")
            ),
            card(
              full_screen = TRUE,
              card_header("Top Combatants"),
              tableOutput("top_combatants_dash")
            ),
            col_widths = c(6, 6)
          )
        )
      )
    )
  ),

  # Page 2: Country Analysis
  nav_panel(
    "Countries",
    layout_sidebar(
      sidebar = sidebar(
        selectInput(
          "country_select",
          "Select Country:",
          choices = sort(unique(cow_data$state_name)),
          selected = "United States"
        ),
        hr(),
        p("View conflict participation by country.",
          style = "font-size: 0.9em;")
      ),
      navset_card_tab(
        nav_panel(
          "Profile",
          br(),
          layout_column_wrap(
            value_box(
              title = "Conflicts",
              value = textOutput("country_conflicts"),
              theme = "primary"
            ),
            value_box(
              title = "Fatalities",
              value = textOutput("country_fatalities"),
              theme = "danger"
            ),
            value_box(
              title = "Avg Duration",
              value = textOutput("country_duration"),
              theme = "info"
            ),
            col_widths = c(4, 4, 4)
          ),
          br(),
          card(
            card_header("Conflict Timeline"),
            plotOutput("country_timeline")
          )
        ),
        nav_panel(
          "Comparative",
          br(),
          card(
            full_screen = TRUE,
            card_header("Most Involved Countries"),
            plotlyOutput("country_comparison")
          )
        )
      )
    )
  ),

  # Page 3: Data Explorer
  nav_panel(
    "Data",
    br(),
    layout_column_wrap(
      card(
        full_screen = TRUE,
        card_header("Raw Data"),
        downloadButton("download_data_page", "Download CSV"),
        br(), br(),
        dataTableOutput("data_explorer")
      ),
      col_widths = 12
    )
  ),

  # Page 4: About
  nav_panel(
    "About",
    br(),
    layout_column_wrap(
      card(
        full_screen = TRUE,
        markdown(
          "## Interstate Conflicts Explorer

This interactive application visualizes data from the **Correlates of War** project,
a comprehensive dataset on interstate conflicts and wars.

### Key Features

- **Real-time filtering** by year and conflict type
- **Interactive visualizations** with Plotly
- **Country-level analysis** for detailed exploration
- **Data export** capabilities for further analysis

### About Correlates of War

The Correlates of War (COW) project is a research initiative that provides data on
various aspects of international conflict and cooperation. The interstate war dataset
includes information on wars between two or more states since 1816.

### Data Variables

- **War Number**: Unique identifier for each conflict
- **Duration**: Length of conflict in years
- **Fatalities**: Battle-related deaths
- **War Type**: Inter-state or intra-state classification
- **Initiator**: Which party initiated the conflict

### Data Source

Visit [Correlates of War](https://correlatesofwar.org/) for more information.
"
        )
      ),
      col_widths = 12
    )
  )
)

# Define server
server <- function(input, output, session) {
  # Reactive filtered data
  filtered_data_dash <- reactive({
    cow_data %>%
      filter(
        year >= input$year_range_dash[1],
        year <= input$year_range_dash[2],
        war_type %in% input$war_type_filter_dash
      )
  })

  # Country-specific data
  country_data <- reactive({
    cow_data %>%
      filter(state_name == input$country_select)
  })

  # ===== Dashboard Tab =====
  output$total_conflicts_dash <- renderText({
    length(unique(filtered_data_dash()$cow_war_warnum))
  })

  output$total_fatalities_dash <- renderText({
    format(sum(filtered_data_dash()$cow_war_fatalities, na.rm = TRUE), big.mark = ",")
  })

  output$countries_involved_dash <- renderText({
    length(unique(filtered_data_dash()$state_name))
  })

  output$timeline_dash <- renderPlot({
    df <- filtered_data_dash() %>%
      group_by(year) %>%
      summarize(
        n_wars = n_distinct(cow_war_warnum),
        total_deaths = sum(cow_war_fatalities, na.rm = TRUE),
        .groups = "drop"
      )

    ggplot(df, aes(x = year, y = n_wars)) +
      geom_area(fill = "#1f77b4", alpha = 0.5) +
      geom_line(color = "#1f77b4", size = 1) +
      labs(
        title = "Number of Interstate Wars Over Time",
        x = "Year",
        y = "Number of Wars",
        caption = "Source: Correlates of War"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(face = "bold", size = 12),
        panel.grid.minor = element_blank()
      )
  })

  output$fatalities_over_time_dash <- renderPlotly({
    df <- filtered_data_dash() %>%
      group_by(year) %>%
      summarize(
        total_deaths = sum(cow_war_fatalities, na.rm = TRUE),
        .groups = "drop"
      )

    plot_ly(df, x = ~year, y = ~total_deaths, type = "scatter", mode = "lines+markers",
            line = list(color = "#d62728", width = 2),
            marker = list(size = 5)) %>%
      layout(
        xaxis = list(title = "Year"),
        yaxis = list(title = "Total Fatalities"),
        hovermode = "x unified"
      )
  })

  output$wartype_pie_dash <- renderPlot({
    df <- filtered_data_dash() %>%
      group_by(war_type) %>%
      summarize(n = n_distinct(cow_war_warnum), .groups = "drop")

    pie(df$n, labels = df$war_type,
        col = c("#1f77b4", "#d62728", "#2ca02c", "#ff7f0e")[1:nrow(df)])
  })

  output$intensity_plot_dash <- renderPlotly({
    df <- filtered_data_dash() %>%
      group_by(year, war_type) %>%
      summarize(
        n_wars = n_distinct(cow_war_warnum),
        .groups = "drop"
      )

    plot_ly(df, x = ~year, y = ~n_wars, color = ~war_type, type = "scatter",
            mode = "lines", fill = "tozeroy") %>%
      layout(
        xaxis = list(title = "Year"),
        yaxis = list(title = "Number of Wars"),
        hovermode = "x unified",
        showlegend = TRUE
      )
  })

  output$duration_plot_dash <- renderPlotly({
    df <- filtered_data_dash() %>%
      filter(!is.na(cow_war_duration))

    plot_ly(df, x = ~cow_war_duration, type = "histogram",
            marker = list(color = "#1f77b4")) %>%
      layout(
        xaxis = list(title = "Duration (years)"),
        yaxis = list(title = "Frequency"),
        showlegend = FALSE
      )
  })

  output$top_combatants_dash <- renderTable({
    filtered_data_dash() %>%
      group_by(state_name) %>%
      summarize(
        n_conflicts = n_distinct(cow_war_warnum),
        total_deaths = sum(cow_war_fatalities, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(n_conflicts)) %>%
      slice_head(n = 10) %>%
      rename(
        "Country" = state_name,
        "Conflicts" = n_conflicts,
        "Deaths" = total_deaths
      ) %>%
      mutate(Deaths = format(Deaths, big.mark = ","))
  })

  # ===== Country Tab =====
  output$country_conflicts <- renderText({
    length(unique(country_data()$cow_war_warnum))
  })

  output$country_fatalities <- renderText({
    format(sum(country_data()$cow_war_fatalities, na.rm = TRUE), big.mark = ",")
  })

  output$country_duration <- renderText({
    dur <- mean(country_data()$cow_war_duration, na.rm = TRUE)
    sprintf("%.1f years", dur)
  })

  output$country_timeline <- renderPlot({
    df <- country_data() %>%
      group_by(year) %>%
      summarize(
        n_wars = n_distinct(cow_war_warnum),
        .groups = "drop"
      )

    if (nrow(df) == 0) {
      plot.new()
      text(0.5, 0.5, "No conflicts for this country")
    } else {
      ggplot(df, aes(x = year, y = n_wars)) +
        geom_col(fill = "#1f77b4", alpha = 0.7) +
        labs(
          x = "Year",
          y = "Number of Conflicts",
          title = paste(input$country_select, "- Conflict Participation")
        ) +
        theme_minimal() +
        theme(plot.title = element_text(face = "bold"))
    }
  })

  output$country_comparison <- renderPlotly({
    df <- cow_data %>%
      group_by(state_name) %>%
      summarize(
        n_conflicts = n_distinct(cow_war_warnum),
        .groups = "drop"
      ) %>%
      arrange(desc(n_conflicts)) %>%
      slice_head(n = 15)

    plot_ly(df, x = ~reorder(state_name, n_conflicts), y = ~n_conflicts,
            type = "bar", marker = list(color = "#1f77b4")) %>%
      layout(
        xaxis = list(title = "", tickangle = -45),
        yaxis = list(title = "Number of Conflicts"),
        showlegend = FALSE,
        margin = list(b = 100)
      )
  })

  # ===== Data Tab =====
  output$data_explorer <- renderDataTable({
    cow_data %>%
      select(state_name, year, cow_war_warnum, war_type = cow_war_wartype,
             duration = cow_war_duration, fatalities = cow_war_fatalities) %>%
      rename(
        "Country" = state_name,
        "Year" = year,
        "War ID" = cow_war_warnum,
        "Type" = war_type,
        "Duration" = duration,
        "Fatalities" = fatalities
      )
  })

  output$download_data_page <- downloadHandler(
    filename = function() {
      paste0("cow_conflicts_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(cow_data, file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
