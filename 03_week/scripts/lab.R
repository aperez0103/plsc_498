## In-Class assignment script, creates properly scaled figure for overdispered Election Data

###setup----
library(dplyr)
library(scales)
library(ggplot2)

set.seed(123)

###Data----
df <- read.csv("data/HOUSE_precinct_general.csv")

head(df) #inspect data
names(df) #inspect data

##filter data 
df_keep <- df %>%
  filter(stage == "GEN") %>%
  filter(party_simplified == c("DEMOCRAT", "REPUBLICAN")) %>%
  filter(county_fips!="") #removes empty county info using county name

##county-level aggregation
county_df <- df_keep %>% 
  group_by(county_name) %>%
  summarize(
    dem_votes = sum(votes[party_simplified == "DEMOCRAT"], na.rm = TRUE),
    rep_votes = sum(votes[party_simplified == "REPUBLICAN"], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    county_total_votes = dem_votes + rep_votes, 
    rep_share = rep_votes / (dem_votes + rep_votes)
  ) %>%
  na.omit(county_df$rep_share) #drops any NaN values caused by 0 votes

##checks
#nrow(county_df)                 # number of unique counties
#summary(county_df$dem_votes)    #summary by dem_votes     
#summary(county_df$rep_votes)    #summary by rep_votes
#range(county_df$rep_share)      #range by rep_share, should be between 0 & 1

###Plots----
##unscaled plot 
plot_raw <- ggplot(county_df, aes(county_total_votes, rep_share, color = rep_share)) +
  geom_point(size = 3) +
  scale_color_continuous(palette = c("blue", "grey", "red")) +
  theme_bw() + 
  ylab("Republican Share of Votes") + 
  xlab("Total County Votes") +
  scale_y_continuous(labels = scales::label_percent()) + #display y-axis scale as percentages
  scale_x_continuous(labels = scales::comma) + #display x-axis scale using commas
  ggtitle("Figure 1: Republican Share of County Votes") + 
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) #centers title with plot

ggsave("figures/plot_raw.png", plot = plot_raw, scale = 1) #scale for readability 

##scaled plot (log)
plot_scaled <- ggplot(county_df, aes(county_total_votes, rep_share, color = rep_share)) +
  geom_point(size = 3) +
  scale_color_continuous(palette = c("blue", "grey", "red")) +
  theme_bw() + 
  ylab("Republican Share of Votes") + 
  xlab("Total County Votes\n(log10 Scaled)") +
  scale_y_continuous(labels = scales::label_percent()) + #display y-axis scale as percentages
  scale_x_log10(labels = scales::comma) + #log scaled x-axis using commas
  ggtitle("Figure 2: Republican Share of County Votes (Scaled)") + 
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5)) #centers title with plot

ggsave("figures/plot_scaled.png", plot = plot_scaled, scale = 1) #scale for readability 


