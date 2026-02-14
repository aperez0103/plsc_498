## getwd() 
[1] "/Users/angel/Desktop/PSU/2025-26/Spring '26/PLSC 498/Problem Sets/plsc_498/05_week"

## list.files("data") 
[1] "archive.zip"          "IMDB_Movies_Data.csv"

## nrow(df) 
[1] 42

## ncol(df) 
[1] 16

## range(df$budget) 
[0, 320000000]

## range(df$revenue) 
[0, 970766005]

## Interpretation 
The [budget distribution](../figures/budget_hist_binned.png) revealed the fact that a significant amount of movies received comparatively less funding than others; that is, the movie budgets were significantly left-skewed towards little-to-no funding. Most movies received less than \$100 million in budget funding. The [revenue distribution](../figures/revenue_hist_binned.png) reveals a similar left-skewedness, indicating that most movies earned \$250 million in revenue. The top three directors' (Chris Renaud, Christopher McQuarrie, John Woo) [earnings by movies](../figures/revenue_by_director.png) reveal that the Chris Renaud's movie *Dispicable Me 2*, bringing in nearly \$1,000 million. The second highest grossing director is Christopher McQuarrie, coming in just under \$750 million. In the [scatter plot](../figures/budget_revenue_scatter.png) showing the relationship between budget and revenue, it is clear that movies originally in English perform better in both revenue and popularity, while there is a visible correlation between a higher budget resulting in more revenue. Encoding popularity to size while simultaneously encoding language to color clutters the visualization, potentially allowing for the more spaced points to give more meaning than all the points that are around (0,0). While it doesn't affect determining what movies have done well in the past in terms of budget, revenue and language, it obsures potentially crucial information, such as the true ratio of movies that may receieve little funding, yet still perform well and/or gross higher amounts. Alone, sizing by popularity makes interpretation clearer, and it is more intuitive than simply plotting another visualization depicting popularity alone. Showing the potential relationship between language and movie success is intuitive, but doing so by color only obscures data that are within a short distance from each other. 