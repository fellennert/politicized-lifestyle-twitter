library(fs)
library(tidyverse)

data <- dir_ls("data/follower-data", recurse = TRUE) %>% 
  .[str_detect(., "csv$")] %>% 
  map(read.csv)

data %>% head()

users <- data$user %>% unique()

users_original <- read_csv("data/distinct-followers.csv")

users_original$followers %in% users %>% sum()

users_original %>% filter(followers %in% users) %>% arrange(n) %>% head()

to_scrape <- users_original %>% filter(followers > 9) %>% pull(followers)
