#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# This is the code for the app for final project!

# import data and install packages
library(shiny)
library(ggplot2)
library(shinydashboard)
library(dplyr)
final_clean_nfl <- read.csv("final_clean_nfl.csv")

# making the IQR-capped salary data
q1 <- quantile(final_clean_nfl$Salary, 0.25) 
q3 <- quantile(final_clean_nfl$Salary, 0.75) 
iqr <- q3 - q1 
lower <- q1 - 1.5*iqr 
upper <- q3 + 1.5*iqr   
sal <- ifelse(final_clean_nfl$Salary < lower, lower, ifelse(final_clean_nfl$Salary > upper, upper, final_clean_nfl$Salary))
sort(sal)

# making the salary dataset with upper outliers removed to see a trend/significance
cutcap_nfl <- final_clean_nfl
cutcap_nfl$capSalary <- sal
cutcap_nfl <- cutcap_nfl %>%
  arrange(capSalary)
cutcap_nfl <- head(cutcap_nfl, 80)
cutcap_nfl <- cutcap_nfl %>%
  select(2, 14, 16)
colnames(cutcap_nfl) <- c("Player", "Catch_Rate", "Salary")

# making the datasets for other figures smaller to only contain the desired columns
Rec_final_clean_nfl <- final_clean_nfl %>%
  select(2, 3, 4)
colnames(Rec_final_clean_nfl) <- c("Player", "Receptions", "Yards")

TD_final_clean_nfl <- final_clean_nfl %>%
  select(2, 4, 5)
colnames(TD_final_clean_nfl) <- c("Player", "Yards", "Touchdowns")


#UI

ui_nfl <- fluidPage(
  titlePanel(title = "NFL 2024 Receiver Analysis"),
  tabsetPanel(
    tabPanel(
      "Salary Histogram", 
      sliderInput("bins", "Number of Bins:", min = 10, max = 50, value = 10),
      plotOutput("SalaryHist")
    ),
    tabPanel("Salary vs. Catch Rate", 
             plotOutput("Salary_catchRate", click = "Salary_catchRate_click"),
             textOutput("Salselect"),
             verbatimTextOutput("salinfo")
    ),
    tabPanel("Receptions vs. Yards", 
             plotOutput("Rec_Yds", click = "Rec_Yds_click"),
             textOutput("Recselect"),
             verbatimTextOutput("Recinfo")
    ),
    tabPanel("Touchdowns vs. Yards", 
             plotOutput("TD_Yds", click = "TD_Yds_click"),
             textOutput("TDselect"),
             verbatimTextOutput("TDinfo")
    )
  )
)

# SERVER

server_nfl<-function(input, output) {
  # interactive salary histogram
  output$SalaryHist <- renderPlot({
    salary_data <- cutcap_nfl$Salary
    ggplot(data = data.frame(x = salary_data), aes(x = cutcap_nfl$Salary)) +
      geom_histogram(fill = '#b2c655', color = "white", bins = input$bins) + # still need to add in the slider
      # green for $$
      theme_minimal() +
      labs(
        title = "Histogram of Capped NFL Receiver 2024 Salaries",
        x = "Capped Salary ($)",
        y = "Frequency"
      )
  })
  output$Salary_catchRate <- renderPlot({
    ggplot(cutcap_nfl, aes(x = Catch_Rate, y = Salary)) +
      geom_point(size = 3, color = '#FD5E48') +   # size is for size of the points
      labs(title = "Salary vs. Catch Rate",
           x = "Catch Rate",
           y = "2024 Salary ($)") +
      ylim(500000, 1505000) +
      # add a vertical line at the mean catch rate, because catch rate is normally distributed
      geom_vline(xintercept = mean(cutcap_nfl$Catch_Rate), color = "darkgrey") +
      theme_minimal() +
      # label the mean catch rate line
      annotate("text", label = "Mean Catch Rate", x = mean(cutcap_nfl$Catch_Rate) + 0.018, y = 1300000, color = "darkgrey")
  })
  output$Rec_Yds <- renderPlot({
    ggplot(Rec_final_clean_nfl, aes(x = Yards, y = Receptions)) +
      geom_point(size = 3, color = '#e5ba37') +   # size is for size of the points
      labs(title = "Receptions vs. Yards",
           x = "Yards",
           y = "Receptions") +
      ylim(30, 130) +
      xlim(300, 1800) +
      # add a vertical line at the median yards because skewed. 
      geom_vline(xintercept = median(Rec_final_clean_nfl$Yards), color = "darkgrey") +
      theme_minimal() +
      # label the median yards line
      annotate("text", label = "Median Yards", x = median(Rec_final_clean_nfl$Yards) + 65, y = 120, color = "darkgrey") 
  })
  output$TD_Yds <- renderPlot({
    ggplot(TD_final_clean_nfl, aes(x = Yards, y = Touchdowns)) +
      geom_point(size = 3, color = '#3d939c') +
      labs(title = "Touchdowns vs. Yards",
           x = "Yards",
           y = "Touchdowns") +
      ylim(0, 18) +
      xlim(300, 1800) +
      # add a vertical line at the median Yards because yards is skewed. 
      geom_vline(xintercept = median(TD_final_clean_nfl$Yards), color = "darkgrey") +
      theme_minimal() +
      # label the median yards line
      annotate("text", label = "Median Yards", x = median(TD_final_clean_nfl$Yards) + 65, y = 17, color = "darkgrey")
  })
  output$Salselect <- renderText({
    paste("You selected the point:")
  })
  output$Recselect <- renderText({
    paste("You selected the point:")
  })
  output$TDselect <- renderText({
    paste("You selected the point:")
  })
  output$salinfo <- renderPrint({
    nearPoints(cutcap_nfl, input$Salary_catchRate_click, threshold = 10, maxpoints = 1)
  })
  output$Recinfo <- renderPrint({
    nearPoints(Rec_final_clean_nfl, input$Rec_Yds_click, threshold = 10, maxpoints = 1)
  })
  output$TDinfo <- renderPrint({
    nearPoints(TD_final_clean_nfl, input$TD_Yds_click, threshold = 10, maxpoints = 1)
  })
}

# running the app
shinyApp(ui = ui_nfl, server = server_nfl)