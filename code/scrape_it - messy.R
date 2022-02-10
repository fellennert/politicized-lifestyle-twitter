library(tidyverse)
#devtools::install_github("cjbarrie/academictwitteR", build_vignettes = TRUE)
library(academictwitteR)
library(rtweet)
library(fs)

# retain old stuff
names <- dir_ls("/Volumes/Transcend/remaining_followers") %>% 
  str_remove_all("\\/Volumes\\/Transcend\\/remaining\\_followers\\/|\\.csv")

file_list <- map(dir_ls("/Volumes/Transcend/remaining_followers"), read_csv, show_col_types = FALSE)

scraped <- map_lgl(file_list, ~nrow(.x) < 5000)
names[scraped]
files_to_move <- file_list[str_detect(names(file_list), str_c(names[scraped], collapse = "|"))]
to_move <- names(files_to_move)
to_write <- str_replace(to_move, "remaining\\_followers", "final_scrape")

walk2(to_move, to_write, file_move)

scraped_tbls <- follower_files[scraped] 
scraped_names <- names[scraped]
##
politicians <- read_csv("data/politicians_tbl.csv")

already_scraped <- dir_ls("/Volumes/Transcend/final_scrape") %>% 
  str_remove_all("\\/Volumes\\/Transcend\\/final\\_scrape\\/|\\.csv")

to_scrape <- politicians$twitter [!politicians$twitter %in% already_scraped]

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

safe_write <- safely(write_csv)
  
#scrape_call
map(to_scrape, ~get_followers_tbl(.x) %>% 
       safe_write(., paste0("/Volumes/Transcend/temp_scrape/", .x, ".csv")))
