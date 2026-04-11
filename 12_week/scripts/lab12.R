# ----------------------------------
# Script name: lab12.R
# Purpose: PLSC 498 In-Class Problem Set - Time series and Trends with Presidential Approval Data
# ----------------------------------

##setup----
# load required packages
library(ggplot2)
library(dplyr)
library(tidyr)
library(zoo)
library(gapminder)
library(scales)
library(gridExtra)
library(viridis)

# access datasets
econ <- ggplot2::economics
pres <- ggplot2::presidential

# gapminder data
library(gapminder)
gap <- gapminder

# quick inspection
head(econ)

# number of rows & columns
dim(econ)
dim(gap)
dim(pres)

# confirm date and empoloy columns exist in econ
c("date", "unemploy") %in% names(econ)#does exist

#range of years in gapminder
range(gap$year)


## Line chart: unemployment over time----

# Step 1: plot unemployment over time
# Step 2: format the x-axis
# Step 3: add labels
# Step 4: save figure

fig1 <- ggplot(econ, aes(x = date, y = unemploy)) +
  geom_line() +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  scale_y_continuous(labels = scales::comma_format()) +
  theme_classic() +
  labs(title = "Figure 1: Unemployment Over Time", x = "Year", y = "Number of Unemployed (in the thousands)")

ggsave("figures/unemployment_line.png", fig1, height = 7, width = 9)


## Smoothing comparison: rolling mean vs LOESS----

# rolling mean
econ <- econ %>%
  mutate(roll_12 = zoo::rollmean(unemploy, k = 12,
                                 fill = NA, align = "right"))
fig2.1 <- ggplot(econ, aes(x = date)) +
geom_line(aes(y = unemploy), alpha = 0.3) +
  geom_line(aes(y = roll_12), color = "steelblue", linewidth = 1) +
  labs(title = "Figure 2.1: Unemployment Over Time", subtitle = "Rolling Mean Smoothed", x = "Year", y = "Number of Unemployed (in the thousands)")

# LOESS
fig2.2 <- ggplot(econ, aes(x = date, y = unemploy)) +
  geom_line(alpha = 0.3) +
  geom_smooth(method = "loess", se = FALSE) +
  labs(title = "Figure 2.2: Unemployment Over Time", subtitle = "LOESS Smoothed", x = "Year", y = "Number of Unemployed (in the thousands)")

fig2 <- grid.arrange(fig2.1, fig2.2, ncol = 2) #combine both figures into one frame

ggsave("figures/unemployment_smoothed.png", fig2, height = 7, width = 9)

## Annotation: Marking presidential terms----
fig3 <- ggplot(econ, aes(x = date, y = unemploy)) +
  geom_rect(data = pres, aes(xmin = start, xmax = end,
                             fill = name), ymin = -Inf, ymax = Inf,
            alpha = 0.15, inherit.aes = FALSE) +
  geom_text( #add president names in their respective rectangles
    data = pres,
    aes(
      x = start + (end - start) / 2,  # midpoint of term
      y = Inf,
      label = name
    ),
    vjust = 2)+ #lower names from top for visibility
  geom_line() +
  theme_classic() +
  theme(legend.position = "none") +
  labs(title = "Figure 3: Unemployment Over Time", subtitle = "By Presidential Terms", x = "Year", y = "Number of Unemployed (in the thousands)")

ggsave("figures/unemployment_presidents.png", fig3, height = 7, width = 12)

## Multiple Time Series: GDP per capita ---
gap_sub <- gap %>%
  filter(country %in% c("China", "Japan",
                        "Germany", "Italy"))
fig4 <- ggplot(gap_sub, aes(x = year, y = gdpPercap)) +
  geom_line() +
  geom_point(size = 1.5) +
  facet_wrap(~ country, scales = "fixed") +
  theme_classic() +
  labs(title = "Figure 4: GDP Per Capita Over Time", subtitle = "By Country", x = "Year", y = "GDP Per Capita")

ggsave("figures/gdp_faceted.png", fig4, height = 7, width = 10)
