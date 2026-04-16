# APPROACH 4: Modern Shiny App with bslib Theming
# ISIS Mobilization Explorer  (International Relations dataset)
#
# Data: isis_mobilization.rds
#   Built in create_data.R from the Edgerton (2023, JCR) replication archive:
#     https://github.com/jfedgerton/Edgerton-2023-JCR
#   The raw PRIO-GRID cell-year file is aggregated to country-year.
#
#   Columns:
#     country_name, year, isis_fighters, isis_attacks, n_cells,
#     mean_nightlights, mean_gcp_ppp, total_population, mean_unemployment,
#     mean_polity, mean_gov_effect, any_sunni_excluded
#
# PLSC 498 - Week 15: Interactive Visualization with R Shiny

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)

# Load data -------------------------------------------------------------------
data_file <- if (file.exists("isis_mobilization.rds")) {
  "isis_mobilization.rds"
} else {
  "15_week/data/isis_mobilization.rds"
}
isis <- readRDS(data_file)

year_min <- min(isis$year, na.rm = TRUE)
year_max <- max(isis$year, na.rm = TRUE)

# Theme -----------------------------------------------------------------------
theme_obj <- bs_theme(
  version   = 5,
  primary   = "#1f77b4",
  secondary = "#d62728",
  success   = "#2ca02c",
  danger    = "#ff7f0e",
  base_font = font_google("Roboto")
)

# UI --------------------------------------------------------------------------
ui <- page_navbar(
  title   = "ISIS Mobilization Explorer",
  theme   = theme_obj,
  bg      = "#ffffff",
  underline = TRUE,

  # ---- Dashboard ----
  nav_panel(
    "Dashboard",
    layout_sidebar(
      sidebar = sidebar(
        h4("Filters"),
        sliderInput(
          "year_range", "Year:",
          min   = year_min,
          max   = year_max,
          value = c(year_min, year_max),
          step  = 1,
          sep   = ""
        ),
        sliderInput(
          "min_fighters", "Min ISIS fighters per country-year:",
          min   = 0,
          max   = max(isis$isis_fighters, na.rm = TRUE),
          value = 0
        ),
        checkboxInput(
          "sunni_only",
          "Only countries with politically excluded Sunni populations",
          value = FALSE
        ),
        hr(),
        p("Country-year aggregates of the PRIO-GRID cell-level ISIS",
          "mobilization data from Edgerton (2023, JCR).",
          style = "font-size: 0.9em;")
      ),
      navset_card_tab(
        nav_panel(
          "Overview",
          layout_column_wrap(
            value_box(
              title = "Countries with ISIS activity",
              value = textOutput("n_countries"),
              theme = "primary"
            ),
            value_box(
              title = "Total fighters (grid-cell count)",
              value = textOutput("total_fighters"),
              theme = "danger"
            ),
            value_box(
              title = "Total attacks",
              value = textOutput("total_attacks"),
              theme = "success"
            ),
            col_widths = c(4, 4, 4)
          ),
          br(),
          plotOutput("fighters_timeline", height = "400px"),
          br(),
          layout_column_wrap(
            card(
              full_screen = TRUE,
              card_header("Attacks over time"),
              plotlyOutput("attacks_over_time")
            ),
            card(
              full_screen = TRUE,
              card_header("Top 10 source countries (fighters)"),
              plotOutput("top_countries_bar")
            ),
            col_widths = c(6, 6)
          )
        ),
        nav_panel(
          "Correlates",
          br(),
          card(
            full_screen = TRUE,
            card_header("Unemployment vs. ISIS fighters"),
            plotlyOutput("unemp_scatter", height = "450px")
          ),
          br(),
          layout_column_wrap(
            card(
              full_screen = TRUE,
              card_header("Polity vs. fighters"),
              plotlyOutput("polity_scatter")
            ),
            card(
              full_screen = TRUE,
              card_header("Government effectiveness vs. fighters"),
              plotlyOutput("goveffect_scatter")
            ),
            col_widths = c(6, 6)
          )
        )
      )
    )
  ),

  # ---- Country Profile ----
  nav_panel(
    "Country",
    layout_sidebar(
      sidebar = sidebar(
        selectInput(
          "country_select", "Select country:",
          choices  = sort(unique(isis$country_name)),
          selected = "Iraq"
        ),
        hr(),
        p("Drill down into one country's ISIS-mobilization time series.",
          style = "font-size: 0.9em;")
      ),
      navset_card_tab(
        nav_panel(
          "Profile",
          br(),
          layout_column_wrap(
            value_box(title = "Total fighters",
                      value = textOutput("country_fighters"),
                      theme = "primary"),
            value_box(title = "Total attacks",
                      value = textOutput("country_attacks"),
                      theme = "danger"),
            value_box(title = "Mean unemployment",
                      value = textOutput("country_unemployment"),
                      theme = "info"),
            col_widths = c(4, 4, 4)
          ),
          br(),
          card(
            card_header("Fighters and attacks by year"),
            plotOutput("country_timeline", height = "420px")
          )
        ),
        nav_panel(
          "Comparative",
          br(),
          card(
            full_screen = TRUE,
            card_header("Top-15 source countries vs. the selected country"),
            plotlyOutput("country_comparison")
          )
        )
      )
    )
  ),

  # ---- Data ----
  nav_panel(
    "Data",
    br(),
    layout_column_wrap(
      card(
        full_screen = TRUE,
        card_header("Raw country-year data"),
        downloadButton("download_data", "Download CSV"),
        br(), br(),
        dataTableOutput("data_table")
      ),
      col_widths = 12
    )
  ),

  # ---- About ----
  nav_panel(
    "About",
    br(),
    layout_column_wrap(
      card(
        full_screen = TRUE,
        markdown(
"## ISIS Mobilization Explorer

This interactive application explores country-year patterns of ISIS mobilization
built from the replication archive for:

**Edgerton, Jared (2023).** *Journal of Conflict Resolution.*
Repository: <https://github.com/jfedgerton/Edgerton-2023-JCR>

### What you are looking at

The underlying data are PRIO-GRID cell-year observations of ISIS fighter counts
and ISIS attacks, merged with a range of geographic, economic, and political
covariates. `create_data.R` aggregates those cells up to the country-year level
for use in this classroom app.

### Variables

- **isis_fighters** - sum of the cell-level ISIS fighter `count`
- **isis_attacks** - sum of ISIS attacks across grid cells
- **mean_unemployment** - WDI male unemployment (country mean over cells)
- **mean_polity** - Polity2 score
- **mean_gov_effect** - WBGI government effectiveness
- **any_sunni_excluded** - whether any cell belongs to a politically
  excluded Sunni group

### Caveats

These aggregates are illustrative and should not be used for inference outside
of the classroom. See the original paper and replication code for the
cell-level models used in Edgerton (2023)."
        )
      ),
      col_widths = 12
    )
  )
)

# Server ----------------------------------------------------------------------
server <- function(input, output, session) {

  filtered <- reactive({
    df <- isis %>%
      filter(year         >= input$year_range[1],
             year         <= input$year_range[2],
             isis_fighters >= input$min_fighters)
    if (isTRUE(input$sunni_only)) {
      df <- df %>% filter(any_sunni_excluded == 1)
    }
    df
  })

  country_df <- reactive({
    isis %>% filter(country_name == input$country_select)
  })

  # ---- Overview value boxes ----
  output$n_countries <- renderText({
    length(unique(filtered()$country_name))
  })
  output$total_fighters <- renderText({
    format(sum(filtered()$isis_fighters, na.rm = TRUE), big.mark = ",")
  })
  output$total_attacks <- renderText({
    format(sum(filtered()$isis_attacks, na.rm = TRUE), big.mark = ",")
  })

  output$fighters_timeline <- renderPlot({
    df <- filtered() %>%
      group_by(year) %>%
      summarize(fighters = sum(isis_fighters, na.rm = TRUE), .groups = "drop")
    validate(need(nrow(df) > 0, "No data for the current filters."))
    ggplot(df, aes(x = year, y = fighters)) +
      geom_area(fill = "#1f77b4", alpha = 0.5) +
      geom_line(color = "#1f77b4", size = 1) +
      geom_point(color = "#1f77b4", size = 2.5) +
      labs(
        title   = "Total ISIS fighters over time",
        x       = "Year",
        y       = "Fighters (grid-cell count)",
        caption = "Source: Edgerton (2023, JCR)"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold", size = 13))
  })

  output$attacks_over_time <- renderPlotly({
    df <- filtered() %>%
      group_by(year) %>%
      summarize(attacks = sum(isis_attacks, na.rm = TRUE), .groups = "drop")
    plot_ly(df, x = ~year, y = ~attacks,
            type = "scatter", mode = "lines+markers",
            line = list(color = "#d62728", width = 2),
            marker = list(size = 6)) %>%
      layout(xaxis = list(title = "Year"),
             yaxis = list(title = "ISIS attacks"),
             hovermode = "x unified")
  })

  output$top_countries_bar <- renderPlot({
    df <- filtered() %>%
      group_by(country_name) %>%
      summarize(fighters = sum(isis_fighters, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(fighters)) %>%
      slice_head(n = 10)
    validate(need(nrow(df) > 0, "No data."))
    ggplot(df, aes(x = reorder(country_name, fighters), y = fighters)) +
      geom_col(fill = "#1f77b4", alpha = 0.85) +
      coord_flip() +
      labs(x = NULL, y = "Total fighters") +
      theme_minimal(base_size = 13)
  })

  # ---- Correlate scatters ----
  output$unemp_scatter <- renderPlotly({
    df <- filtered()
    plot_ly(df, x = ~mean_unemployment, y = ~isis_fighters,
            type = "scatter", mode = "markers",
            text = ~paste(country_name, year),
            marker = list(size = 9, color = "#1f77b4", opacity = 0.75)) %>%
      layout(xaxis = list(title = "Mean unemployment (WDI)"),
             yaxis = list(title = "ISIS fighters"))
  })

  output$polity_scatter <- renderPlotly({
    df <- filtered()
    plot_ly(df, x = ~mean_polity, y = ~isis_fighters,
            type = "scatter", mode = "markers",
            text = ~paste(country_name, year),
            marker = list(size = 9, color = "#2ca02c", opacity = 0.75)) %>%
      layout(xaxis = list(title = "Polity2"),
             yaxis = list(title = "ISIS fighters"))
  })

  output$goveffect_scatter <- renderPlotly({
    df <- filtered()
    plot_ly(df, x = ~mean_gov_effect, y = ~isis_fighters,
            type = "scatter", mode = "markers",
            text = ~paste(country_name, year),
            marker = list(size = 9, color = "#d62728", opacity = 0.75)) %>%
      layout(xaxis = list(title = "Government effectiveness (WBGI)"),
             yaxis = list(title = "ISIS fighters"))
  })

  # ---- Country tab ----
  output$country_fighters <- renderText({
    format(sum(country_df()$isis_fighters, na.rm = TRUE), big.mark = ",")
  })
  output$country_attacks <- renderText({
    format(sum(country_df()$isis_attacks, na.rm = TRUE), big.mark = ",")
  })
  output$country_unemployment <- renderText({
    v <- mean(country_df()$mean_unemployment, na.rm = TRUE)
    if (is.nan(v)) "N/A" else sprintf("%.1f%%", v)
  })

  output$country_timeline <- renderPlot({
    df <- country_df()
    validate(need(nrow(df) > 0, "No data for this country."))
    df_long <- tidyr::pivot_longer(
      df,
      cols      = c(isis_fighters, isis_attacks),
      names_to  = "metric",
      values_to = "value"
    )
    ggplot(df_long, aes(x = year, y = value, color = metric)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2.5) +
      scale_color_manual(values = c("isis_fighters" = "#1f77b4",
                                    "isis_attacks"  = "#d62728"),
                         labels = c("Fighters", "Attacks"),
                         name   = NULL) +
      labs(
        title = paste(input$country_select,
                      "- ISIS fighters and attacks by year"),
        x = "Year", y = "Count"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title      = element_text(face = "bold"),
            legend.position = "bottom")
  })

  output$country_comparison <- renderPlotly({
    df <- isis %>%
      group_by(country_name) %>%
      summarize(fighters = sum(isis_fighters, na.rm = TRUE), .groups = "drop") %>%
      arrange(desc(fighters)) %>%
      slice_head(n = 15)

    df$highlight <- ifelse(df$country_name == input$country_select,
                           "Selected", "Other")

    plot_ly(df, x = ~reorder(country_name, fighters), y = ~fighters,
            color = ~highlight, colors = c("Other" = "#1f77b4",
                                           "Selected" = "#d62728"),
            type = "bar") %>%
      layout(xaxis = list(title = "", tickangle = -45),
             yaxis = list(title = "Total fighters"),
             showlegend = FALSE,
             margin = list(b = 100))
  })

  # ---- Data tab ----
  output$data_table <- renderDataTable({
    isis %>%
      mutate(across(where(is.numeric), ~ round(.x, 3))) %>%
      rename(
        "Country"         = country_name,
        "Year"            = year,
        "Fighters"        = isis_fighters,
        "Attacks"         = isis_attacks,
        "Grid cells"      = n_cells,
        "Mean nightlights"= mean_nightlights,
        "Mean GCP (ppp)"  = mean_gcp_ppp,
        "Population"      = total_population,
        "Unemployment"    = mean_unemployment,
        "Polity2"         = mean_polity,
        "Gov effectiveness" = mean_gov_effect,
        "Sunni excluded"  = any_sunni_excluded
      )
  })

  output$download_data <- downloadHandler(
    filename = function() paste0("isis_mobilization_", Sys.Date(), ".csv"),
    content  = function(file) write.csv(isis, file, row.names = FALSE)
  )
}

# Run -------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
