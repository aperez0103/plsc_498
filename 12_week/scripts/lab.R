library(ggplot2)
library(dplyr)
library(zoo)
library(gapminder)

set.seed(123)

econ <- ggplot2::economics
pres <- ggplot2::presidential
gap <- gapminder

dim(econ)
names(econ)
head(econ)
dim(pres)
dim(gap)
range(gap$year)

p1 <- ggplot(econ, aes(x = date, y = unemploy)) +
  geom_line(linetype = "dashed", linewidth = 2) +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  theme_bw() +
  labs(title = "US Unemployment Over Time",
       x = "Date",
       y = "Unemployed (thousands)")

ggsave("figures/unemployment_line.png", p1, width = 8, height = 5, dpi = 300)

econ <- econ %>%
  mutate(roll_12 = zoo::rollmean(unemploy, k = 12, fill = NA, align = "right"))

p2a <- ggplot(econ, aes(x = date)) +
  geom_line(aes(y = unemploy), alpha = 0.3) +
  geom_line(aes(y = roll_12), color = "steelblue", linewidth = 1) +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  theme_bw() +
  labs(title = "Unemployment with 12-Month Rolling Mean",
       x = "Date", y = "Unemployed (thousands)")

p2b <- ggplot(econ, aes(x = date, y = unemploy)) +
  geom_line(alpha = 0.3) +
  geom_smooth(method = "loess", se = FALSE, color = "firebrick") +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  theme_bw() +
  labs(title = "Unemployment with LOESS Smoother",
       x = "Date", y = "Unemployed (thousands)")

library(patchwork)
p2 <- p2a / p2b
ggsave("figures/unemployment_smoothed.png", p2, width = 8, height = 8, dpi = 300)

p3 <- ggplot(econ, aes(x = date, y = unemploy)) +
  geom_rect(data = pres,
            aes(xmin = start, xmax = end, fill = party),
            ymin = -Inf, ymax = Inf,
            alpha = 0.2, inherit.aes = FALSE) +
  geom_line() +
  scale_fill_manual(values = c(Democratic = "blue", Republican = "red")) +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  theme_bw() +
  labs(title = "US Unemployment by Presidential Term",
       x = "Date", y = "Unemployed (thousands)", fill = "Party") + 
  theme(legend.position = "bottom",
        legend.title = element_blank())

ggsave("figures/unemployment_presidents.png", p3, width = 9, height = 5, dpi = 300)

gap_sub <- gap %>%
  filter(country %in% c("United States", "China", "Germany", "Brazil"))

p4 <- ggplot(gap_sub, aes(x = year, y = gdpPercap)) +
  geom_line() +
  geom_point(size = 1.5) +
  facet_wrap(~ country, scales = "free_y") +
  theme_bw() +
  labs(title = "GDP per Capita Over Time",
       x = "Year", y = "GDP per Capita (USD)")

ggsave("figures/gdp_faceted.png", p4, width = 9, height = 6, dpi = 300)

recession <- data.frame(xmin = as.Date("2007-12-01"),
                        xmax = as.Date("2009-06-01"))

p5 <- ggplot(econ, aes(x = date, y = psavert)) +
  geom_rect(data = recession,
            aes(xmin = xmin, xmax = xmax),
            ymin = -Inf, ymax = Inf,
            fill = "gray70", alpha = 0.5, inherit.aes = FALSE) +
  geom_line(alpha = 0.4) +
  geom_smooth(method = "loess", se = TRUE, color = "darkred"") +
  scale_x_date(date_breaks = "5 years", date_labels = "%Y") +
  theme_bw() +
  labs(title = "Personal Savings Rate with Great Recession",
       x = "Date", y = "Savings Rate (%)")

ggsave("figures/savings_recession.png", p5, width = 8, height = 5, dpi = 300)
