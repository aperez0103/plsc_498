files <- c(
  "04_week/data/Sall_members.csv",
  "09_week/data/state_df.rds",
  "12_week/data/presidential.rds",
  "13_week/data/state_data.rds",
  "13_week/data/us_arrests.rds",
  "07_week/data/battle_deaths.rds",
  "02_week/data/vdem.rds",
  "14_week/data/survey_democracy.rds"
)
for (p in files) {
  cat("===", p, "===\n")
  tryCatch({
    d <- if (grepl("csv$", p)) read.csv(p) else readRDS(p)
    cat("dim:", nrow(d), "x", ncol(d), "\n")
    cat("cols:", paste(names(d), collapse = ", "), "\n")
    print(utils::head(d, 2))
    cat("\n")
  }, error = function(e) cat("err:", conditionMessage(e), "\n"))
}
