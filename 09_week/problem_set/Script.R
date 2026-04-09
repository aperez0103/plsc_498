###############################################################################
# answer_key.R
# Week 9 Problem Set: Totals vs Proportions in Political and Health Data
# PLSC 498 — Answer Key
###############################################################################

library(tidyverse)

# ─── Q1: Setup ───────────────────────────────────────────────────────────────

# Confirm working directory and data
getwd()
dir.create("scripts", showWarnings = FALSE)
dir.create("outputs", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
list.files("data")

# ─── Q2: Load and inspect ────────────────────────────────────────────────────

# Step 1: load the RDS file into df
# Step 2: check dimensions and column names
# Step 3: summarize vote and death columns

df <- readRDS("09_week/data/state_df.rds")

dim(df)
names(df)
summary(df[, c("totalvotes", "covid_deaths_to_2020_11_07")])

# ─── Q3: Create total illness death variable ─────────────────────────────────

# Step 1: create total_illness_deaths column (sum of two death cols)
# Step 2: compute national total with sum()
# Step 3: find state-level min and max

df <- df |>
  mutate(total_illness_deaths = covid_deaths_to_2020_11_07 + pneumonia_deaths_to_2020_11_07)

national_total <- sum(df$total_illness_deaths, na.rm = TRUE)
state_min <- df |> slice_min(total_illness_deaths, n = 1)
state_max <- df |> slice_max(total_illness_deaths, n = 1)

cat("National total illness deaths:", national_total, "\n")
cat("Minimum:", state_min$state, "-", state_min$total_illness_deaths, "\n")
cat("Maximum:", state_max$state, "-", state_max$total_illness_deaths, "\n")

# ─── Q4: Bar plot of total illness deaths by state ───────────────────────────

# Step 1: reorder states by total_illness_deaths
# Step 2: build bar plot with geom_col()
# Step 3: flip coordinates for readability
# Step 4: add title, axis labels (note: totals, not proportions)
# Step 5: save with ggsave()

p_totals <- df |>
  mutate(state = fct_reorder(state, total_illness_deaths)) |>
  ggplot(aes(x = total_illness_deaths, y = state)) +
  geom_col(fill = "#4a7c91", width = 0.7) +
  scale_x_continuous(labels = scales::comma_format(), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "Total Illness Deaths by State (COVID + Pneumonia)",
    subtitle = "Cumulative through November 7, 2020 — shown as raw counts, not proportions",
    x = "Total Illness Deaths (count)",
    y = NULL
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 9),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 6.5)
  )

ggsave("figures/total_illness_deaths_by_state.png", p_totals,
       width = 8, height = 10, dpi = 300)

# ─── Q5: Proportions bar plot — Trump vs Biden ──────────────────────────────

# Step 1: create winner variable based on biden_share vs trump_share
# Step 2: group by winner and compute proportion of total illness deaths
# Step 3: build bar plot with proportions (geom_col)
# Step 4: apply red/blue color scale
# Step 5: add labels clarifying these are proportions

df <- df |>
  mutate(winner = if_else(biden_share > trump_share, "Biden", "Trump"))

winner_props <- df |>
  group_by(winner) |>
  summarise(
    total_deaths = sum(total_illness_deaths, na.rm = TRUE),
    n_states = n(),
    .groups = "drop"
  ) |>
  mutate(proportion = total_deaths / sum(total_deaths))

winner_colors <- c("Biden" = "#2166ac", "Trump" = "#b2182b")

p_proportions <- winner_props |>
  ggplot(aes(x = winner, y = proportion, fill = winner)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%\n(%s deaths)",
                                 proportion * 100,
                                 scales::comma(total_deaths))),
            vjust = -0.3, size = 3.8, fontface = "bold") +
  scale_fill_manual(values = winner_colors) +
  scale_y_continuous(labels = scales::percent_format(),
                     limits = c(0, max(winner_props$proportion) * 1.15),
                     expand = expansion(mult = c(0, 0))) +
  labs(
    title = "Proportion of Total Illness Deaths by 2020 Election Winner",
    subtitle = "Share of cumulative COVID + pneumonia deaths through Nov 7, 2020 — proportions, not raw counts",
    x = NULL,
    y = "Proportion of Total Illness Deaths"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 9),
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave("figures/illness_deaths_by_winner_proportion.png", p_proportions,
       width = 7, height = 6, dpi = 300)

# ─── Q6: Faceted bar plot — deaths by state, grouped by winner ───────────────

# Step 1: reorder states by total_illness_deaths within each facet
# Step 2: build bar plot with geom_col()
# Step 3: facet by winner using facet_wrap()
# Step 4: use scales = "free_y" so each panel has its own state list
# Step 5: add appropriate colors, title, axis labels
# Step 6: save with ggsave()

df_facet <- df |>
  mutate(state_po = tidytext::reorder_within(state_po, total_illness_deaths, winner))

p_faceted <- df_facet |>
  ggplot(aes(x = total_illness_deaths, y = state_po, fill = winner)) +
  geom_col(width = 0.7) +
  tidytext::scale_y_reordered() +
  facet_wrap(~ winner, scales = "free_y") +
  scale_fill_manual(values = winner_colors) +
  scale_x_continuous(labels = scales::comma_format(), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "Total Illness Deaths by State, Faceted by 2020 Election Winner",
    subtitle = "COVID + pneumonia deaths through Nov 7, 2020 — states ordered within each panel",
    x = "Total Illness Deaths (count)",
    y = NULL
  ) +
  theme_minimal(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 9),
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 6.5),
    strip.text = element_text(face = "bold", size = 11)
  )

ggsave("figures/illness_deaths_faceted_by_winner.png", p_faceted,
       width = 12, height = 10, dpi = 300)


df_by_illness <- df |>
  dplyr::select(c(state_po, winner, pneumonia_deaths_to_2020_11_07, covid_deaths_to_2020_11_07)) |>
  pivot_longer(cols = c(pneumonia_deaths_to_2020_11_07, covid_deaths_to_2020_11_07),
               names_to = "death_type",
               values_to = "deaths") |>
  mutate(death_type = ifelse(grepl("pneumonia", death_type), "Pneumonia", "COVID-19"))

covid_pct <- df$covid_deaths_to_2020_11_07/df$total_illness_deaths
state_po_covid  <- data.frame(
  state_po = df$state_po,
  covid_pct
) 

state_po_covid <- state_po_covid |> 
  arrange(
    covid_pct
  )
df_by_illness <- df_by_illness |> 
  as.data.frame(.) |> 
  mutate(state_po = factor(state_po, levels = unique(state_po_covid$state_po)))

p_illness_prop <- df_by_illness |>
  mutate(death_type = factor(death_type, levels = c("Pneumonia", "COVID-19"))) |>
  ggplot(aes(x = deaths, y = state_po, fill = death_type)) +
  geom_col(position = "fill") +
  tidytext::scale_y_reordered() +
  facet_wrap(~ winner, scales = "free_y") +
  scale_fill_manual(values = c("gold", "purple")) +
  scale_x_continuous(labels = scales::percent_format(), expand = expansion(mult = c(0, 0.05))) +
  labs(
    title = "Illness Deaths by State, Faceted by 2020 Election Winner",
    subtitle = "COVID and pneumonia deaths proportion through Nov 7, 2020 — states ordered within each panel",
    x = "Total Illness Deaths (proportion)",
    y = NULL
  ) +
  theme_classic(base_size = 10) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 9),
    legend.position = "bottom",
    legend.title = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 6.5),
    strip.text = element_text(face = "bold", size = 11)
  )


ggsave("figures/illness_death_type_faceted_by_winner.png", p_illness_prop,
       width = 12, height = 10, dpi = 300)