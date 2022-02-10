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

#mp_list_api <- map(mp_list$api_link, ~safe_read(.x) %>% pluck(1))

twitter_data <- mp_list %>% 
  filter(!is.na(twitter)) %>% 
  select(name = nom, id, twitter, twitter_followers, groupe_sigle) %>% 
  arrange(twitter_followers) %>% 
  left_join(lookup_users(mp_list$twitter) %>% select(user_id, screen_name), by = c("twitter" = "screen_name"))

politicians_tbl <- map(mp_list_api, ~select(.x, name = nom, id, twitter, groupe_sigle)) %>% bind_rows()

names <- read_csv("data/politicians_tbl.csv")

# scrape it

## functions
add_10 <- function(n) n + 10

get_followers_tbl <- function(twitter_name) {
  tibble(
    user_id = lookup_users(twitter_name) %>% pull(user_id),
    followers = get_followers(
      user = twitter_name, 
      n = lookup_users(twitter_name) %>% pull(followers_count) %>% add_10(), 
      retryonratelimit = TRUE) %>% 
      pull(user_id)
  )
}



#scrape_call
already_scraped <- dir_ls("/Volumes/Transcend/final_scrape") %>% 
  str_remove_all("\\/Volumes\\/Transcend\\/final\\_scrape\\/|\\.csv")

to_scrape <- names$twitter[!names$twitter %in% already_scraped]

to_scrape[[3]] <- "chevenement"

walk(to_scrape[[3]], ~get_followers_tbl(.x) %>% 
      safe_write(., paste0("/Volumes/Transcend/temp_scrape/", .x, ".csv")))


## get friends

follower_list <- read_csv("data/distinct-followers.csv") %>% 
  mutate(followers = as.character(followers))

follower_list$followers[[2]]

get_friends(c("12", "1000"))

scrape_list_ge10 <- follower_list %>% filter(n > 9) %>% pull(followers) %>% split(., ceiling(seq_along(.)/15))

scrape_list_ge10[[1]] 


