# Data Curation Script for Week 15: Interactive Visualization with R Shiny
# PLSC 498 - Visualizing Social Data
# Author: Jared Edgerton
#
# This script builds the four datasets used by the Shiny apps in this folder
# by pulling from data that already exists in previous week folders and from
# the Edgerton (2023, JCR) ISIS mobilization replication archive.
#
# Three American politics datasets + two international relations datasets:
#   1. senate_ideology.rds   -- AP -- from 04_week/data/Sall_members.csv
#   2. election_2020.rds     -- AP -- from 09_week/data/state_df.rds
#   3. state_crime.rds       -- AP -- from 13_week/data/us_arrests.rds +
#                                        13_week/data/state_data.rds
#   4. battle_deaths.rds     -- IR -- from 07_week/data/battle_deaths.rds
#   5. isis_mobilization.rds -- IR -- from Edgerton-2023-JCR replication data
#
# Run from the project root (the directory containing the *_week folders).

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
})

# Resolve paths relative to this script's location so it works from any cwd.
this_file <- tryCatch(
  rstudioapi::getSourceEditorContext()$path,
  error = function(e) NULL
)
if (is.null(this_file) || !nzchar(this_file)) {
  this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
}
if (is.null(this_file) || !nzchar(this_file)) {
  this_file <- "15_week/data/create_data.R"
}

out_dir  <- normalizePath(dirname(this_file), mustWork = FALSE)
proj_dir <- normalizePath(file.path(out_dir, "..", ".."), mustWork = FALSE)

cat("Project root:", proj_dir, "\n")
cat("Output dir:  ", out_dir, "\n")

if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ============================================================================
# 1. SENATE IDEOLOGY  (AP #1)  -- from 04_week/data/Sall_members.csv
# ============================================================================

cat("\n--- 1. Senate ideology (Sall_members) ---\n")

sall <- read.csv(file.path(proj_dir, "04_week", "data", "Sall_members.csv"),
                 stringsAsFactors = FALSE)

senate_data <- sall %>%
  filter(chamber == "Senate",
         congress >= 110,                         # recent congresses
         !is.na(nominate_dim1)) %>%
  mutate(
    party = case_when(
      party_code == 100 ~ "D",
      party_code == 200 ~ "R",
      TRUE              ~ "I"
    )
  ) %>%
  transmute(
    member_id = icpsr,
    name      = bioname,
    state     = state_abbrev,
    party,
    congress,
    dwnom1    = nominate_dim1,
    dwnom2    = nominate_dim2
  ) %>%
  distinct() %>%
  arrange(congress, state, desc(dwnom1))

cat("Senate ideology rows:", nrow(senate_data), "\n")
saveRDS(senate_data, file.path(out_dir, "senate_ideology.rds"))
write.csv(senate_data, file.path(out_dir, "senate_ideology.csv"),
          row.names = FALSE)

# ============================================================================
# 2. 2020 PRESIDENTIAL ELECTION  (AP #2)  -- from 09_week/data/state_df.rds
# ============================================================================

cat("\n--- 2. 2020 Presidential election (state_df) ---\n")

state_df <- readRDS(file.path(proj_dir, "09_week", "data", "state_df.rds"))

election_2020 <- state_df %>%
  transmute(
    state            = tools::toTitleCase(tolower(state)),
    state_po,
    total_votes      = totalvotes,
    biden_votes,
    trump_votes,
    biden_share,
    trump_share,
    biden_margin,
    winner           = ifelse(biden_margin > 0, "Biden", "Trump"),
    covid_deaths     = covid_deaths_to_2020_11_07,
    pneumonia_deaths = pneumonia_deaths_to_2020_11_07
  ) %>%
  arrange(desc(biden_margin))

cat("Election rows:", nrow(election_2020), "\n")
saveRDS(election_2020, file.path(out_dir, "election_2020.rds"))
write.csv(election_2020, file.path(out_dir, "election_2020.csv"),
          row.names = FALSE)

# ============================================================================
# 3. STATE CRIME + DEMOGRAPHICS  (AP #3)
#    -- from 13_week/data/us_arrests.rds + 13_week/data/state_data.rds
# ============================================================================

cat("\n--- 3. State crime and demographics ---\n")

arrests <- readRDS(file.path(proj_dir, "13_week", "data", "us_arrests.rds"))
states  <- readRDS(file.path(proj_dir, "13_week", "data", "state_data.rds"))

arrests$state <- rownames(arrests)
states$state  <- rownames(states)

state_crime <- arrests %>%
  select(state, Murder, Assault, Rape, UrbanPop) %>%
  left_join(
    states %>% select(state, region, Population, Income, Illiteracy,
                      Life.Exp, HS.Grad, Frost, Area),
    by = "state"
  ) %>%
  rename(
    murder     = Murder,
    assault    = Assault,
    rape       = Rape,
    urban_pop  = UrbanPop,
    population = Population,
    income     = Income,
    illiteracy = Illiteracy,
    life_exp   = Life.Exp,
    hs_grad    = HS.Grad,
    frost      = Frost,
    area       = Area
  ) %>%
  mutate(region = as.character(region))

cat("State crime rows:", nrow(state_crime), "\n")
saveRDS(state_crime, file.path(out_dir, "state_crime.rds"))
write.csv(state_crime, file.path(out_dir, "state_crime.csv"),
          row.names = FALSE)

# ============================================================================
# 4. BATTLE DEATHS  (IR #1)  -- from 07_week/data/battle_deaths.rds
#    (Country-year battle deaths with World Bank region and income group.)
# ============================================================================

cat("\n--- 4. Battle deaths (07_week) ---\n")

bd_src <- readRDS(file.path(proj_dir, "07_week", "data", "battle_deaths.rds"))

battle_deaths <- bd_src %>%
  filter(!is.na(battle_deaths), battle_deaths > 0) %>%
  transmute(
    iso2c,
    country,
    year          = as.integer(year),
    battle_deaths = as.numeric(battle_deaths),
    region        = as.character(region),
    income        = as.character(income)
  ) %>%
  arrange(country, year)

cat("Battle deaths rows:", nrow(battle_deaths),
    "| countries:", dplyr::n_distinct(battle_deaths$country), "\n")

saveRDS(battle_deaths, file.path(out_dir, "battle_deaths.rds"))
write.csv(battle_deaths, file.path(out_dir, "battle_deaths.csv"),
          row.names = FALSE)

# ============================================================================
# 5. ISIS MOBILIZATION  (IR #2)  -- from Edgerton (2023) JCR replication archive
#    https://github.com/jfedgerton/Edgerton-2023-JCR
# ============================================================================

cat("\n--- 5. ISIS mobilization (Edgerton 2023) ---\n")

isis_rda <- file.path(out_dir, "data_for_analysis.Rda")
if (!file.exists(isis_rda)) {
  url <- paste0("https://raw.githubusercontent.com/jfedgerton/",
                "Edgerton-2023-JCR/main/replication_data/data_for_analysis.Rda")
  cat("Downloading from:", url, "\n")
  utils::download.file(url, isis_rda, mode = "wb")
}

isis_env <- new.env()
load(isis_rda, envir = isis_env)
isis_raw <- isis_env$data_for_analysis

# Aggregate PRIO-GRID cell-year up to country-year so the app stays snappy.
isis_mobilization <- isis_raw %>%
  filter(!is.na(country_name), !is.na(year)) %>%
  group_by(country_name, year) %>%
  summarize(
    isis_fighters      = sum(count,              na.rm = TRUE),
    isis_attacks       = sum(isis_attacks,       na.rm = TRUE),
    n_cells            = dplyr::n(),
    mean_nightlights   = mean(nlights_calib_mean, na.rm = TRUE),
    mean_gcp_ppp       = mean(gcp_ppp,           na.rm = TRUE),
    total_population   = sum(pop_gpw_sum,        na.rm = TRUE),
    mean_unemployment  = mean(wdi_unempmne,      na.rm = TRUE),
    mean_polity        = mean(p_polity2,         na.rm = TRUE),
    mean_gov_effect    = mean(wbgi_pve,          na.rm = TRUE),
    any_sunni_excluded = as.integer(any(excluded_sunni_present == 1, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  filter(isis_fighters > 0 | isis_attacks > 0) %>%
  arrange(country_name, year)

cat("ISIS mobilization rows:", nrow(isis_mobilization),
    "| countries:", dplyr::n_distinct(isis_mobilization$country_name), "\n")

saveRDS(isis_mobilization, file.path(out_dir, "isis_mobilization.rds"))
write.csv(isis_mobilization, file.path(out_dir, "isis_mobilization.csv"),
          row.names = FALSE)

cat("\n=== Data curation complete ===\n")
cat("Files written to:", out_dir, "\n")
