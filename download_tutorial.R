# Download tweets using rtweet::search_fullarchive() in 12 steps

# 0) Important aspects of Twitter's premium search API

# Query-String rules
# a) "foo bar" -> returns result if both words in tweet, order does not matter 
#              -> "i like bar foo", "foo I like bar"
# b) caps insensitive  ->  returns "Foo Bar", "FoO, BaR", ...
# c) #hashtag -> returns "#hashtag" and not "hashtag"

# Variables "from" and "to" as timeframes of the search
# a) format "yyyymmddhhmm" -> accurate to the minute
# b) API searches chronologically backwards -> update "to", not "from" after a query
# c) all timestamps are standardized to UTC / GMT "Greenwich, London" time

# 1) Make sure to download the rtweet package GitHub fix on your machine
#    to be able to send as many requests as you have actually paid for in
#    the premium API

# remove.packages("rtweet")
# library(devtools)
# remotes::install_github("conradborchers/rtweet")

# 2) Post a tweet to your timeline to check connection to your API

# library(rtweet)
# post_tweet("This is a test.")

# 3) Setup

rm(list=ls())

library(rtweet)
library(magrittr) # %>%

# setwd("C:/")

# 4) Find your developer premium environment label under your developer Twitter account
#    and store it in the variable "env_name"

# env_name <- "string" 

# 5) Custom download functions

# 6) Insert the hashtag you would like to download into the function below

tweetdownload <- function(from, to){
  search_fullarchive(q="#hashtag", n=500, fromDate = from,  # set hashtag
                     toDate = to, env_name = env_name)
}

# 7) Transformation and save functions

## UTC2frame() - Transforms timestamp in data frame to yyyymmddhhmm query

UTC2frame <- function(datetime){
  frame <- strftime(datetime,"%Y-%m-%d %H:%M:%S", tz="UTC")
  frame <- substr(frame, 1, nchar(frame) - 3)
  frame <- gsub("-", "", frame)
  frame <- gsub(":", "", frame)
  frame <- gsub(" ", "", frame)
  return(frame)
}

## save_rda_dl() - Creates a .rda file of your download

# 8) Insert your hashtag or preferred file name to the variable
#    "stampstring" below. Other than that, the filename will display
#    the timerange of the tweets that you have downloaded

save_rda_dl <- function(tweets_dl, stampstring="hashtag_"){   # set hastag for filename
  first <- tweets_dl$created_at %>% min() %>% UTC2frame() 
  last <- tweets_dl$created_at %>% max() %>% UTC2frame()
  
  file_name <- paste(stampstring, "DATA_", first, "_TO_", last, ".rda", sep="")  
  
  save(tweets_dl, file = file_name) 
}

## save_rds_dl() if you prefer .rds format

save_rds_dl <- function(tweets_dl, stampstring="hashtag_"){   # set hastag for filename
  first <- tweets_dl$created_at %>% min() %>% UTC2frame() 
  last <- tweets_dl$created_at %>% max() %>% UTC2frame()
  
  file_name <- paste(stampstring, "DATA_", first, "_TO_", last, ".rds", sep="") 
  
  saveRDS(tweets_dl, file = file_name) 
}

# 9) Downloading

# 10) Insert the timeframes you would like to start with below

from <- "200603220000" # yyyymmddhhmm 
to <- "201912312359"  

# 11) The following 6 lines of code download up to 2,500 tweets
#     starting chronologically backwards from the variable "to", 
#     then save the download in an .rda file, update the variable "to",
#     for the next download and then print a status update.
#     Normally your download is complete once you have reached a return
#     of less than 2,500 tweets in an iteration.

#     You can either paste the code over and over manually to your R
#     console or, if you are sure your targeted data is huge enough,
#     apply a while loop like this:

# n = 0
# while (n < 10){   # do 10 times
#   # code goes here
#
#   n = n+1         # do not forget to insert this variable update
# }

###################################################################################

# tweets_dl <- tweetdownload(from, to) 
# save_rda_dl(tweets_dl)
# to <- tweets_dl$created_at %>% min() %>% UTC2frame()
downloaded <- nrow(tweets_dl)
print(paste(c("Download included ", downloaded, " tweets."), sep=""))
print(paste(c("Next download is initiated starting backwards from ", to), sep=""))

###################################################################################

# 12) Optionally merge all data frames to a single one
#     This example code works on .rda files

fn1 <- dir(pattern="hashtag_*")

full <- NULL

for (fn in fn1){
  load(fn)
  full <- rbind(full, tweets_dl)
}

tweets_dl <- full

# tweets_dl <- tweets_dl[order(tweets_dl$created_at),]  # order by time of creation

# save_rda_dl(tweets_dl, "ALL_hashtag_")
