#import the libraries
library(rvest)
library(xml2)
library(robotstxt)
library(chromote)

#set up links to scrape nfl player data
nfl_link = "https://www.nfl.com"
current_url = "https://www.nfl.com/stats/player-stats/category/receiving/2024/reg/all/receivingreceptions/desc"

# Check if scraping is allowed
paths_allowed(paths = current_url)



#initialize an empty data frame
all_data <- data.frame()

#loop through and scrape data, 20 was set manually by inspection
for (i in 1:20) {  
  
  #get page content
  page <- current_url %>% read_html_live()
  
  #Extract data
  data <- page %>%
    html_nodes("table") %>%
    html_table()
  
  
  #Add the data to the data frame
  all_data <- rbind(all_data, data[[1]])  
  
  
  #find 'next' page link
  next_page_link <- page %>%
    html_nodes("a.nfl-o-table-pagination__next") %>%  
    html_attr("href")
  
  
  #Check if the extracted link is a relative URL
  if (substr(next_page_link, 1, 1) == "/") {
    #concatenate the relative link to the original link
    next_page_link <- paste0(nfl_link, next_page_link)
  }
  
  
  #Update current url to next page link
  current_url <- next_page_link
}

#write data to a csv file
write.csv(all_data, "nfl_receiving_data.csv", row.names = FALSE)

#print(all_data)
