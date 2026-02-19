## ---------------------------- ##
## Problem set 06 flight data   ##
## ---------------------------- ##

# Load Libraries 
library(plyr)
library(dplyr)
library(ggplot2)


## Load data
df <- nycflights13::flights

##  Inspect data
dim(df)
names(df)
head(df)


## Question 2: Histogram of data
ggplot(df, aes(x = dep_delay)) + 
  geom_histogram() + 
  theme_classic() + 
  labs(x = "Departure delay", y = "Count", title = "Histogram of departure delays") + 
  scale_y_continuous(labels = scales::comma)

ggplot(df, aes(x = dep_delay)) + 
  geom_histogram(bins = 50) + 
  theme_classic() + 
  labs(x = "Departure delay", y = "Count", title = "Histogram of departure delays") + 
  scale_y_continuous(labels = scales::comma)

ggplot(df, aes(x = arr_delay)) + 
  geom_histogram() + 
  theme_classic() + 
  labs(x = "Arrival delay", y = "Count", title = "Histogram of arrival delays") + 
  scale_y_continuous(labels = scales::comma)

ggplot(df, aes(x = arr_delay)) + 
  geom_histogram(bins = 50) + 
  theme_classic() + 
  labs(x = "Arrival delay", y = "Count", title = "Histogram of arrival delays") + 
  scale_y_continuous(labels = scales::comma)

## Question 3: Histogram and density of delay
ggplot(df, aes(x = dep_delay)) + 
  geom_density(fill = "gray20") + 
  theme_classic() + 
  labs(x = "Departure delay", y = "Count", title = "Histogram of Departure delays") + 
  scale_y_continuous(labels = scales::comma)

ggplot(df, aes(x = dep_delay)) + 
  geom_density(adjust = 1.5, fill = "gray20") + 
  theme_classic() + 
  labs(x = "Departure delay", y = "Count", title = "Histogram of Departure delays") + 
  scale_y_continuous(labels = scales::comma)


## Question 4
top_carriers <- df %>% 
  plyr::ddply(~carrier, 
              summarize,
              n = n()) %>% 
  arrange(-n) %>% 
  slice(1:6)

top_6_carriers <- df %>% 
  filter(carrier %in% top_carriers$carrier)

ggplot(top_6_carriers, aes(x = dep_delay, fill = carrier)) + 
  geom_histogram(alpha = 0.6, bins = 50) + 
  theme_classic() + 
  labs(x = "Departure delay", y = "Count", title = "Histogram of Departure delays by carrier", fill = "Carrier") + 
  scale_y_continuous(labels = scales::comma) + 
  scale_fill_brewer(palette = "Set2") +
  theme(legend.position = "bottom") 

ggplot(top_6_carriers, aes(x = dep_delay, fill = carrier)) + 
  geom_histogram(alpha = 0.6, bins = 50) + 
  theme_classic() + 
  labs(x = "Departure delay", y = "Count", title = "Histogram of Departure delays by carrier", fill = "Carrier") + 
  scale_y_continuous(labels = scales::comma) + 
  scale_fill_brewer(palette = "Set2") +
  theme(legend.position = "none") + 
  facet_wrap(~carrier, scales = "free")


## Question 5: Overplotting and transparency 
ggplot(df, aes(x = distance, y = air_time)) + 
  geom_point(alpha = 0.25, position = position_jitter(width = 0.12, height = 0.12)) +  
  theme_classic() + 
  scale_y_continuous(labels = scales::comma) + 
  labs(x = "Distance", y = "Air time", title = "Airtime by distance")


ggplot(df, aes(x = distance, y = air_time)) + 
  geom_bin2d() +  
  theme_classic() + 
  scale_fill_gradientn(
    colors = c("lightyellow", "orange", "darkred"),
    breaks = scales::pretty_breaks(n = 3),     # fewer tick labels
    labels = scales::comma
  ) + 
  scale_y_log10(labels = scales::comma) + 
  scale_x_log10(labels = scales::comma) + 
  labs(x = "Distance  (logged axis)", y = "Air time (logged axis)", title = "Airtime by distance", fill = "Count") + 
  theme(legend.position = "bottom",
        axis.text = element_text(size = 11),
        axis.title = element_text(size = 13),
        legend.title = element_text(size = 10),
        title = element_text(size = 12))
