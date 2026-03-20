# Master script: compile xaringan slides for weeks 12-14
# Run from plsc_498 project root
# Requires: xaringan, rmarkdown, ggplot2, dplyr, tidyr, scales, sf, maps,
#           zoo, rnaturalearth, gapminder

library(rmarkdown)

slides <- c(
  "12_week/slides/12_01_week.Rmd",
  "12_week/slides/12_02_week.Rmd",
  "13_week/slides/13_01_week.Rmd",
  "13_week/slides/13_02_week.Rmd",
  "14_week/slides/14_01_week.Rmd",
  "14_week/slides/14_02_week.Rmd"
)

for (rmd in slides) {
  cat("Compiling:", rmd, "\n")
  tryCatch({
    rmarkdown::render(rmd, quiet = TRUE)
    cat("  -> Success\n")
  }, error = function(e) {
    cat("  -> ERROR:", conditionMessage(e), "\n")
  })
}

cat("\nDone. Check each slides/ folder for the HTML output.\n")
