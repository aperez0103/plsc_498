# ============================================================
# PLSC 498 — Week 11 Problem Set: Scatterplots and Association
# ============================================================

# ---- Load libraries ----
library(tidyverse)

# ---- Q1: Confirm dataset ----
getwd()
list.files()
list.files("data")

# ---- Q2: Load and clean basketball ----

# Step 1: Load RDS
basketball <- readRDS("data/basketball.rds")

# Step 2: Copy to basketball_clean
basketball_clean <- basketball

# Step 3: Convert character columns to numeric
cols_to_numeric <- c("AGE", "PLAYER_HEIGHT_INCHES", "PLAYER_WEIGHT",
                     "GP", "PTS", "REB", "AST", "NET_RATING",
                     "OREB_PCT", "DREB_PCT", "USG_PCT", "TS_PCT", "AST_PCT")

basketball_clean[cols_to_numeric] <- lapply(basketball_clean[cols_to_numeric], as.numeric)

# Step 4: Create draft_status indicator
basketball_clean$draft_status <- ifelse(basketball_clean$DRAFT_YEAR == "Undrafted",
                                        "Undrafted", "Drafted")

# Step 5: Inspect
dim(basketball_clean)
summary(basketball_clean[, c("AGE", "PTS", "USG_PCT")])

# ---- Create figures directory ----
dir.create("figures", showWarnings = FALSE)

# ============================================================
# Q3: USG_PCT vs PTS — basic scatterplot
# ============================================================

p1 <- ggplot(basketball_clean, aes(x = USG_PCT, y = PTS)) +
  geom_point(alpha = 0.4, size = 1.5) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Usage Percentage", y = "Points") +
  theme_classic()

ggsave("figures/usg_pts_scatter.png", p1, width = 7, height = 5, dpi = 300)

# ============================================================
# Q4: USG_PCT vs PTS — with linear smoother + SE
# ============================================================

p2 <- ggplot(basketball_clean, aes(x = USG_PCT, y = PTS)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Usage Percentage", y = "Points") +
  theme_classic()

ggsave("figures/usg_pts_lm_se.png", p2, width = 7, height = 5, dpi = 300)

# ============================================================
# Q5: USG_PCT vs TS_PCT — usage and scoring efficiency
# ============================================================

p3 <- ggplot(basketball_clean, aes(x = USG_PCT, y = TS_PCT)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Usage Percentage", y = "True Shooting Percentage") +
  theme_classic()

ggsave("figures/usg_ts_eff_lm_se.png", p3, width = 7, height = 5, dpi = 300)

# ============================================================
# Q6: AST vs AST_PCT — assists raw vs rate
# ============================================================

p4 <- ggplot(basketball_clean, aes(x = AST, y = AST_PCT)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Assists", y = "Assist Percentage") +
  theme_classic()

ggsave("figures/ast_astpct_lm_se.png", p4, width = 7, height = 5, dpi = 300)

# ============================================================
# Q7: PLAYER_WEIGHT vs REB — player size and rebounding
# ============================================================

p5 <- ggplot(basketball_clean, aes(x = PLAYER_WEIGHT, y = REB)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(x = "Player Weight (lbs)", y = "Rebounds") +
  theme_classic()

ggsave("figures/size_reb_scatter.png", p5, width = 7, height = 5, dpi = 300)

# ============================================================
# Q8: AGE vs TS_PCT — quadratic polynomial fit
# ============================================================

p6 <- ggplot(basketball_clean, aes(x = AGE, y = TS_PCT)) +
  geom_point(alpha = 0.4, size = 1.5) +
  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = TRUE) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Age", y = "True Shooting Percentage") +
  theme_classic()

ggsave("figures/age_ts_poly2_se.png", p6, width = 7, height = 5, dpi = 300)
