# Run this script once to create the RDS data files for Week 13
# Requires: maps package

library(maps)

# Use script's own directory for output
out_dir <- file.path(dirname(rstudioapi::getSourceEditorContext()$path))
if (!nzchar(out_dir) || is.null(out_dir)) {
  out_dir <- "C:/Users/Jared_Edgerton/Dropbox/teaching_material/PSU/plsc_498/13_week/data"
}

# US state boundaries
us <- map_data("state")
saveRDS(us, file.path(out_dir, "us_states.rds"))
write.csv(us, file.path(out_dir, "us_states.csv"), row.names = FALSE)

# State attribute data (from built-in state.x77)
state_data <- data.frame(
  region = tolower(state.name),
  as.data.frame(state.x77)
)
saveRDS(state_data, file.path(out_dir, "state_data.rds"))
write.csv(state_data, file.path(out_dir, "state_data.csv"), row.names = FALSE)

# USArrests data
arrests <- USArrests
arrests$region <- tolower(rownames(arrests))
saveRDS(arrests, file.path(out_dir, "us_arrests.rds"))
write.csv(arrests, file.path(out_dir, "us_arrests.csv"), row.names = FALSE)

cat("Week 13 data files created in:", out_dir, "\n")
