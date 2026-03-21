## getwd()

[1] "/Users/angel/Desktop/PSU/2025-26/Spring '26/PLSC 498/Problem Sets/plsc_498/09_week"

## list.files("data")

[1] "state_df.rds"

## dim(df)

[1] 51 10

## names(df)

[1] "state"\
[2] "state_po"\
[3] "totalvotes"\
[4] "biden_votes"\
[5] "trump_votes"\
[6] "biden_share"\
[7] "trump_share"\
[8] "biden_margin"\
[9] "covid_deaths_to_2020_11_07"\
[10] "pneumonia_deaths_to_2020_11_07"

## Total National Illness deaths

1093853 deaths.

## Minimum and Maximum state death totals

VERMONT 459 (min)

CALIFORNIA 115191 (max)

## Interpretation

Interpretations across the board, not only exclusive to the figures created in this lab, shifts when moving from totals to proportion-based figures. Totals show raw counts, given an unfiltered and unsimplified view at what is happening, whereas proportions give viewers an idea of how data relates to each other on a more intuitive level. In this case, proportions allow for comparison between 2020 Presidential candidate easier than other visualization methods, with the focus being how much of a *share* of illness deaths are associated with the states each respective candidate won. The bar plots showing totals emphasizes the differences in death tolls by state, which is entirely omitted in the proportional plot. The proportional plot emphasizes the difference in illness related death tolls in all states each candidate won the 2020 General Election in. This, in theory, can be derived from the faceted bar plots for illness deaths faceted by winner, but it is heavily obscured by the faceting by the two candidates in the visualization. For the plots showing illness deaths faceted by winner and proportion of illness deaths by winner, the coloring scheme relies on the winner's political party. Trump is colored *red* to intuitively denote a republican candidate, while Biden is colored *blue* to intuitively denote a democratic candidate. In showing the total illness death by state, a *light blue* color is used to bring contrast against the background, without being obnoxiously contrasting. This is to allow for the spacing to naturally show where each state's bar starts and ends in order to reduce any confusion. A potential misinterpretation that can be had from "Proportion of Total Illness Deaths by Presidential Candidate" plot is assuming the visualization draws some sort of causality between total illness deaths and whether Trump or Biden won. Without context, it can appear that the argument being made is "Biden winning results in more illness related deaths compared to Trump."
