# ----------------------------------
# Script name: lab13.R
# Purpose: PLSC 498 In-Class Problem Set - Mapping Social Phenomena with US Election Data
# ----------------------------------

#setup----
library(ggplot2)
library(tidyr)
library(dplyr)
library(maps)
library(patchwork)

#data----
#get map boundary data
us <- map_data("state")

#build data attribute data
state_data <- data.frame(
  region = tolower(state.name),
  as.data.frame(state.x77)
)

#inspection
dim(us)
dim(state_data)
head(state_data)

state_data$region %in% us$region #map_data only includes contiguous USA


#Choropleth 1: Murder Rate----

#Merge data
us_merged <- us %>% 
  left_join(state_data, by = "region")

fig1 <- ggplot(us_merged, aes(x = long, y = lat, group = group, fill = Murder)) +
  geom_polygon(color = "black", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_viridis_c(name = "Murder Rates",
                       guide = guide_colorbar(title.position = "top",
                                              title.hjust = 0.5)) +
  theme_void()  +
  ggtitle("Figure 1: Muder Rates by State") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
       legend.position = "bottom",
       legend.direction = "horizontal",
       legend.title = element_text(face ="bold"),
       legend.key.width = unit(2, "cm"),
       legend.key.height = unit(0.4, "cm"))

ggsave("figures/murder_rate_map.png", fig1, width = 7, height = 4)

##Choropleth 2: Life expectancy ----
state_data <- state_data %>%
  mutate(life_dev = Life.Exp - mean(Life.Exp))

#merge data
us_merged <- us %>% left_join(state_data, by = "region")

fig2 <- ggplot(us_merged, aes(x = long, y = lat, group = group,
                              fill = life_dev)) +
  geom_polygon(color = "black", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_gradient2(low = "darkred", mid = "white",
                       high = "darkgreen", midpoint = 0,
                       name = "Deviation (in Years)", 
                       guide = guide_colorbar(title.position = "top",
                                                                                                       title.hjust = 0.5)) +
  theme_void() +
  ggtitle("Figure 2: Deviation from National Average Life Expectancy by State") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.title = element_text(face ="bold"),
        legend.key.width = unit(2, "cm"),
        legend.key.height = unit(0.4, "cm"))

ggsave("figures/life_exp_diverging.png", fig2, width = 7, height = 4)

## Choropleth 3: Binned variables
#determining bin lengths
#summary(state_data$HS.Grad)
state_data <- state_data %>%
  mutate(grad_cat = cut(HS.Grad,
                        breaks = c(0, 30, 40, 50, 60, 70, 100),
                        labels = c("< 30%", "30% - 40%", "40% - 50%", "50% - 60%", "60% - 70%", "70% - 100%")))

#merge data
us_merged <- us %>% left_join(state_data, by = "region")

fig3 <- ggplot(us_merged, aes(x = long, y = lat, group = group,
                              fill = grad_cat)) +
  geom_polygon(color = "black", linewidth = 0.3) +
  coord_quickmap() +
  scale_fill_brewer(palette = "YlGnBu", 
                    name = "Graduation Rates",
                    guide = guide_legend(
                      title.position = "top",
                      title.hjust = 0.5),
                    na.translate = F) +
  theme_void() +
  ggtitle("Figure 3: High School Graduation Rates by State") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.title = element_text(face ="bold"),
        legend.key.width = unit(2, "cm"),
        legend.key.height = unit(0.4, "cm"),
        legend.text.position = "bottom")

ggsave("figures/hs_grad_binned.png", fig3, width = 7, height = 4)

## Map vs dot plot comparison

#murder choropleth
fig1 

#dot plots showing top 20 states by murder rate
top_20 <- state_data %>%
  arrange(desc(Murder)) %>%
  slice_head(n = 20) %>%
  mutate(region = reorder(region, Murder))

fig4 <- ggplot(top_20, aes(x = Murder, y = region)) +
  geom_point(size = 2.5) +
  theme_classic() +
  theme(title = element_text(face ="bold")) +
  labs(x = "Murder Rates", y = NULL) +
  scale_y_discrete(labels = tools::toTitleCase) +
  ggtitle("Figure 4 Top 20 States With Higest Murder Rates")

ggsave("figures/murder_dotplot.png", fig4, width = 5, height = 7)

fig4_comp <- fig1 | fig4 #both plots side by side 

ggsave("figures/murder_dot_choro_comp.png", fig4_comp, width = 10, height = 7)
