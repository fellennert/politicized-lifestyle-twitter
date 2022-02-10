library(tidyverse)
library(rtweet)
library(fs)

media_list <- read_csv("https://raw.githubusercontent.com/medialab/corpora/master/polarisation/medias.csv") %>%
  separate_rows(start_pages, sep = "\\|", convert = TRUE) %>% 
  mutate(twitter = str_extract(start_pages, "(?<=twitter\\.com\\/).+$") %>% 
           str_to_lower() %>% 
           str_remove("hashtag\\/")) %>% 
  distinct(name, twitter, .keep_all = TRUE) %>% 
  filter(!is.na(twitter))
                       
twitter_id <- media_list %>% 
  pull(twitter)

# scrape them
add_10 <- function(n) n + 10
safe_write <- safely(write_csv)

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

already_scraped <- dir_ls("/Volumes/Transcend/final_scrape") %>% 
  str_remove_all("\\/Volumes\\/Transcend\\/final\\_scrape\\/|\\.csv")

to_scrape <- twitter_id[!twitter_id %in% already_scraped]

walk(to_scrape, ~get_followers_tbl(.x) %>% 
       safe_write(., paste0("/Volumes/Transcend/temp_scrape/", .x, ".csv")))
