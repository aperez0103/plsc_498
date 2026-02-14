# ----------------------------------
# Script name: lab4.R
# Purpose: PLSC 498 Lab 5 - Movie Data exploration w/ Distribution and Color
# ----------------------------------

##setup----
library(ggplot2)
library(dplyr)
library(scales)
#data
df <- read.csv("data/IMDB_Movies_Data.csv")

#structure checks
head(df)
names(df)

summary(df) #quick summary of df variables

#nrow(df)
#ncol(df)


##histograms----

#histograms w/o specific bins
budg_hist <- ggplot(df, aes(budget)) +     #budget hist.
  geom_histogram() + 
  theme_bw() +
  xlab("Budget ($ USD)") +
  ylab("Frequency") +
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M"))

ggsave("figures/budget_hist.png", budg_hist, height = 6, width = 5)

rev_hist <- ggplot(df, aes(revenue)) +     #revenue hist.
  geom_histogram() + 
  theme_bw() +
  xlab("Revenue ($ USD)") +
  ylab("Frequency") +
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M"))

ggsave("figures/revenue_hist.png", rev_hist, height = 6, width = 5)


#histograms w/ specific bin sizes
budg_hist_bin <- ggplot(df, aes(budget)) +     #budget hist.
  geom_histogram(binwidth = 2*IQR(df$budget)*(nrow(df))^(-1/3)) + 
  theme_bw() +
  xlab("Budget ($ USD)") +
  ylab("Frequency") +
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M"))

ggsave("figures/budget_hist_binned.png", budg_hist_bin, height = 6, width = 5)

rev_hist_bin <- ggplot(df, aes(revenue)) +     #revenue hist.
  geom_histogram(binwidth = 2*IQR(df$revenue)*(nrow(df))^(-1/3)) + 
  theme_bw() +
  xlab("Revenue ($ USD)") +
  ylab("Frequency") +
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M"))

ggsave("figures/revenue_hist_binned.png", rev_hist_bin, height = 6, width = 5)


##top-grossing directors & revenue----
top_directors <- df %>%
  group_by(director) %>%
  summarize(total_revenue = sum(revenue)) %>%
  arrange(desc(total_revenue)) %>%
  slice(1:3)

df_top <- df %>%
  filter(director %in% top_directors$director)

#boxplot code below, not intuitive for single movie comparisons

#boxplot distribution 
#ggplot(df_top, aes(director, revenue)) +
#  geom_boxplot() +
#  theme_classic() +
#  xlab("Directors") +
#  ylab("Revenue ($ USD)") +
#  ggtitle("Distribution of Revenue by Director")

rev_by_dir_viz <- ggplot(df_top, aes(x = revenue, y = reorder(director, revenue))) + #show revenue by director in comparison to each other - top 3 grossing directors 
  geom_col() + 
  theme_bw() +
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  labs(x = "Revenue", y = "")

ggsave("figures/revenue_by_director.png", rev_by_dir_viz, height = 4, width = 8)

## scatter plot w/ size & color encodings----
rev_by_budg_plot <- ggplot(df, aes(budget, revenue, size = popularity, color = original_language)) +
  geom_point() +
  theme_classic() +
  scale_colour_brewer(palette = "Set2") +
  scale_x_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  scale_y_continuous(labels = scales::label_dollar(scale = 1e-6, suffix = "M")) + 
  xlab("Movie Budget ($ USD)") +
  ylab("Revenue ($ USD)") 

ggsave("figures/budget_revenue_scatter.png", rev_by_budg_plot, height = 6, width = 9)