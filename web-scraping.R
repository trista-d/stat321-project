library(rvest)
library(xml2)
library(robotstxt)
library(chromote)


nfl_link = "https://nfl.com"
current_url = "https://www.nfl.com/stats/player-stats/category/receiving/2024/reg/all/receivingreceptions/desc"

# check if scraping is allowed
paths_allowed(paths = current_url)


# get data
# Problem: webapge is not static (i.e. uses JavaScript to populate its data), so
#          when we use read_html() an empty webpage is returned
# Solution: use read_html_live() instead of read_html()
#           https://rvest.tidyverse.org/reference/LiveHTML.html

# filepath on your computer to a chromium-based browser
Sys.setenv(CHROMOTE_CHROME="C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe")

# for (i in 1:number_of_pages) {
  page <-  current_url %>% read_html_live()
  
  data <- page %>%
    html_nodes("table") %>%
    html_table()
  data

  # append rows of data onto a dataframe
  
  # update current_url: read next url from href attribute of "Next Page" button
# }


# write dataframe to csv file