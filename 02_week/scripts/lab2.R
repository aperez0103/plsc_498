# ----------------------------------
# Script name: lab2.R
# Purpose: PLSC 498 Lab 2 - Reproducible Visualization Workflow
# ----------------------------------

## Setup ----
library(ggplot2)
#step 1: load dataset
vdem <- readRDS("data/vdem.rds")

#inspect
dim(vdem)
names(vdem)[1:3]

#proove variables exists
var_proof_check <- c("v2clacjstw","v2clacjstm","v2clkill","v2cltort")
var_proof_check %in% names(vdem)
str(vdem[, var_proof_check])

#baseline plot
p0 <- ggplot(vdem, aes(
  x = v2clacjstw,
  y = v2clacjstm
)) +
  geom_point()

ggsave("figures/plot_baseline.png", plot = p0)


#extension 1
p1 <- ggplot(vdem, aes(
  x = v2clacjstw,
  y = v2clacjstm,
  size = v2cltort
)) +
  geom_point(alpha = 0.15)

ggsave("figures/plot_extension1.png", plot = p1)

#extension 2
p2 <- ggplot(vdem, aes(
  x = v2clacjstw,
  y = v2clacjstm,
  size = v2cltort,
  color = v2clkill
)) +
  geom_point(alpha = 0.25)

ggsave("figures/plot_extension2.png", plot = p2)
