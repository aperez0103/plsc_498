## getwd()  
[1] "/Users/angel/Desktop/PSU/2025-26/Spring '26/PLSC 498/Problem Sets/plsc_498/04_week"

## list.files()  
[1] "04_week.Rproj" "data"          "figures"      
[4] "outputs"       "problem_set"   "scripts"      
[7] "slides"  

## nrow(df)  
[1] 10125

## ncol(df)  
[1] 22

## table(df4$congress)  
101 106 111 116 
102 102 111 102 

## table(df4$chamber)  
Senate 
   417 
   
## nominate_dim1  
summary(df4$nominate_dim1)
   Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
-0.74700 -0.31900 -0.12300  0.02934  0.39000  0.89100 

The coded variable `nominate_dim1` is the variable used in the visualizations for representing Senators' ideologies. `nominate_dim2` is used along the y-axis, not used for ideological visualization.

## Interpretation  

In all the plots, there is a diverging color scale. This scale utilized red and blue colors on either extreme, with grey being the midpoint at 0. The colors directly correspond with ideological leaning, with more red points indicating more conservative senators and more blue points indicating more liberal senators (the more grey/shaded a point appeared, the more moderate they were). These colors change on a gradient along the x-axis, as the x-axis "dim1" measures ideologies of the senators. These ideologies have a range of [-0.747, 0.891], with negative values indiacting more liberal (displaying more blue) ideologies, while the positive values are more conservative (displaying more red) values. When creating the visualization, I initially had the background of the plot as black as to not be too harsh on the eye while giving good contrast with the points, but with the grey midpoint on my divergin color scale, it made more moderate senators difficult to interpret. Due to this, the background remains white so there is enough contrast for the points to be easily interpretative. In comparing the 101st Senate and the 116th Senate, it is clear that the conservative senators have become more polarized than their liberal counterparts. The liberal senators, for the most part, remain relatively unchanged in dispersion and did not see a drastic shift towards extreme liberalistic values (`dim1 < -0.5`). The conservative senators become significantly less moderate in the 116th Senate, with a large number of senators displaying relatively extreme levels of conservatism (`dim1 > 0.5`).

## Accessability 

For the accessibility evaluation, I used the 101st Senate plot, and tested it using protanopia and deuteranopia simulations. Under both conditions, it was hard to differentiate colors in varying shades of red. Because of this, I decided it was best to re-approach the color design. I used more colorblind friendly colors (A dark green for more liberal senators, light blue for more conservative, with a yellow midpoint for moderates). This easily displays changes in color along the x-axis, though it loses the value of implicitly associating conservatives with the color red and liberals with the color blue. With that said, I learned that visualizations carefully balances accessibility for all readers with conveying what is truly important in a meaningful manner. 