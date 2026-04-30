# APPROACH 5: Shiny App with page_fillable + value boxes + plotly
# Global Battle Deaths Explorer  (International Relations dataset)
#
# Data: battle_deaths.rds
#   Built in create_data.R from 07_week/data/battle_deaths.rds
#   (Country-year battle deaths with World Bank region and income group.)
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

# Install any missing packages automatically --------------------------------
required_packages <- c("shiny", "bslib", "dplyr", "ggplot2", "plotly",
                       "bsicons", "scales", "viridisLite")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(viridisLite)

# Load data -------------------------------------------------------------------
data_file <- if (file.exists("battle_deaths.rds")) {
  "battle_deaths.rds"
} else {
  "data/battle_deaths.rds"
}
bd <- readRDS(data_file)

year_min <- min(bd$year, na.rm = TRUE)
year_max <- max(bd$year, na.rm = TRUE)

region_choices <- sort(unique(bd$region))
income_choices <- sort(unique(bd$income))

theme_obj <- bs_theme(
  version   = 5,
  primary   = "#b2182b",
  secondary = "#2166ac",
  base_font = font_google("Roboto")
)

# UI --------------------------------------------------------------------------
ui <- page_sidebar(
  title = "Global Battle Deaths Explorer",
  theme = theme_obj,

  sidebar = sidebar(
    width = 300,
    h4("Filters"),
    sliderInput(
      "year_range", "Year:",
      min   = year_min,
      max   = year_max,
      value = c(year_min, year_max),
      step  = 1,
      sep   = ""
    ),
    checkboxGroupInput(
      "region_filter", "Region:",
      choices  = region_choices,
      selected = region_choices
    ),
    checkboxGroupInput(
      "income_filter", "Income group:",
      choices  = income_choices,
      selected = income_choices
    ),
    hr(),
    p("Country-year battle deaths from PLSC 498 Week 7.",
      style = "font-size: 0.9em; color: #555;")
  ),

  ## ---- Value boxes row ----
  layout_columns(
    col_widths = c(3, 3, 3, 3),
    value_box(
      title    = "Total battle deaths",
      value    = textOutput("total_deaths"),
      showcase = bsicons::bs_icon("exclamation-triangle"),
      theme    = "danger"
    ),
    value_box(
      title    = "Countries with deaths",
      value    = textOutput("n_countries"),
      showcase = bsicons::bs_icon("globe"),
      theme    = "primary"
    ),
    value_box(
      title    = "Mean deaths / country-year",
      value    = textOutput("mean_deaths"),
      showcase = bsicons::bs_icon("graph-up"),
      theme    = "secondary"
    ),
    value_box(
      title    = "Deadliest country-year",
      value    = textOutput("deadliest"),
      showcase = bsicons::bs_icon("award"),
      theme    = "warning"
    )
  ),

  ## ---- Navset tabs ----
  navset_card_tab(
    nav_panel(
      "Trends",
      layout_columns(
        col_widths = c(8, 4),
        card(
          full_screen = TRUE,
          card_header("Battle deaths over time by region"),
          plotlyOutput("timeline_plot", height = "450px")
        ),
        card(
          full_screen = TRUE,
          card_header("Deaths by income group"),
          plotOutput("income_box", height = "450px")
        )
      )
    ),
    nav_panel(
      "Countries",
      layout_columns(
        col_widths = c(6, 6),
        card(
          full_screen = TRUE,
          card_header("Top 15 countries"),
          plotOutput("top_countries", height = "450px")
        ),
        card(
          full_screen = TRUE,
          card_header("Highlighted country time series"),
          div(
            tags$div(
              style = "color: #777; font-size: 0.85em; margin-bottom: 6px;",
              "Note: Income group and Region filters are ignored."
            ),
            style = "float: right; width = 250px;",
            selectInput(
              "country_select", NULL,
              choices  = c("(Select a Country)", sort(unique(bd$country))),
              selected = "(Select a Country)",
              width = "100%"
            )
          ),
          plotOutput("highlight_plot", height = "450px")
        )
      )
    ),
    nav_panel(
      "Region detail",
      card(
        full_screen = TRUE,
        card_header("Deaths by region over time (stacked)"),
        plotlyOutput("region_stack", height = "500px")
      )
    ),
    nav_panel(
      "Data",
      card(
        full_screen = TRUE,
        card_header("Filtered rows"),
        downloadButton("download_data", "Download CSV"),
        br(), br(),
        dataTableOutput("data_table")
      )
    ),
    nav_panel(
      "About",
      card(
        markdown(
"## Global Battle Deaths Explorer

This app visualizes **country-year battle deaths** from the Week 7 dataset
used earlier in PLSC 498 (`07_week/data/battle_deaths.rds`). Each row is a
country-year observation with the number of reported battle deaths plus the
World Bank **region** and **income group** classification.

### Things to try
- Watch the regional mix shift across decades in the **Trends** tab.
- Use the **Countries** tab to highlight a single country and compare its
  time series against the top 15 deadliest countries.
- In the **Region detail** tab, toggle regions on/off in the legend to isolate
  subsets.

### Source
PLSC 498, Week 7 - battle deaths data as prepared in `07_week/data/`.
"
        )
      )
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered <- reactive({ #reactive df for *all* filters in sidebar
    bd %>%
      filter(
        year   >= input$year_range[1],
        year   <= input$year_range[2],
        region %in% input$region_filter,
        income %in% input$income_filter
      )
  })

  highlight_data <- reactive({ #reactive df for *only* country & year
    req(input$country_select)
    
    bd %>%
      filter(
        country == input$country_select,
        year >= input$year_range[1],
        year <= input$year_range[2]
      )
  })
  # ---- Value boxes ----
  output$total_deaths <- renderText({
    format(sum(filtered()$battle_deaths, na.rm = TRUE), big.mark = ",")
  })
  output$n_countries <- renderText({
    as.character(dplyr::n_distinct(filtered()$country))
  })
  output$mean_deaths <- renderText({
    v <- mean(filtered()$battle_deaths, na.rm = TRUE)
    if (is.nan(v)) "N/A" else format(round(v), big.mark = ",")
  })
  output$deadliest <- renderText({
    df <- filtered()
    if (nrow(df) == 0) return("N/A")
    row <- df[which.max(df$battle_deaths), ]
    sprintf("%s (%d)", row$country, row$year)
  })

  # ---- Trends ----
  output$timeline_plot <- renderPlotly({
    df <- filtered() %>%
      group_by(year, region) %>%
      summarize(deaths = sum(battle_deaths, na.rm = TRUE), .groups = "drop")
    validate(need(nrow(df) > 0, "No data for the current filters."))
    p <- ggplot(df, aes(x = year, y = deaths, color = region)) +
      geom_line(linewidth = 1) +
      geom_point(size = 1.8, alpha = 0.8) +
      scale_color_viridis_d(option = "D") +
      scale_y_continuous(labels = scales::comma) +
      labs(x = "Year", y = "Battle deaths", color = "Region") +
      theme_minimal(base_size = 13)
    ggplotly(p)
  })

  output$income_box <- renderPlot({
    df <- filtered()
    validate(need(nrow(df) > 0, "No data."))
    ggplot(df, aes(x = income, y = battle_deaths, fill = income)) +
      geom_boxplot(alpha = 0.8, show.legend = FALSE) +
      scale_y_log10(labels = scales::comma) +
      scale_fill_viridis_d(option = "D") +
      labs(x = NULL, y = "Battle deaths (log10)") +
      theme_minimal(base_size = 12) +
      theme(axis.text.x = element_text(angle = 25, hjust = 1))
  })

  # ---- Countries tab ----
  output$top_countries <- renderPlot({
    df <- filtered() %>%
      group_by(country) %>%
      summarize(deaths = sum(battle_deaths, na.rm = TRUE),
                region = first(region), .groups = "drop") %>%
      arrange(desc(deaths)) %>%
      slice_head(n = 15)
    validate(need(nrow(df) > 0, "No data."))
    ggplot(df, aes(x = reorder(country, deaths), y = deaths, fill = region)) +
      geom_col(alpha = 0.9) +
      coord_flip() +
      scale_y_continuous(labels = scales::comma) +
      scale_fill_viridis_d(option = "D") +
      labs(x = NULL, y = "Total battle deaths", fill = "Region") +
      theme_minimal(base_size = 12)
  })

  output$highlight_plot <- renderPlot({
    req(input$country_select)
    if (identical(input$country_select, "(Select a Country)")) {
      plot.new()
      title(main = "Select a country to highlight it.")
      return()
    }
    df <- highlight_data()
    validate(need(nrow(df) > 0,
                  "No observations for that country under the current filters."))
    ggplot(df, aes(x = year, y = battle_deaths)) +
      geom_area(fill = "#b2182b", alpha = 0.4) +
      geom_line(color = "#b2182b", linewidth = 1) +
      geom_point(color = "#b2182b", size = 2.5) +
      scale_y_continuous(labels = scales::comma) +
      labs(
        title = paste(input$country_select, "battle deaths"),
        x     = "Year",
        y     = "Battle deaths"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold"))
  })

  # ---- Region detail ----
  output$region_stack <- renderPlotly({
    df <- filtered() %>%
      group_by(year, region) %>%
      summarize(deaths = sum(battle_deaths, na.rm = TRUE), .groups = "drop")
    
    validate(need(nrow(df) > 0, "No data."))
    
    regions <- sort(unique(df$region))
    
    region_palette <- setNames(
      viridisLite::viridis(length(regions), option = "D"),
      regions
    )
    
    p <- plot_ly()
    
    for (r in regions) {
      df_r <- df %>% filter(region == r)
      
      p <- p %>%
        add_trace(
          data = df_r,
          x = ~year,
          y = ~deaths,
          type = "scatter",
          mode = "none",
          stackgroup = "one",
          name = r,
          fillcolor = region_palette[r],
          line = list(width = 0.5, color = "#FFFFFF")
        )
    }
    
    p %>%
      layout(
        xaxis = list(title = "Year"),
        yaxis = list(title = "Battle deaths"),
        hovermode = "x unified"
      )
  })
  
  # ---- Data ----
  output$data_table <- renderDataTable({
    filtered() %>%
      rename(
        "ISO2"    = iso2c,
        "Country" = country,
        "Year"    = year,
        "Battle deaths" = battle_deaths,
        "Region"  = region,
        "Income"  = income
      )
  })

  output$download_data <- downloadHandler(
    filename = function() paste0("battle_deaths_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(filtered(), file, row.names = FALSE)
  )
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
