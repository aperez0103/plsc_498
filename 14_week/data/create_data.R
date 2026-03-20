# Run this script once to create the RDS data files for Week 14
# Requires: gapminder package

library(gapminder)

# Use script's own directory for output
out_dir <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
if (!nzchar(out_dir) || is.null(out_dir)) {
  out_dir <- "C:/Users/Jared_Edgerton/Dropbox/teaching_material/PSU/plsc_498/14_week/data"
}

# Gapminder data
gap <- gapminder::gapminder
saveRDS(gap, file.path(out_dir, "gapminder.rds"))
write.csv(gap, file.path(out_dir, "gapminder.csv"), row.names = FALSE)

# Simulated survey data (matches problem set instructions)
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

saveRDS(df_survey, file.path(out_dir, "survey_democracy.rds"))
write.csv(df_survey, file.path(out_dir, "survey_democracy.csv"), row.names = FALSE)

cat("Week 14 data files created in:", out_dir, "\n")
