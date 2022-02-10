# acquire-friends

library(tidyverse)
library(rtweet)
safe_write <- safely(write_csv)

create_token(
  app = "IAS stuff",
  "sTjeg12FwfnsaLD6cGItgWQVj",
  "zQcztiKgos2vHLdh0UPkuzcGhFDwlijRNslgvLBnuml1NPHbwM",
  access_token = "3376407556-H5smcMlRAY60gQE82YbfXEPdIVBiRpnyrOVlPFk",
  access_secret = "GKdNFPPE35hczzO8me8YrPqPiBv7HMHzkeBiN26ijYpOi",
  set_renv = F
)

follower_list <- read_csv("data/distinct-followers.csv") %>% 
  mutate(followers = as.character(followers))

scrape_list_ge10 <- follower_list %>% filter(n > 9) %>% pull(followers) %>% split(., ceiling(seq_along(.)/15))

scrape_list_ge10 <- set_names(scrape_list_ge10, as.character(1:length(scrape_list_ge10)))

walk2(scrape_list_ge10, names(scrape_list_ge10), ~{get_friends(.x, retryonratelimit = TRUE) %>% 
    safe_write(str_c("data/friend-data/", .y, ".csv"))})
