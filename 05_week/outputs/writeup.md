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

## git status 
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

## git log -3 (updated lab 4 in repo after submission, needed to merge branch to main repo before pushing)
commit bb2651ee6d4b91f04740d06080b054546efd01a0 (HEAD -> main, origin/main, origin/HEAD)
Author: aperez0103 <angel13per@gmail.com>
Date:   Fri Feb 13 23:45:02 2026 -0500

    update repo 
    
    commit 1c6545ee05c8c7e13133d4a7e0f6dd8e9ac3e3f2
    
Merge: 56234c1 c55884e
Author: aperez0103 <angel13per@gmail.com>
Date:   Fri Feb 13 23:37:43 2026 -0500

    Merge branch 'main' of https://github.com/aperez0103/plsc_498

commit 56234c155fb3b218eeebae306a42014693f59f97
Author: aperez0103 <angel13per@gmail.com>
Date:   Fri Feb 13 23:36:40 2026 -0500
