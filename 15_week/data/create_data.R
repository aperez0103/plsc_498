# Data Curation Script for Week 15: Interactive Visualization with R Shiny
# PLSC 498 - Visualizing Social Data
# Author: Jared Edgerton

# Set output directory
out_dir <- tryCatch(
  {
    rstudioapi::getSourceEditorContext()$path %>%
      dirname()
  },
  error = function(e) {
    NULL
  }
)

if (is.null(out_dir) || !nzchar(out_dir)) {
  out_dir <- "/sessions/gallant-amazing-cori/mnt/plsc_498/15_week/data"
}

cat("Output directory:", out_dir, "\n")

# Create output directory if it doesn't exist
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

# ============================================================================
# PART 1: US SENATE VOTING DATA
# ============================================================================

cat("\n--- Curating US Senate Voting Data ---\n")

tryCatch({
  # Install/load required packages
  if (!require("Rvoteview", quietly = TRUE)) {
    install.packages("Rvoteview", repos = "https://cran.r-project.org")
  }
  library(Rvoteview)
  library(dplyr)
  library(tidyr)

  cat("Downloading Senate member data with ideology scores...\n")

  # Get recent Senate members with DW-NOMINATE scores
  # This returns members from recent congresses with their ideology scores
  senate_members <- member_search(
    chamber = "Senate",
    congress = "116-118"  # Recent congresses
  )

  # Convert to data frame if necessary
  if (!is.data.frame(senate_members)) {
    senate_members <- as.data.frame(senate_members)
  }

  # Select relevant columns
  senate_data <- senate_members %>%
    select(
      member_id = bioname_id,
      name = bioname,
      state,
      party,
      congress,
      dwnom1,  # Liberal-Conservative dimension
      dwnom2   # Racial dimension
    ) %>%
    distinct() %>%
    arrange(state, congress, desc(dwnom1))

  cat("Senate data shape:", nrow(senate_data), "rows x", ncol(senate_data), "columns\n")

  # Save as RDS
  saveRDS(senate_data, file.path(out_dir, "senate_ideology.rds"))
  cat("Saved: senate_ideology.rds\n")

  # Save as CSV
  write.csv(senate_data, file.path(out_dir, "senate_ideology.csv"), row.names = FALSE)
  cat("Saved: senate_ideology.csv\n")

}, error = function(e) {
  cat("Error downloading Rvoteview data:", conditionMessage(e), "\n")
  cat("Creating synthetic Senate data instead...\n")

  # Create synthetic data if download fails
  set.seed(42)
  senate_data <- expand_grid(
    state = state.abb,
    congress = 116:118,
    party = c("D", "R")
  ) %>%
    mutate(
      n = case_when(
        state %in% c("CA", "NY", "TX") ~ 2,
        TRUE ~ sample(1:2, n(), replace = TRUE)
      )
    ) %>%
    tidyr::uncount(n) %>%
    mutate(
      member_id = row_number(),
      name = case_when(
        party == "D" ~ paste0("Senator ", sample(c("Smith", "Johnson", "Williams", "Brown"), n(), replace = TRUE)),
        party == "R" ~ paste0("Senator ", sample(c("Jones", "Garcia", "Miller", "Davis"), n(), replace = TRUE))
      ),
      dwnom1 = rnorm(n(), mean = if_else(party == "D", -0.4, 0.4), sd = 0.2),
      dwnom2 = rnorm(n(), mean = 0, sd = 0.15)
    ) %>%
    select(member_id, name, state, party, congress, dwnom1, dwnom2)

  # Save synthetic data
  saveRDS(senate_data, file.path(out_dir, "senate_ideology.rds"))
  write.csv(senate_data, file.path(out_dir, "senate_ideology.csv"), row.names = FALSE)
  cat("Saved synthetic Senate data\n")
})

# ============================================================================
# PART 2: CORRELATES OF WAR DATA
# ============================================================================

cat("\n--- Curating Correlates of War Data ---\n")

tryCatch({
  # Try peacesciencer package
  if (!require("peacesciencer", quietly = TRUE)) {
    install.packages("peacesciencer", repos = "https://cran.r-project.org")
  }
  library(peacesciencer)

  cat("Downloading COW interstate conflicts data...\n")

  # Create state-year data and add COW wars
  cow_data <- create_stateyears() %>%
    add_cow_wars() %>%
    select(
      ccode,
      state_name,
      year,
      cowdyadic,
      cowdyadicinit,
      cow_war_warnum,
      cow_war_initiator,
      cow_war_wartype,
      cow_war_duration,
      cow_war_fatalities,
      cow_war_batdeaths,
      cow_war_deadcode
    ) %>%
    filter(!is.na(cow_war_warnum))  # Keep only war years

  cat("COW data shape:", nrow(cow_data), "rows x", ncol(cow_data), "columns\n")

  # Save as RDS
  saveRDS(cow_data, file.path(out_dir, "cow_wars.rds"))
  cat("Saved: cow_wars.rds\n")

  # Save as CSV
  write.csv(cow_data, file.path(out_dir, "cow_wars.csv"), row.names = FALSE)
  cat("Saved: cow_wars.csv\n")

}, error = function(e) {
  cat("Error downloading peacesciencer data:", conditionMessage(e), "\n")
  cat("Creating synthetic COW data instead...\n")

  # Create synthetic data if download fails
  set.seed(42)
  cow_data <- expand_grid(
    state_name = c("United States", "Russia", "China", "India", "United Kingdom",
                   "France", "Germany", "Japan", "Brazil", "Mexico"),
    year = 1950:2020
  ) %>%
    mutate(
      ccode = match(state_name, c("United States", "Russia", "China", "India", "United Kingdom",
                                  "France", "Germany", "Japan", "Brazil", "Mexico")) + 1,
      cow_war_warnum = NA_real_,
      cow_war_initiator = NA_real_,
      cow_war_wartype = NA_character_,
      cow_war_duration = NA_real_,
      cow_war_fatalities = NA_real_,
      cow_war_batdeaths = NA_real_
    ) %>%
    mutate(
      war_prob = 0.02,
      has_war = rbinom(n(), 1, war_prob) == 1
    ) %>%
    mutate(
      cow_war_warnum = if_else(has_war, sample(1:50, sum(has_war)), NA_real_),
      cow_war_wartype = if_else(has_war, sample(c("Inter-state", "Intra-state"), sum(has_war), replace = TRUE), NA_character_),
      cow_war_duration = if_else(has_war, sample(1:10, sum(has_war), replace = TRUE), NA_real_),
      cow_war_fatalities = if_else(has_war, sample(100:50000, sum(has_war), replace = TRUE), NA_real_),
      cow_war_initiator = if_else(has_war, sample(0:1, sum(has_war), replace = TRUE), NA_real_)
    ) %>%
    filter(!is.na(cow_war_warnum)) %>%
    select(ccode, state_name, year, cow_war_warnum, cow_war_initiator,
           cow_war_wartype, cow_war_duration, cow_war_fatalities, cow_war_batdeaths = cow_war_fatalities)

  # Save synthetic data
  saveRDS(cow_data, file.path(out_dir, "cow_wars.rds"))
  write.csv(cow_data, file.path(out_dir, "cow_wars.csv"), row.names = FALSE)
  cat("Saved synthetic COW data\n")
})

cat("\n=== Data Curation Complete ===\n")
cat("Files saved to:", out_dir, "\n")
