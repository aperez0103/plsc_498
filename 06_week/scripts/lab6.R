# ----------------------------------
# Script name: lab5.R
# Purpose: PLSC 498 Lab 6 - Distributions adn Overplotting with Flight Data
# ----------------------------------

#setup----
library(plyr)
library(dplyr)
library(ggplot2)
# access dataset
load("data/nycflights13.rds")
df <- nycflights13::flights
# quick inspection
dim(df)
names(df)
head(df)