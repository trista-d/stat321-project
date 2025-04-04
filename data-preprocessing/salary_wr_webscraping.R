#import libraries
library(rvest)
library(stringr)
library(robotstxt)


#set current url for wide receiver data
current_url <- "https://www.spotrac.com/nfl/rankings/player/_/year/2024/position/wr/sort/cap_base"  
paths_allowed(current_url)

#load url
page <- read_html_live(current_url)

#identify data tags
players_data <- page %>%
  html_nodes(".list-group-item")  

#set the new data frame
sal_data <- data.frame(Player = character(), Team = character(), Salary = character(), stringsAsFactors = FALSE)

#iterate through the page
for (player in players_data) {
  
  #isolate player name
  player_name <- player %>%
    html_node(".link") %>%  
    html_text()
  
  #isolate team and position
  team_and_position <- player %>%
    html_node("small") %>%  
    html_text()
  
  #isolate salary
  salary <- player %>%
    html_node(".medium") %>%  
    html_text()
  
  #seperate team and position
  team <- strsplit(team_and_position, ",")[[1]][1]  
  position <- strsplit(team_and_position, ",")[[1]][2]  
  
  #add data to data frame
  sal_data <- rbind(sal_data, data.frame(Player = player_name, Team = team, Salary = salary), stringsAsFactors = FALSE)
}


#print(sal_data)
#write to csv
write.csv(sal_data, "nfl_salary_wr5.csv", row.names = FALSE)