---
output:
  html_document: default
---

### getwd()

"/Users/angel/Desktop/PSU/2025-26/Spring '26/PLSC 498/Problem Sets/plsc_498/03_week"

### list.files("data")

[1] "codebook.md"\
[2] "dataverse_files.zip"\
[3] "HOUSE_precinct_general.csv" [4] "README.md"

### list.files()

[1] "03_week.Rproj" "data" "figures"\
[4] "outputs" "problem_set" "scripts"\
[7] "slides"

### nrow(county_df)

[1] 1698\
The total number of unique counties in the aggregated dataset is 1698.

### summary(county_df\$county_total_votes)

The lowest amount of votes a county recorded was 24, while the highest number of votes recieved is 875,210. The dataset has a median vote count of 6,486.

### summary(county_df\$rep_share)

The bounds of the Republican share of votes by county are 0 and 1, as the share is presented as a percentage of total votes. The average republican share of votes across all counties is 60.55%, with 50% of the data falling between 47.49% and 76.26%

### Interpretation and Explanation

In both plots, the the Republican share of votes by counties is plotted on the y-axis. Along the x-axis, in [Figure 1](../figures/plot_raw.png), is the unscaled, raw total county vote totals, while [Figure 2](../figures/plot_scaled.png) uses a log scale of the same data. The color is mapped on a continuous scale according to the share of votes held by republicans, showing how republican vote shares are, with values less than 50% being more democrat dominant. In the unscaled plot, it is more difficult to see county total votes on a case-by-case basis as it relates to the republican share of those votes, it is also difficult to interpret what each point is conveying (that is, it is difficult to tell what vote counts are more frequent under 250,000 votes). Both of these issues are remedied in the scaled plot, with a more spread out plot of the data being visualized, allowing for white space to exists and differentiate points from on another. The scaled plot does not present any new issues, nor does it make it any more difficult in interpreting its contents; however, if the outlier effects were meant to be visualized in this scatterplot, then it becomes very difficult to intuitively analyze it with the logged scale in the x-axis. In presenting the results to a general audience, the scaled plot ([Figure 2](../figures/plot_scaled.png)) would be the figure I present. It is uncluttered, clear, and visually appealing compared to the unscaled version ([Figure 1](../figures/plot_raw.png)).


### git status

On branch main
Your branch is ahead of 'origin/main' by 1 commit.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean

### git log -1

commit e4bc08ae5911862c7fa747561cfe505bd9fd0121 (HEAD -> main)