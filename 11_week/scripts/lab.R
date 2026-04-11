# ----------------------------------
# Script name: lab.R
# Purpose: PLSC 498 In-Class Problem Set - Scatterplots and Associations
# ----------------------------------

##setup----
library(ggplot2)
library(dplyr)
##Data----

# Step 1: load the RDS/CSV into basketball
# Step 2: copy to basketball_clean
# Step 3: convert character columns to numeric with as.numeric()
# Step 4: create draft_status indicator from DRAFT_YEAR
# Step 5: inspect with dim(), summary()

basketball <- readRDS("data/basketball.rds") #step 1
dim(basketball)
summary(basketball)

basketball_clean <- basketball %>%#step 2
  mutate(
    across(
      c("AGE", "PLAYER_HEIGHT_INCHES", "PLAYER_WEIGHT", "GP", "PTS", "REB", "AST", "NET_RATING", "OREB_PCT", "DREB_PCT", "USG_PCT", "TS_PCT", "AST_PCT"), #step 3
      as.numeric
      )
    )%>%
  na.omit()

basketball_clean$draft_status <- ifelse( #step 4
  basketball_clean$DRAFT_YEAR != "Undrafted",
  "Drafted",
  basketball_clean$DRAFT_YEAR
) 

dim(basketball_clean) #step 5
summary(basketball_clean)

##Scatterplot 1: usage and scoring----
# Step 1: set up ggplot with USG_PCT on x, PTS on y
# Step 2: add geom_point() with alpha for overplotting
# Step 3: format x-axis as percent if applicable
# Step 4: apply theme_classic() and labels
# Step 5: save with ggsave()

scat1base <- ggplot(basketball_clean, aes(x = USG_PCT, y = PTS)) + #step 1
  geom_point(alpha = 0.5, size = 1) + #step 2
  scale_x_continuous(labels = scales::percent_format()) + #step 3
  theme_classic() +  #step 4
  ylab("Points Scored") +
  xlab("Usage Percent - Rate of Player Utility on Offense") 
scat1 <- scat1base +
  ggtitle("Figure 1: Points Scored by Player Usage Percent on Offense") 

ggsave("figures/usg_pts_scatter.png", scat1, height = 8, width = 6)

##Scatterplot 2 - add linear smother w/ SE----
# Step 1: start from the previous scatter plot
# Step 2: add geom_smooth(method = "lm", se = TRUE)
# Step 3: keep geom_point() visible underneath
# Step 4: save with ggsave()

scat2 <- scat1base + #step 1 & 3
  geom_smooth(method = "lm", se = T) + #step 2 
  ggtitle("Figure 2: Points scored by player Usage Perent on Offense")

ggsave("figures/usg_pts_lm_se.png", scat2, height = 8, width = 6) #step 4

##Scatterplot 3 - Usage and scoring efficiency----
# Step 1: set up ggplot with USG_PCT on x, TS_PCT on y
# Step 2: add geom_point() with alpha for overplotting
# Step 3: format both axes as percent
# Step 4: add geom_smooth(method = "lm", se = TRUE)
# Step 5: apply theme_classic() and save

scat3 <- ggplot(basketball_clean, aes(x = USG_PCT, y = TS_PCT)) + #step 1
  geom_point(alpha = 0.5, size = 1) + # step 2
  scale_x_continuous(labels = scales::percent_format()) + #step 3
  scale_y_continuous(labels = scales::percent_format()) +
  geom_smooth(method = "lm", se = T) + # step 4
  xlab("Usage Percent - Rate of Player Utility on Offense") +
  ylab("True Shooting Percentage") +
  ggtitle("Figure 3: Usage and Score Efficiency") +
  theme_classic() #step 5 
  
ggsave("figures/usg_ts_eff_lm_se.png", scat3, height = 8, width = 6)

##Scatterplot 4 - Assists (raw vs rate)----
# Step 1: set up ggplot with AST on x, AST_PCT on y
# Step 2: add geom_point() with alpha for overplotting
# Step 3: format AST_PCT axis as percent
# Step 4: add geom_smooth(method = "lm", se = TRUE)
# Step 5: apply theme_classic() and save

scat4 <- ggplot(basketball_clean, aes(x = AST, y = AST_PCT)) + #step 1
  geom_point(alpha = 0.5, size = 1) + # step 2
  scale_y_continuous(labels = scales::percent_format()) + #step 3
  geom_smooth(method = "lm", se = T) + # step 4
  xlab("Assists") +
  ylab("Assists (as percentage)") +
  ggtitle("Figure 4: Assists - Raw Values vs Rates") +
  theme_classic() #step 5

ggsave("figures/ast_astpct_lm_se.png", scat4, height = 8, width = 6)

##Scatterplot 5 - PLayer size and rebounding ----
# Step 1: set up ggplot with PLAYER_WEIGHT on x, REB on y
# Step 2: add geom_point() with alpha for overplotting
# Step 3: add geom_smooth(method = "lm", se = TRUE)
# Step 4: apply theme_classic() and labels
# Step 5: save with ggsave()

scat5 <- ggplot(basketball_clean, aes(x = PLAYER_WEIGHT, y = REB)) + #step 1
  geom_point(alpha = 0.5, size = 1) + # step 2
  geom_smooth(method = "lm", se = T) + # step 3
  xlab("Player Weight") + #step 4
  ylab("Rebounds") +
  ggtitle("Figure 5: Relationship Between Player Weight and Rebounds") +
  theme_classic() 

ggsave("figures/size_reb_scatter.png", scat5, height = 8, width = 6) #step 5

## Scatterplot 6 - Age and scoring efficiency
# Step 1: set up ggplot with AGE on x, TS_PCT on y
# Step 2: add geom_point() with alpha for overplotting
# Step 3: format TS_PCT axis as percent
# Step 4: add geom_smooth(method = "lm",
# formula = y ~ poly(x, 2), se = TRUE)
# Step 5: apply theme_classic() and save

scat6 <- ggplot(basketball_clean, aes(x = AGE, y = TS_PCT)) + #step 1
  geom_point(alpha = 0.25, size = 1) + # step 2
  scale_y_continuous(labels = scales::percent_format()) + #step 3
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = T) + # step 4
  xlab("Age") + 
  ylab("True Shooting Percentage") +
  ggtitle("Figure 6: Relationsihp Between Age and Scoring Effeciency") +
  theme_classic() #step 5

ggsave("figures/age_ts_poly2_se.png", scat6, height = 8, width = 6) #step 5
