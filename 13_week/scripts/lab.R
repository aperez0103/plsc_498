library(ggplot2)
library(dplyr)
library(maps)
library(scales)

set.seed(123)

# Q1: Load data and prepare for joining
us <- map_data("state")

state_data <- data.frame(
  region = tolower(state.name),
  as.data.frame(state.x77)
)

dim(us)
dim(state_data)
head(state_data)
summary(state_data$Murder)
summary(state_data$Life.Exp)

# Q2: Choropleth — murder rate (sequential scale)
us_merged <- us %>%
  left_join(state_data, by = "region")

p1 <- ggplot(us_merged, aes(x = long, y = lat, group = group, fill = Murder)) +
  geom_polygon(color = "white", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_viridis_c(option = "C", name = "Murder rate\n(per 100k)") +
  theme_void() +
  labs(title = "Murder Rate by State")

ggsave("figures/murder_rate_map.png", p1, width = 8, height = 5, dpi = 300)

# Q3: Choropleth — life expectancy (diverging scale)
state_data <- state_data %>%
  mutate(life_dev = Life.Exp - mean(Life.Exp))

us_merged <- us %>%
  left_join(state_data, by = "region")

p2 <- ggplot(us_merged, aes(x = long, y = lat, group = group, fill = life_dev)) +
  geom_polygon(color = "white", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_gradient2(low = "red", mid = "white", high = "blue",
                       midpoint = 0, name = "Deviation\nfrom mean (yrs)") +
  theme_void() +
  labs(title = "Life Expectancy: Deviation from National Mean")

ggsave("figures/life_exp_diverging.png", p2, width = 8, height = 5, dpi = 300)

# Q4: Choropleth — HS graduation rate (binned/categorical scale)
state_data <- state_data %>%
  mutate(grad_cat = cut(HS.Grad,
    breaks = c(0, 45, 55, 65, 100),
    labels = c("Low (<45%)", "Medium-Low (45-55%)",
               "Medium-High (55-65%)", "High (>65%)")))

us_merged <- us %>%
  left_join(state_data, by = "region")

p3 <- ggplot(us_merged, aes(x = long, y = lat, group = group, fill = grad_cat)) +
  geom_polygon(color = "white", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_brewer(palette = "YlOrRd", name = "HS Graduation") +
  theme_void() +
  labs(title = "High School Graduation Rate by State (Binned)")

ggsave("figures/hs_grad_binned.png", p3, width = 8, height = 5, dpi = 300)

# Q5: Map vs dot plot comparison
top_20 <- state_data %>%
  arrange(desc(Murder)) %>%
  slice_head(n = 20) %>%
  mutate(region = reorder(region, Murder))

p4 <- ggplot(top_20, aes(x = Murder, y = region)) +
  geom_point(size = 2.5) +
  theme_classic() +
  labs(x = "Murder Rate (per 100k)", y = NULL,
       title = "Top 20 States by Murder Rate")

ggsave("figures/murder_dotplot.png", p4, width = 7, height = 6, dpi = 300)

# Optional extension: USArrests choropleth
arrests <- USArrests %>%
  mutate(region = tolower(rownames(USArrests)))

us_arrests <- us %>%
  left_join(arrests, by = "region")

p5 <- ggplot(us_arrests, aes(x = long, y = lat, group = group, fill = Assault)) +
  geom_polygon(color = "white", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_viridis_c(option = "C", name = "Assault arrests\n(per 100k)") +
  theme_void() +
  labs(title = "Assault Arrests by State")

ggsave("figures/assault_map.png", p5, width = 8, height = 5, dpi = 300)
