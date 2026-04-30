# ----------------------------------
# Script name: lab14.R
# Purpose: PLSC 498 In-Class Problem Set - Uncertainty and Publication-Quality Figures with World Development Indicators
# ----------------------------------

##setup----
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)

##Data-----
#gapminder data
library(gapminder); gap <- gapminder


#create simulated survey data
set.seed(42); df_survey <- data.frame(
  country = c("United States", "United Kingdom", "Germany", "France", "Japan", "Brazil", "India", "Nigeria"),
  dem_support = c(72, 68, 65, 61, 54, 48, 42, 38),
  n = c(1200, 1000, 950, 1100, 800, 600, 750, 500)
)

df_survey$se <- sqrt(df_survey$dem_support *
  (100 - df_survey$dem_support) / df_survey$n)
df_survey$lower <- df_survey$dem_support - 1.96 * df_survey$se
df_survey$upper <- df_survey$dem_support + 1.96 * df_survey$se

#inspect data
dim(gap)
head(df_survey)
range(gap$year) #year range

## Error Bar plot - Support for Democracy----
attach(df_survey)
df_survey$country  <- reorder(country, dem_support)

fig1 <- ggplot(df_survey, aes(x = dem_support, y = country)) +
  geom_vline(xintercept = 50, linetype = "dashed") +
  geom_errorbar(aes(xmin = lower, xmax = upper),
                height = 0.25,
                ) +
  geom_point(size = 3) +
  theme_classic() +
  labs(x = "Democracy Support", y = NULL, title = "Support for Democracy by Country", subtitle = "Point Estimates with 95% confidence intervals", caption= "Source: Simulated Survey Data | Dashed Line = 50% Threshold")

ggsave("figures/democracy_support_ci.png", fig1, height = 5, width = 9, dpi = 300)

detach(df_survey)
##Time series w/ uncertainty ribbon ----
gap_summary <- gap %>%
  group_by(continent, year) %>%
  summarise(
    mean_le = mean(lifeExp),
    se_le = sd(lifeExp) / sqrt(n()),
    lower = mean_le - 1.96 * se_le,
    upper = mean_le + 1.96 * se_le,
    .groups = "drop"
  )

fig2 <- ggplot(gap_summary, aes(x = year, color = continent, fill = continent)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
  geom_line(aes(y = mean_le), linewidth = 0.7) +
  theme_classic() +
  theme(legend.position = "bottom") +
  labs(x = NULL, y = "Average Life Expectancy (in years)", color = NULL, fill = NULL,
       title = "Life Expectancy by Continent", subtitle = "With 95% Confidence Ribbons", caption = "Source: Gapminder Package")

ggsave("figures/life_exp_ribbon.png", fig2, width = 9, height = 5, dpi = 300)

## Redesign, before and after----
fig3 <- ggplot(gap_summary, aes(x = year, color = continent, fill = continent)) +
  geom_ribbon(aes(ymin = lower, ymax = upper), alpha = 0.15, color = NA) +
  geom_line(aes(y = mean_le), linewidth = 0.7) #before 

fig4 <- fig2 #after

ggsave("figures/redesign_before.png", fig3, width = 9, height = 5, dpi = 300)
ggsave("figures/redesign_after.png", fig4, width = 9, height = 5, dpi = 300)


## Regression uncertainty: GDP and life expectancy
gap_2007 <- gap %>% filter(year == 2007)
fig5 <- ggplot(gap_2007, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(alpha = 0.5, aes(size = pop)) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_x_log10(labels = dollar) +
  scale_size_continuous(labels = comma, guide = "none") +
  theme_classic() +
  labs(x = "GDP (Log-Scaled)", y = "Life Expectancy", title = "Relationship between GDP and Life Expectancy in 2007", subtitle="With 95% Confidence Ribbon | With Respect to Population Size", caption = "Source: Gapminder Package")

ggsave("figures/gdp_lifeexp_lm_se.png", fig5, width = 9, height = 5, dpi = 300)

##Shiny App----
library(shiny)

ui <- fluidPage( #create user interface
  selectInput(
    inputId = "continent",
    label = "Choose continent:",
    choices = unique(gap_summary$continent)),
  plotOutput("lePlot")
)

server <- function(input, output) {
  output$lePlot <- renderPlot ({
    df_filtered <- gap_summary %>% filter(continent == input$continent)
    ggplot(df_filtered, aes(x = year, y = mean_le)) +
      geom_ribbon(aes(ymin = lower, ymax = upper), fill = "grey70", alpha = 0.4) +
      geom_line(linewidth = 0.8) +
      theme_classic() +
      labs(x = NULL, y = "Life Expectancy (Years)",
           title = paste0(input$continent, ":Life Expectancy Over Time"), 
           subtitle = "With 95% Confidence Ribbon", 
           caption = "Source: Gapminder Package")
  })
}

shinyApp(ui, server)
