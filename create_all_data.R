# Master script: generates all RDS data files for weeks 12-14
# Run this in RStudio (no working directory dependency)

base <- "C:/Users/Jared_Edgerton/Dropbox/teaching_material/PSU/plsc_498"

cat("Creating data files for weeks 12-14...\n\n")

# --- Week 12 ---
library(ggplot2)
library(gapminder)

d12 <- file.path(base, "12_week", "data")

econ <- ggplot2::economics
saveRDS(econ, file.path(d12, "economics.rds"))
write.csv(econ, file.path(d12, "economics.csv"), row.names = FALSE)

pres <- ggplot2::presidential
saveRDS(pres, file.path(d12, "presidential.rds"))
write.csv(pres, file.path(d12, "presidential.csv"), row.names = FALSE)

gap <- gapminder::gapminder
saveRDS(gap, file.path(d12, "gapminder.rds"))
write.csv(gap, file.path(d12, "gapminder.csv"), row.names = FALSE)

cat("Week 12 done.\n")

# --- Week 13 ---
library(maps)

d13 <- file.path(base, "13_week", "data")

us <- map_data("state")
saveRDS(us, file.path(d13, "us_states.rds"))
write.csv(us, file.path(d13, "us_states.csv"), row.names = FALSE)

state_data <- data.frame(
  region = tolower(state.name),
  as.data.frame(state.x77)
)
saveRDS(state_data, file.path(d13, "state_data.rds"))
write.csv(state_data, file.path(d13, "state_data.csv"), row.names = FALSE)

arrests <- USArrests
arrests$region <- tolower(rownames(arrests))
saveRDS(arrests, file.path(d13, "us_arrests.rds"))
write.csv(arrests, file.path(d13, "us_arrests.csv"), row.names = FALSE)

cat("Week 13 done.\n")

# --- Week 14 ---
d14 <- file.path(base, "14_week", "data")

saveRDS(gap, file.path(d14, "gapminder.rds"))
write.csv(gap, file.path(d14, "gapminder.csv"), row.names = FALSE)

set.seed(42)
df_survey <- data.frame(
  country = c("United States", "United Kingdom", "Germany",
              "France", "Japan", "Brazil", "India", "Nigeria"),
  dem_support = c(72, 68, 65, 61, 54, 48, 42, 38),
  n = c(1200, 1000, 950, 1100, 800, 600, 750, 500)
)
df_survey$se <- sqrt(df_survey$dem_support *
  (100 - df_survey$dem_support) / df_survey$n)
df_survey$lower <- df_survey$dem_support - 1.96 * df_survey$se
df_survey$upper <- df_survey$dem_support + 1.96 * df_survey$se

saveRDS(df_survey, file.path(d14, "survey_democracy.rds"))
write.csv(df_survey, file.path(d14, "survey_democracy.csv"), row.names = FALSE)

cat("Week 14 done.\n")
cat("\nAll data files created successfully.\n")
