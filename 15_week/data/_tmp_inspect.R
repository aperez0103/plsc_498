setwd("15_week/data")
cat("=== isis_count_data.rds ===\n")
isis <- readRDS("isis_count_data.rds")
cat("class:", class(isis)[1], "dim:", dim(isis)[1], "x", dim(isis)[2], "\n")
cat("cols:", paste(names(isis), collapse = ", "), "\n")
print(utils::head(isis, 3))

cat("\n=== data_for_analysis.Rda ===\n")
env <- new.env()
load("data_for_analysis.Rda", envir = env)
cat("objects:", paste(ls(env), collapse = ", "), "\n")
for (nm in ls(env)) {
  obj <- env[[nm]]
  if (is.data.frame(obj)) {
    cat("--", nm, "dim:", nrow(obj), "x", ncol(obj), "\n")
    cat("   cols:", paste(names(obj), collapse = ", "), "\n")
  } else {
    cat("--", nm, "class:", class(obj)[1], "\n")
  }
}
