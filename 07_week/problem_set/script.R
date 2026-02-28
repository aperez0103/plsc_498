## -------------------------- ##
## Visualize battle deaths    ##
## -------------------------- ##

## Clear working directory 
rm(list = ls())

## Load libraries
library(ggplot2)
library(plyr)
library(dplyr)

## Load in the data
df <- readRDS("07_week/data/battle_deaths.rds") 
colnames(df)
df2 <- subset(df, !is.na(battle_deaths))
battle_deaths_hist <- ggplot(df2, aes(x = log1p(battle_deaths))) + 
  geom_histogram(fill = "darkblue") + 
  theme_bw() + 
  labs(x = "Count of Battle Deaths (Log + 1)", y = "Count")


battle_deaths_density <- ggplot(df2, aes(x = log1p(battle_deaths))) + 
  geom_density(fill = "gray20") + 
  theme_classic() + 
  labs(x = "Count of Battle Deaths (Log + 1)", y = "Count")


df2 <- subset(df, !is.na(battle_deaths))
qq_normality_plot <- ggplot(df2, aes(sample = log1p(battle_deaths))) + 
  stat_qq(size = 0.8, alpha = 0.6) +
  stat_qq_line() + 
  theme_classic() + 
  labs(x = "Theoretical Quantiles (Normal Distribution)",
       y = "Sample Quantiles (Battle Deaths)") 
  

df2 <- df2 %>%
  mutate(
    income = factor(
      income, 
      levels = c(
        "High income", 
        "Upper middle income",
        "Lower middle income",
        "Low income",
        "Not classified"
      )
    )
  )


p_inc <- ggplot(df2 %>% 
                  filter(income != "Not classified")
                , aes(x = battle_deaths, fill = income)) + 
  geom_histogram(bins = 30) + 
  facet_wrap( ~ income, ncol = 2, scales = "free") + 
  theme_classic() + 
  scale_x_continuous(
    trans = "log1p",
    breaks = c(0, 1, 10, 100, 1000, 10000),
    labels = scales::comma
  ) +
  labs(x = "Battle deaths (scale: log(x + 1))",
       y = "Count") + 
  scale_fill_brewer(palette = "Set2") + 
  theme(legend.position = "none")

p_reg <- ggplot(df2 %>% 
                  filter(region != "North America") %>%
                  mutate(region = factor(
                    region, levels = c(
                      "Latin America & Caribbean",
                      "East Asia & Pacific",
                      "Europe & Central Asia",
                      "South Asia",
                      "Middle East & North Africa",
                      "Sub-Saharan Africa"
                    )
                  ))
                , aes(x = battle_deaths, fill = region)) + 
  geom_histogram() + 
  facet_wrap( ~ region, ncol = 3) + 
  theme_classic() + 
  scale_x_continuous(
    trans = "log1p",
    breaks = c(0, 1, 10, 100, 1000, 10000),
    labels = scales::comma
  ) +
  labs(x = "Battle deaths (scale: log(x + 1))",
       y = "Count") + 
  scale_fill_brewer(palette = "Dark2") + 
  theme(legend.position = "none")

