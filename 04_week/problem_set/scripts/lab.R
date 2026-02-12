## ---------------------- ##
## Senate ideology scores ##
## ---------------------- ##

setwd("04_week")
dir.create("problem_set/outputs", showWarnings = F, recursive = T)
dir.create("problem_set/figures", showWarnings = F, recursive = T)

list.files("data")

library(ggplot2)
library(plyr)
library(dplyr)
library(ggrepel)
df <- read.csv("data/Sall_members.csv")

set.seed(123)
dim(df)
head(df)


summary(df$nominate_dim1)
summary(df$nominate_dim2)


df4 <- df %>% 
  filter(
    chamber == "Senate",
    congress %in% c(101, 106, 111, 116)
  )

congress_loop <- unique(df4$congress)
for (i in congress_loop)
{
  df_temp <- df %>% 
    filter(congress == i)
  drop_names <- sample(1:nrow(df_temp), 80)
  df_temp$bioname[drop_names] <- NA  
  df_temp$bioname_short <- sub(",.*$", "", df_temp$bioname)
  ptemp <- ggplot(df_temp, aes(x = nominate_dim1, nominate_dim2, col = nominate_dim1, label = bioname_short)) + 
    geom_point(alpha = I(4/5)) + 
    scale_color_gradient2(low = "darkblue", mid = "gray", high = "darkred") +
    theme_bw() + 
    labs(x = "DW Nominate 1", y = "DW Nominate 2", title = paste0("Senate ", i),
         col = "DW Nominate 1\n(Conservative to Progressive)") + 
    geom_text_repel(point.padding = 0.15,   # keep a little space from the dot
              box.padding   = 0.25,   # keep labels from touching each other
              min.segment.length = 0, # always draw the little connector
              segment.alpha = 0.4,
              size = 3) + 
    theme(legend.position = "bottom")
  ggsave(paste0("problem_set/figures/figure_", i, ".png"), ptemp, width = 7, height = 5, units = "in")
}
