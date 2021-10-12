# scraping twitter followers

library(tidyverse)
#devtools::install_github("cjbarrie/academictwitteR", build_vignettes = TRUE)
library(academictwitteR)
library(rtweet)
library(fs)

#mp_list <- read_csv("data/french-politicians.csv")
mp_list <- bind_rows(
  read_csv("https://raw.githubusercontent.com/regardscitoyens/twitter-parlementaires/master/data/senateurs.csv") %>% 
    distinct(url_nossenateurs_api, .keep_all = TRUE) %>% 
    rename(api_link = url_nossenateurs_api),
  read_csv("https://raw.githubusercontent.com/regardscitoyens/twitter-parlementaires/master/data/deputes.csv") %>% 
    distinct(url_nosdeputes_api, .keep_all = TRUE) %>% 
    rename(api_link = url_nosdeputes_api)
) %>% 
  distinct(twitter, .keep_all = TRUE)

safe_read <- safely(read_csv2) 

mp_list_api <- map(mp_list$api_link, ~safe_read(.x) %>% pluck(1))

twitter_data <- mp_list %>% 
  filter(!is.na(twitter)) %>% 
  select(name = nom, id, twitter, twitter_followers, groupe_sigle) %>% 
  arrange(twitter_followers) %>% 
  left_join(lookup_users(mp_list$twitter) %>% select(user_id, screen_name), by = c("twitter" = "screen_name"))

politicians_tbl <- map(mp_list_api, ~select(.x, name = nom, id, twitter, groupe_sigle)) %>% bind_rows()
sliced <- politicians_tbl %>% slice(1:10)
#bearer_token <- ""

# get followers

get_followers_tbl <- function(twitter_name) {
  tibble(
    user_id = lookup_users(twitter_name) %>% pull(user_id),
    followers = rtweet::get_followers(user = twitter_name, retryonratelimit = TRUE)
  )
}

safe_write <- safely(write_csv)

lookup_users("felix_lennert")

sliced %>% 
  pull(twitter) %>% 
  walk(~get_followers_tbl(.x) %>% 
         safe_write(., paste0("data/follower_data/", .x, ".csv")))
