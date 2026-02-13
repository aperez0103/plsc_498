## --------------------- ##
## Set up movie analysis ##
## --------------------- ##

library(plyr)
library(dplyr)
library(ggplot2)
library(scales)

df <- read.csv("05_week/data/IMDB_Movies_Data.csv")


## Check dimensions
dim(df)

bin_width_budget <- 2 * IQR(df$budget) * nrow(df)^(-1/3)
ggplot(df, aes(x = budget)) + 
  geom_histogram(binwidth = bin_width_budget) + 
  theme_bw() + 
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  labs(x = "Movie Budget", y = "Count")

bin_width_revenue <- 2 * IQR(df$revenue[df$revenue > 0]) * length(df$revenue > 0)^(-1/3)

df %>% 
  filter(revenue > 0) %>% 
ggplot(., aes(x = revenue)) + 
  geom_histogram(binwidth = bin_width_revenue) + 
  theme_bw() + 
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  labs(x = "Movie Revenue", y = "Count")


top_directors <- df %>% 
  plyr::ddply(~director,
              summarize,
              total_revenue = sum(revenue)) %>% 
  arrange(-total_revenue) %>% 
  slice(1:3)

df_top <- df %>% 
  filter(director %in% top_directors$director) %>% 
  mutate(director = gsub(" ", "\n", director))


ggplot(df_top, aes(x = revenue, y = reorder(director, revenue))) + 
  geom_col() + 
  theme_bw() + 
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  labs(x = "Revenue", y = "") + 
  theme(axis.text.y = element_text(size = 12),
        axis.text.x = element_text(size = 11),
        plot.margin = margin(t = 5.5, r = 20, b = 5.5, l = 5.5))


ggplot(df, aes(x = budget + 1, y = revenue + 1, col = original_language, size = popularity)) + 
  geom_point() + 
  scale_colour_brewer(palette = "Set2") + 
  theme_bw() +  
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  scale_y_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  labs(x = "Budget", y = "Revenue", col = "Language", size = "Popularity") + 
  theme(lengend.position = "bottom")
