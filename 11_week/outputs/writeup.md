## getwd()

[1] "/Users/angel/Desktop/PSU/2025-26/Spring '26/PLSC 498/Problem Sets/plsc_498/11_week"

## list.files()

[1] "11_week.Rproj" "data"\
[3] "figures" "outputs"\
[5] "problem_set" "scripts"\
[7] "slides"

## list.files("data")

[1] "basketball.rds"

## \# of rows in dataframe `basketball`

569 rows

## \# of rows in dataframe `basketball_clean`

565 rows

## Summary of AGE, PTS, REB

### Age

-   Min: 19

-   Max: 40

-   Mean: 26.23

### Points scored (on average)

-   Min: 0

-   Max: 32.70

-   Mean: 8.879

### Rebounds (on average)

-   Min: 0

-   Max: 13.90

-   Mean:3.591

## Handling of `NAs` in the data

All observations with NA values post-conversion from character strings to numeric format were dropped from the dataset using `na_omit()`.

## Relationship 1 (extension)

The fitted line on the the [scatterplot](../figures/usg_pts_lm_se.png) claims there is a positive linear relationship in the data between points scored and usage percent. The shaded area can be interpreted as the level of confidence in the trend line at any given point, with wider shading corresponding to a poorer fitting trend line for the data, while a tighter line corresponds to a better fitting line for the data. The band in general makes me more confident in the trend between roughly 10 and 30% of player usage percentage, while I have diminishing confidence in its accuracy outside of these bounds.

## Relationship 1B: Usage and scoring efficiency

The trend looks roughly linear, however I believe a better fitting line would have some degree of curvature. The standard error ribbon supports this idea that the relationship may not be linear. As the fitted line enters and exits the densely populated area (10% \< x \< 30%, 40% \< y \< 70%), the standard error area expands rapidly, suggesting a poorly fitted lines for values not within the aforementioned ranges, raiding uncertainty for the fitted line.

## Relationship 1C: Assists (Raw vs Rates)

With several exceptions around x = 1, AST and AST_PCT have a close one-to-one relationship. The reason why players may have similar AST (Assists) but differing AST_PCT (Assist Rates) is due to the nature of raw volume versus rates. AST measures assist volume - the number of times a player assists (which can be similar for many players), while assist rates (AST_PCT) better represent the frequency of the volume. So two players can have 5 assists, but one may have a higher rate of occurrence relative to time on the court compared to another player with lower assist rates.

## Relationship 2: Player Size and Rebounds

This [scatterplot](../figures/size_reb_scatter.png) shows a moderate positive relationship between player weight and rebounds, meaning on average the heavier a player is, the more likely they are to average more rebounds. A reason for this may have to relate to a third confounding variable - height. When height increases, it is expected that weight also increases, and intuitively, height may make for easier, more frequently successful rebounds to occur on average.

## Relationship 3: Age and Scoring Effeciency

The quadratic fit seems to capture the data trend better than a straight. The SE ribbon is widest between ages 35 and 40, suggesting fewer basketball players fall within that age range. According to the curve, players roughly at 31-34 years of age seem to have peak scoring efficiency.

## Final Interpretation

In Figure 1 and Figure 2, the scatterplot reveals a strong positive relationship between points scored and usage percentage. This trend follows a fairly linear shape. In Figure 3, the relationship is slightly more ambiguous. True shooting percentage as a weak positive relationship with player usage percentage, still following a positive, relatively linear pattern. However, confidence in linearity falls off beyond 30% player usage. Figure 4 displays a strong positive linear relationship between assist rates and assist volume. Figure 5 has a moderate positive linear relationship between rebounds and player weight. Figure 5 has an interesting point pattern compared to the other figures, in that it has a lot of high value outliers with respect to rebounds, spreading the data more than any other relationship examined. This could imply potential randomness in this relationship, or confounding variables that may better explain the effect player stats have on rebounds. Figure 6 shows a strong parabolic relationship between age and scoring efficiency. Here, scoring efficiency peaks around ages 31-34, with scoring efficiency decreasing as player age both increases and decreases. Across all figures, I made the point sizes both smaller and more translucent to help avoid overplotting and give a more intuitive sense of data trends, without needing to rely on a smoothing line. For Figure 6 specifically, I increased the translucency of each point, as there is a lot of similar shooting efficiency rates for each cohort of player. Increasing translucency allows for density around these ages to be better seen and examined. 