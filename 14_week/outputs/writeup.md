## Number of Rows and Columns in `gap` (gapminder data) 
1,704 rows, 6 Columns

dim(gap)
[1] 1704    6

## Range of years in `gap` (gapminder data) 
The date ranges from 1952 to 2007. [1952, 2007]

## Confirmation of df_survey
head(df_survey)
         country dem_support    n       se    lower    upper
1  United States          72 1200 1.296148 69.45955 69.45955
2 United Kingdom          68 1000 1.475127 65.10875 65.10875
3        Germany          65  950 1.547494 61.96691 61.96691
4         France          61 1100 1.470621 58.11758 58.11758
5          Japan          54  800 1.762101 50.54628 50.54628
6         Brazil          48  600 2.039608 44.00237 44.00237

## Interpretation 
The following pairs of countries have overlapping confidence intervals in support for democracy: United States & United Kingdom (UK), UK & Germany, Germany & France, Japan & Brazil, India & Brazil, India & Nigeria. In terms of these overlaps’ effects on rankings, since none of the confidence intervals meets any of the neighboring point estimates, rankings can rely on the point estimates as shown in the plot.

The uncertainty ribbon on the life expectancy time series provides an additional layer of context that aids in understanding what true values may be. Without these confidence ribbons, interpretation of this plot would follow along the lines of making a strict linear argument, i.e., positing that the average life expectancy for each country follows exactly the trends shown. Instead, the ribbons provide a 95% confidence that the true average life expectancy for each continent lies somewhere within the bounds, with a statistical estimation of what the true average may be. \n

In the redesign of the Life Expectancy by Continent (with 95% confidence ribbons), I first removed the grid background to reduce visual clutter. Since the plot is showing a banded estimate of average life expectancy, knowing exactly what each year’s average was not necessary, thus undermining the need for a grid background. Second, I clearly labeled both the X- and Y- axes from their previous “mean_le” and “year” to clearly relay what the relationship being shown is between. I also added a clear title and subtitle that gives a succinct summary of what the plot is meant to accomplish, which is to convey trends in average life expectancy for each continent over time. The exclusion of such a title, coupled with poorly labeled axes, would leave readers confused as to what argument is being made. 

The confidence ribbon around the fitted line shows where the true relationship between life expectancy and GDP lies with 95% confidence. That is to say, should the data be collected and/or reanalyzed countless times, roughly 95% of those instances see a regression line falling within the bounds of the confidence ribbon. 

Uncertainty was especially important in the Life Expectancy by Continent plot. First, this plot utilized calculated averages based on data that cannot physically and accurately capture every continents residents’ age at time of death. Because of this, the averages calculated are, at best, estimates that may give an idea of where the true average for each continent fall but still fails to provide a objectively correct value. The confidence intervals mitigate this and add to the overall credibility and accuracy of these trend lines, as the averages would statistically fall close to the true values. Second, as a continuation to the prior point, giving the explicit 95% interval also ensures that the reader understands the limits of the plot, and the possibility for inaccuracy.  \n


## Proof 
### Angels-MacBook-Pro:14_week angel$ git status 
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

### Angels-MacBook-Pro:14_week angel$ git log -1 
commit 2e5d97899d24e1ed2985383f858f8bc2f7a3708f (HEAD -> main, origin/main, origin/HEAD)
Author: aperez0103 <angel13per@gmail.com>
Date:   Thu Apr 30 19:20:29 2026 -0400

    lab 14 push