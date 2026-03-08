# ----------------------------------
# Script name: midterm.R
# Purpose: PLSC 498 Midterm - Visualizing War, Regime Type, Distance, and Trade 
# ----------------------------------

##setup----
library(dplyr)
library(scales)
library(ggplot2)
library(tidyr)
library(viridis)


##data tidying & manipulation ----
#load data
df <- readRDS("conflict_data.rds")

#brief glimpse at data
head(df)
names(df)

#year-level (system-year)  df for wars per year summaries - base df

df_yl <- df %>%
  filter(!is.na(cowinterongoing),
         cowinterongoing ==1) %>%
  group_by(year) %>%
  summarise(
    `totalWars` = sum(cowinterongoing==1),
    `totalDem` = sum(polity21 =="Democracy" & polity22 =="Democracy"),#create columns to differentiate government types (polity), sum each regime type by year
    `totalDem.Au` = sum(polity21 == "Democracy" & polity22 == "Autocracy") + sum(polity21 == "Autocracy" & polity22 == "Democracy"),
    `totalDem.An` = sum(polity21 == "Democracy" & polity22 == "Anocracy") + sum(polity21 == "Anocracy" & polity22 == "Democracy"), 
    `totalAu` = sum(polity21 == "Autocracy" & polity22 == "Autocracy"),
    `totalAu.An` = sum(polity21 == "Autocracy" & polity22 == "Anocracy") + sum(polity21 == "Anocracy" & polity22 == "Autocracy"),
    `totalAn` = sum(polity21 == "Anocracy" & polity22 == "Anocracy") 
    ) %>%
  mutate(
    totalMixed = totalDem.Au + totalDem.An + totalAu.An
  )

#dyad
df_dyad <- df %>%
  filter(!is.na(cowinterongoing),
         cowinterongoing==1,
         !is.na(cowinteronset),
         !is.na(trade),
         !is.na(capdist)
         ) 
df_dyad$cowinteronset <- factor(df_dyad$cowinteronset, labels = c("No", "Yes"))


##Viz 1: Total number of wars per year----
df_yl1 <- df_yl %>%
  select(year, totalDem, totalWars) %>%
  pivot_longer(-year, names_to = "type", values_to = "count")

totalWarviz <- ggplot(df_yl1, aes(year, count, color = type)) +
  geom_line()+
  theme_dark() +
  scale_color_viridis_d(name = "Dyad Relationship Type", labels = c("Democracy-Democracy", "All Wars")) +
  xlab("Year") +
  ylab("Total War Counts") +
  ggtitle("Figure 1: Total Counts of Wars by Year") 

ggsave("figures/warsbyyears.png", totalWarviz, width = 10, height = 7)

##Viz 2: Comparing war patterns across dyad-regime types----
df_yl2 <- df_yl %>% 
  select(year, totalDem, totalMixed, totalAu) %>%
  pivot_longer(cols = c(totalDem, totalMixed, totalAu), names_to = "dyad_type", values_to = "war_count")

compPatterns <- ggplot(df_yl2, aes(year, war_count, color = dyad_type)) + 
  geom_line(linewidth = 0.75) +
  scale_color_viridis_d(name = "Dyad Relationship Type", labels = c("Autocracy-Autocracy", "Democracy-Democracy", "Mixed Regime Dyads")) +
  theme_dark() +
  xlab("Dyadic Regime Type") +
  ylab("Number of Wars")+
  ggtitle("Figure 2: War Comparisons", subtitle = "By Dyadic Regime Types")

ggsave("figures/warcompregimes.png", compPatterns, width = 10, height = 7)

##Viz 3: War Dist. Relationship ----
warDist <- ggplot(df_dyad, aes(x=capdist, fill=factor(cowinteronset))) +
  geom_histogram(binwidth = 2*IQR(df_dyad$capdist)*(nrow(df_dyad))^(-1/3), position = position_dodge2(width = 1), width = 0.7)+
  theme_dark()+
  scale_fill_viridis_d(name = "War Onset?")+
  ylab("Frequency") +
  xlab("Distance Between Country Capitals") + 
  ggtitle("Figure 3:War - Distance Relationship")


ggsave("figures/wardistrel.png", warDist, width = 10, height = 7)

## Viz 4: Trade, Dist. and conflict----
tdcviz <- ggplot(df_dyad, aes(x =capdist, y = trade, color = factor(cowinteronset))) +
  geom_point(alpha= 0.6) +
  theme_dark()+
  scale_color_viridis_d(name = "War Onset?")+
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma)+
  ylim(0, 1000)+
  xlab("Distance Between Country Capitals") +
  ylab("Dyadic Trade Volume") +
  ggtitle("Figure 4.0: Trade Volume, Country Distance and War Onset")
  

ggsave("figures/tradedistwar.png", tdcviz, width = 10, height = 7)

##Raw vs transformed----
#raw plot
tdcviz_raw <- ggplot(df_dyad, aes(x =capdist, y = trade, color = factor(cowinteronset))) +
  geom_point(alpha= 0.6) +
  theme_dark()+
  scale_color_viridis_d(name = "War Onset?")+
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma) +
  xlab("Distance Between Country Capitals") +
  ylab("Dyadic Trade Volume") +
  ggtitle("Figure 4.1: Trade Volume, Country Distance and War Onset (Raw Plot)")

ggsave("figures/tradedistwar_raw.png", tdcviz_raw, width = 10, height = 7)



#scaled
tdcviz_scaled <- ggplot(df_dyad, aes(x =capdist, y = log(1+trade), color = factor(cowinteronset))) + #log(1+y) to avoid -inf values
  geom_point(alpha= 0.6) +
  theme_dark()+
  scale_color_viridis_d(name = "War Onset?")+
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(labels = scales::comma) +
  xlab("Distance Between Country Capitals") +
  ylab("Dyadic Trade Volume \n log(1+y)") +
  ggtitle("Figure 4.2: Trade Volume, Country Distance and War Onset (Scaled Plot)")


ggsave("figures/tradedistwar_scaled.png", tdcviz_scaled, width = 10, height = 7)

##bad viz

bad <- ggplot(df_dyad, aes(y = capdist, x = factor(cowinteronset))) +
  geom_boxplot() +
  geom_jitter() +
  ylab("Distance Bewteen Countries") +
  ggtitle("Figure 5: Comparing Onset of Wars by Country Distance")

ggsave("figures/bad_boxplot.png", bad, width = 10, height = 7)
