## getwd()

[1] "/Users/angel/Desktop/PSU/2025-26/Spring '26/PLSC 498/Problem Sets/plsc_498/02_week"

## RStudio Screenshot

![R Project Proof](../figures/screenshot.png)

## Dimensions of `vdem`

dim(vdem) 27913 rows, 1818 columns

## First three column names in `vdem`

names(vdem)[1:3] 

[1] "country_name"\
[2] "country_text_id"\
[3] "country_id"

## Variable Proofs

### var_proof_check <- c("v2clacjstw","v2clacjstm","v2clkill","v2cltort")

### var_proof_check %in% names(vdem)
[1] TRUE TRUE TRUE TRUE

### str(vdem[, var_proof_check])

All variables of interest are number classes.
