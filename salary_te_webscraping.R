
#load packages
library(rvest)
library(stringr)
library(robotstxt)


#set current url to collect Tight End data
current_url <- "https://www.spotrac.com/nfl/rankings/player/_/year/2024/position/te/sort/cap_base"  
paths_allowed(current_url)

#use read_html_live to pull from dynamically rendered js site
page <- read_html_live(current_url)

#identify player data
players_data <- page %>%
  html_nodes(".list-group-item")  

#make new data frame to hold the acquired player data
sal_data <- data.frame(Player = character(), Team = character(), Salary = character(), stringsAsFactors = FALSE)

#iterate through the players to pull data
for (player in players_data) {
  
 #pull player name
  player_name <- player %>%
    html_node(".link") %>%  
    html_text()
  
  #pull player team and position
  team_and_position <- player %>%
  html_node("small") %>%  
  html_text()
  
 #extract player salary
  salary <- player %>%
    html_node(".medium") %>%  
    html_text()
  
  #separate team and position
  team <- strsplit(team_and_position, ",")[[1]][1]  
  position <- strsplit(team_and_position, ",")[[1]][2]  
  
 #append to the data frame
  sal_data <- rbind(sal_data, data.frame(Player = player_name, Team = team, Salary = salary, stringsAsFactors = FALSE))
}


#print(sal_data)
#write to csv
write.csv(sal_data, "nfl_salary_te.csv", row.names = FALSE)