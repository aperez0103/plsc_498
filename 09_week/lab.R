# ----------------------------------
# Script name: lab.R
# Purpose: PLSC 498 In-Class Problem Set - Totals vs Proportions in Politcal and Health Data
# ----------------------------------

##setup----
library(ggplot2)
library(tidytext)

## Q2 - Load & Inspect Data----
# Step 1: load the RDS/CSV file into df
# Step 2: check dimensions and column names
# Step 3: summarize vote and death columns

df <- readRDS("data/state_df.rds") #step 1

dim(df)#step 2
names(df)
summary(df[,c("totalvotes","covid_deaths_to_2020_11_07")]) #step 3

## Q3 - Create Total Illness Death Variable----
# Step 1: create total_illness_deaths column (sum of two death cols)
# Step 2: compute national total with sum()
# Step 3: find state-level min and max

df$total_illness_deaths <- df$covid_deaths_to_2020_11_07 + df$pneumonia_deaths_to_2020_11_07 #step 1

nat_total <- sum(df$total_illness_deaths, na.rm = T) #step 2, calculate total death count

state_min_max <- df[order(df$total_illness_deaths)[c(1,51)],] #step 3
state_min_max[1,c("state", "total_illness_deaths")] #min
state_min_max[2,c("state", "total_illness_deaths")] #max

##Q4 - Bar plot of total illness deaths by state----
# Step 1: reorder states by total_illness_deaths
# Step 2: build bar plot with geom_col()
# Step 3: add title, axis labels (note: totals, not proportions)
# Step 4: save with ggsave()

df <- df %>% mutate(state = fct_reorder(state, total_illness_deaths)) #step 1

#barplot
bar_totals <- ggplot(df, aes(total_illness_deaths, state)) + #call dataframe and x-y variables
  geom_col(fill = "skyblue", width = .85) + #step 2, create bar plot
  scale_x_continuous(labels = scales::comma_format()) + # show x-axis with commas for values requiring them
  xlab("Total Illness Deaths by State (Counts)") + #step 3, labels lines 45-47
  ylab("") +
  ggtitle("Total Illness Deaths by State") +
  theme_minimal() + #change plot background
  theme(plot.title = element_text(hjust = 0.5), margins = margin(t = 0.25, b = 0.25, l = 0.25, r = 0.5, unit = "in")) #center title text; set custom margins

ggsave("figures/total_illness_deaths_by_state.png", bar_totals, width = 6, height = 10) #step 4

## Q5 - Trump vs Biden proportions----
# Step 1: create winner variable based on biden_share vs trump_share
# Step 2: group by winner and compute proportion of total illness deaths
# Step 3: build bar plot with proportions (geom_col)
# Step 4: apply red/blue color scale
# Step 5: add labels clarifying these are proportions

df$winner <- ifelse(df$biden_share > df$trump_share, "Biden", "Trump") #step 1, create winner variable

df_prop <- df %>%
  group_by(winner) %>% #step 2, group by winner
  summarise(
    total_deaths = sum(total_illness_deaths, na.rm = T)#sum total deaths by winner
  ) %>%
  mutate(
    proportion = total_deaths / sum(total_deaths) #calculate proportion of total illness deaths by winner
  )

#barplot
trump_biden_bar <- ggplot(df_prop, aes(winner, proportion, fill = winner)) + #call dataframe and x-y variables
  geom_col(width = 0.6) + #step 3, create bar plot
  scale_fill_manual(values = c("Biden"="blue", "Trump" = "red")) + #step 4, assign fill colors for each candidate
  theme_minimal() + #set background theme
  scale_y_continuous(labels = scales::percent_format()) + #display y-axis values as percentages
  labs( #labels
    y = "Proportion of Total Illness Deaths", #step 5
    x = "Winning Candidate", 
    fill = "Candidate"
  ) +
  ggtitle(stringr::str_wrap("Proportion of Total Illness Deaths by Presidential Candidate", width = 40)) + #plot title
  theme(plot.title = element_text(hjust = 0.5)) #center title text

ggsave("figures/illness_deaths_by_winner_proportions.png", trump_biden_bar, width = 5, height = 7)

# Q6 - Deaths by State, Grouped (Faceted) by Winner----
# Step 1: reorder states by total_illness_deaths within each facet
# Step 2: build bar plot with geom_col()
# Step 3: facet by winner using facet_wrap() or facet_grid()
# Step 4: use scales = "free_y" so each panel has its own state list
# Step 5: add appropriate colors, title, axis labels

df_fac <- df %>% #step 1
  mutate(
    state = reorder_within(state, total_illness_deaths, winner)
  )

bar_plot_facet <- ggplot(df_fac, aes(total_illness_deaths, state, fill = winner)) + #call dataframe and x-y variables
  geom_col(width = 0.6) + #step 2, create bar plot
  facet_wrap(~winner, scales = "free_y") + #step 3 & 4, format facets
  scale_y_reordered() + #clean up y-axis
  scale_x_continuous(labels = scales::comma_format()) + #display x-axis labels as comma values
  scale_fill_manual(values = c("Biden"="blue", "Trump" = "red")) + #step 5, color encoding
  labs( #labels
    x = "Total Illness Deaths (Counts)", 
    y = ""
  ) +
  ggtitle("Total Illness Deaths by State, Faceted by 2020 Presidential Winner") + #title
  guides(fill = "none") + #remove legend
  theme_minimal() + #set background 
  theme(plot.title = element_text(hjust = 0.5), margins = margin(t = 0.25, b = 0.25, l = 0.25, r = 0.5, unit = "in")) #cetner title text; set custom margins

ggsave("figures/illness_deaths_faceted_by_winner.png", height = 10, width = 8)
