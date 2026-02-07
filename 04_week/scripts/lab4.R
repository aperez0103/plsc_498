# ----------------------------------
# Script name: lab4.R
# Purpose: PLSC 498 Lab 4 - Senate Ideology
# ----------------------------------

##setup----
library(ggplot2)
library(dplyr)
set.seed(123)

##data----
df <- read.csv("data/Sall_members.csv")

#check data
dim(df)
names(df)

summary(df$nominate_dim1)
summary(df$nominate_dim2)

#isolate relevant data 
 df4 <- df %>% filter(chamber == "Senate") %>% 
   filter(congress %in% c(106, 106, 111, 116))

#check  
table(df4$congress)
table(df4$chamber)

##plots----

#Congress 101 Senate plot
congress_id <- 101

p <- ggplot(df4 %>% filter(congress == congress_id),
            aes(nominate_dim1, nominate_dim2, color = nominate_dim1)) +
  geom_point() +
  labs(title = "Senate ideology:101st Congress", x = "dim1", y = "dim2") +
theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = NA)) +
  scale_color_gradient2(
    low = "#003C32",
    mid = "#FFC107",
    high = "#1E88E5",
    midpoint = 0
  )

ggsave("figures/senate_101.png", p, width = 8, height = 5)

#Congress 106 Senate plot
congress_id <- 106

p <- ggplot(df4 %>% filter(congress == congress_id),
            aes(nominate_dim1, nominate_dim2, color = nominate_dim1)) +
  geom_point() +
  labs(title = "Senate ideology:106th Congress", x = "dim1", y = "dim2") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = NA)) +
  scale_color_gradient2(
    low = "blue",
    mid = "grey",
    high = "red",
    midpoint = 0
  )

ggsave("figures/senate_106.png", p, width = 8, height = 5)

#Congress 111 Senate plot
congress_id <- 111

p <- ggplot(df4 %>% filter(congress == congress_id),
            aes(nominate_dim1, nominate_dim2, color = nominate_dim1)) +
  geom_point() +
  labs(title = "Senate ideology:111th Congress", x = "dim1", y = "dim2") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = NA)) +
  scale_color_gradient2(
    low = "blue",
    mid = "grey",
    high = "red",
    midpoint = 0
  )

ggsave("figures/senate_111.png", p, width = 8, height = 5)

#Congress 116 Senate plot
congress_id <- 116

p <- ggplot(df4 %>% filter(congress == congress_id),
            aes(nominate_dim1, nominate_dim2, color = nominate_dim1)) +
  geom_point() +
  labs(title = "Senate ideology:116th Congress", x = "dim1", y = "dim2") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = NA)) +
  scale_color_gradient2(
    low = "blue",
    mid = "grey",
    high = "red",
    midpoint = 0
  )

ggsave("figures/senate_116.png", p, width = 8, height = 5)
