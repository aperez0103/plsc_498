# ============================================================
# Week 14 Problem Set: Uncertainty & Publishing-Quality Figures
# ============================================================

# ----------------------------------------------------------
# Q1: Load data and create simulated survey estimates
# ----------------------------------------------------------

library(ggplot2)
library(dplyr)
library(scales)

library(gapminder)
gap <- gapminder

set.seed(42)
df_survey <- data.frame(
  country = c("United States", "United Kingdom", "Germany",
              "France", "Japan", "Brazil", "India", "Nigeria"),
  dem_support = c(72, 68, 65, 61, 54, 48, 42, 38),
  n = c(1200, 1000, 950, 1100, 800, 600, 750, 500)
)
df_survey$se <- sqrt(df_survey$dem_support *
  (100 - df_survey$dem_support) / df_survey$n)
df_survey$lower <- df_survey$dem_support - 1.96 * df_survey$se
df_survey$upper <- df_survey$dem_support + 1.96 * df_survey$se

dim(gap)
head(df_survey)

# ----------------------------------------------------------
# Q2: Error bar plot — support for democracy
# ----------------------------------------------------------

df_survey$country <- reorder(df_survey$country, df_survey$dem_support)

p2 <- ggplot(df_survey, aes(x = dem_support, y = country)) +
  geom_vline(xintercept = 50, linetype = "dashed") +
  geom_errorbarh(aes(xmin = lower, xmax = upper),
                 height = 0.25) +
  geom_point(size = 3) +
  theme_classic() +
  labs(x = "Support for Democracy (%)", y = NULL,
       title = "Public Support for Democracy by Country")

ggsave("figures/democracy_support_ci.png", plot = p2,
       width = 7, height = 4, dpi = 300, units = "in")

# ----------------------------------------------------------
# Q3: Time series with uncertainty ribbon
# ----------------------------------------------------------

gap_summary <- gap %>%
  group_by(continent, year) %>%
  summarise(
    mean_le = mean(lifeExp),
    se_le = sd(lifeExp) / sqrt(n()),
    lower = mean_le - 1.96 * se_le,
    upper = mean_le + 1.96 * se_le,
    .groups = "drop"
  )

p3 <- ggplot(gap_summary, aes(x = year, color = continent, fill = continent)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
  geom_line(aes(y = mean_le), linewidth = 0.7) +
  theme_classic() +
  theme(legend.position = "bottom") +
  scale_fill_brewer(palette = "Set2") + 
  scale_colour_brewer(palette = "Set2") + 
  labs(x = NULL, y = "Life Expectancy (years)", color = NULL, fill = NULL,
       title = "Life Expectancy by Continent with 95% Confidence Intervals") 

ggsave("figures/life_exp_ribbon.png", plot = p3,
       width = 7, height = 4, dpi = 300, units = "in")

# ----------------------------------------------------------
# Q4: Redesign exercise — before and after
# ----------------------------------------------------------

# Before: deliberately rough version of the democracy support plot
p4_before <- ggplot(df_survey, aes(x = dem_support, y = country)) +
  geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.25) +
  geom_point(size = 3)

ggsave("figures/redesign_before.png", plot = p4_before,
       width = 7, height = 4, dpi = 300, units = "in")

# After: polished version with full publishing-quality checklist
p4_after <- ggplot(df_survey, aes(x = dem_support, y = country)) +
  geom_vline(xintercept = 50, linetype = "dashed", alpha = 0.5) +
  geom_errorbarh(aes(xmin = lower, xmax = upper),
                 height = 0.25, color = "grey40") +
  geom_point(size = 3, color = "grey40") +
  theme_classic(base_size = 13) +
  labs(
    x = "Support for Democracy (%)",
    y = NULL,
    title = "Public Support for Democracy by Country",
    subtitle = "Point estimates with 95% confidence intervals",
    caption = "Source: Simulated survey data (n varies by country)"
  )

ggsave("figures/redesign_after.png", plot = p4_after,
       width = 7, height = 4, dpi = 300, units = "in")

# ----------------------------------------------------------
# Q5: Regression uncertainty — GDP and life expectancy
# ----------------------------------------------------------

gap_2007 <- gap %>% filter(year == 2007)

  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_x_log10(labels = dollar) +
  scale_size_continuous(labels = comma, guide = "none") +
  theme_classic() +
  labs(x = "GDP per Capita (log scale, USD)",
       y = "Life Expectancy (years)",
       title = "GDP per Capita vs. Life Expectancy (2007)")

ggsave("figures/gdp_lifeexp_lm_se.png", plot = p5,
       width = 7, height = 4, dpi = 300, units = "in")

# ----------------------------------------------------------
# Optional Extension: Shiny App
# ----------------------------------------------------------
# Minimal Shiny app: choose a continent from a dropdown and
# display the life expectancy time series (with uncertainty
# ribbon) for that continent only.

library(shiny)

ui <- fluidPage(
  titlePanel("Life Expectancy by Continent"),
  selectInput("continent", "Choose continent:",
              choices = unique(gap_summary$continent)),
  plotOutput("lePlot")
)

server <- function(input, output) {
  output$lePlot <- renderPlot({
    df_filtered <- gap_summary %>% filter(continent == input$continent)
    ggplot(df_filtered, aes(x = year, y = mean_le)) +
      geom_ribbon(aes(ymin = lower, ymax = upper),
                  fill = "grey70", alpha = 0.4) +
      geom_line(linewidth = 0.8) +
      theme_classic(base_size = 13) +
      labs(x = NULL, y = "Life expectancy (years)",
           title = paste0(input$continent,
                          ": life expectancy over time"),
           caption = "Source: Gapminder")
  })
}

shinyApp(ui, server)

