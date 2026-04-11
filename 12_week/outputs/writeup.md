## dim(econ)

574 rows, 6 columns

## dim(gap)

1704 rows, 6 columns

## dim(pres)

[1] 12 rows, 4 columns

## c("date", "unemploy") %in% names(econ)

#### Confirming date and unemploy exist in economics data

[1] TRUE TRUE

## range(gap\$year)

The range of years in the gapminder data is [1952, 2007]

## Rolling mean and LOESS comparison

Smoothing does a good job at generalizing the trends over time, and highlighting the distinct direction the turning points shift the trend towards, however it doesn't pinpoint the exact point where the trend shifts. Instead, it approximates around where the trend hits a turning point. The rolling mean best preserves the riming of recessions, as it doesn't over generalize the data and reduce it down to a simple line-of-best-fit.

## Justifying Figure 3

For Figure 3, I elected to include the names of presidents in their respective terms along the x-axis as an attempt to help distinguish different terms from each other, due to the transperency of the colors potentially causing visibility issues.

## Interpretation

I see a constant net-growth in unemployment over time, with more volatility to come in the long-run. The data shows a constant growing period the predicates a sharp decrease in unemployment rates. These decreases seldom ever dip below the previous trough, meaning unemployment rarely falls below its most recent decline. Unemployment follows the same pattern of growth and decay, seeing large growths in unemployment numbers and even more drastic falls in unemployment, relative to time. The rolling mean gives accurate depictions of when the economy experienced short-term recessions, including their start and end years. The LOESS smoothing method generalizes the trend to show overall economic growth and decay, identifying when the economy in an overall "recession" as opposed to growth period across the entire data set. Anointing presidential terms has the potential to add context to the unemployment story, however, as it stands as at the moment, the addition of presidential terms distracts from the story. In more specificity, it adds context regarding what each president was seeming responsibly for in regards to the economy, whether they brought the country out of a recession or not, and if they led the country into a recession. However, the addition coloring adds visual clutter that detracts from this context. In the GDP comparisons, it is clear that the four selected countries (China, Germany, Italy, and Japan) see a growth over time, though China's GDP growth isn't as linear as the other three countries. In fact, China has the slowest climbing GDP rate of the three countries, with Japan, Germany and Italy having roughly similar growth patterns. For Figure 4, the GDP Per Capita: By Country visualization, I elected to have the y-axis fixed rather than free for each facet for two reasons. First, it allows for instant comparison to be more intuitive without concerning the reader with the scales. Second, with a free y-axis, the growth in China will seem to be as large and rapid as the other three countries, despite the magnitude of growth remaining relatively small.
