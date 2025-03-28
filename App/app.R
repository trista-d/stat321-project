#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#


# This is the code for the histogram app for final project!
# May need to change what is actually presented in the histograms depending on how Trista deals with the data. 

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

#UI - reference for the icons: https://fontawesome.com/search?q=ball&o=r&ic=free&s=solid&ip=classic

ui_nfl <- fluidPage(
  titlePanel(title = "NFL 2024 Receiver Analysis"),
  tabsetPanel(
    tabPanel(
      "Salary Histogram", 
      sliderInput("bins", "Number of Bins:", min = 10, max = 50, value = 10),
      plotOutput("SalaryHist")
    ),
    tabPanel("Salary vs. Catch Rate", 
             plotOutput("Salary_catchRate")
    ),
    tabPanel("Receptions vs. Yards", 
             plotOutput("Rec_Yds")
    ),
    tabPanel("Touchdowns vs. Yards", 
             plotOutput("TD_Yds")
    )
  )
)


# will try doing something like this maybe so that the scatterplots are also interactive (but not just with a silly slider bar)
library(ggplot2)
ui <- basicPage(
  plotOutput("plot1", click = "plot_click"),
  verbatimTextOutput("info")
)

server <- function(input, output) {
  output$plot1 <- renderPlot({
    ggplot(mtcars, aes(x=wt, y=mpg)) + geom_point()
  })
  
  output$info <- renderPrint({
    # With ggplot2, no need to tell it what the x and y variables are.
    # threshold: set max distance, in pixels
    # maxpoints: maximum number of rows to return
    # addDist: add column with distance, in pixels
    nearPoints(mtcars, input$plot_click, threshold = 10, maxpoints = 1,
               addDist = TRUE)
  })
}

shinyApp(ui, server)




# SERVER

server_nfl<-function(input, output) {
  # interactive salary histogram
  output$SalaryHist <- renderPlot({
    salary_data <- cutcap_nfl$capSalary
    ggplot(data = data.frame(x = salary_data), aes(x = cutcap_nfl$capSalary)) +
      geom_histogram(fill = '#009E73', color = "white", bins = input$bins) + # still need to add in the slider
      # green for $$
      theme_minimal() +
      labs(
        title = "Histogram of Capped NFL Receiver 2024 Salaries",
        x = "Capped Salary ($)",
        y = "Frequency"
      )
  })
  output$Salary_catchRate <- renderPlot({
    ggplot(cutcap_nfl, aes(x = catchRate, y = capSalary)) +
      geom_point(size = 3, color = '#D55E00') +   # size is for size of the points
      labs(title = "Salary vs. Catch Rate",
           x = "Catch Rate",
           y = "2024 Salary ($)") +
      ylim(500000, 1505000) +
      # add a vertical line at the mean catch rate, mean because normally distributed catch rate
      geom_vline(xintercept = mean(cutcap_nfl$catchRate), color = "grey") +
      theme_minimal() +
      # label the players with highest catch rates
      geom_text(label = ifelse(cutcap_nfl$catchRate > 0.90, cutcap_nfl$Player, ''), hjust = 0.7, vjust = -1) +
      annotate("text", label = "Mean Catch Rate", x = mean(cutcap_nfl$catchRate), y = 1500000, color = "grey")
  })
  output$Rec_Yds <- renderPlot({
    ggplot(final_clean_nfl, aes(x = Yds, y = Rec)) +
      geom_point(size = 3, color = '#D55E00') +   # size is for size of the points
      labs(title = "Receptions vs. Yards",
           x = "Yards",
           y = "Receptions") +
      ylim(30, 130) +
      xlim(300, 1800) +
      # add a vertical line at the median yards because skewed. 
      geom_vline(xintercept = median(final_clean_nfl$Yds), color = "grey") +
      theme_minimal() +
      # label the players with highest number of yards
      geom_text(label = ifelse(final_clean_nfl$Yds > 1500, final_clean_nfl$Player, ''), hjust = 0.7, vjust = -1) +
      annotate("text", label = "Median Yds", x = median(final_clean_nfl$Yds), y = 120, color = "grey") 
  })
  output$TD_Yds <- renderPlot({
    ggplot(final_clean_nfl, aes(x = Yds, y = TD)) +
      geom_point(size = 3, color = '#D55E00') +   # size is for size of the points
      labs(title = "TD vs. Yds",
           x = "Yds",
           y = "TD") +
      ylim(0, 18) +
      xlim(300, 1800) +
      # add a vertical line at the median Yards because yards is skewed. 
      geom_vline(xintercept = mean(final_clean_nfl$Yds), color = "grey") +
      theme_minimal() +
      # label the players with highest number of yards
      geom_text(label = ifelse(final_clean_nfl$Yds > 1500, final_clean_nfl$Player, ''), hjust = 0.7, vjust = -1) +
      annotate("text", label = "Mean Yds", x = mean(final_clean_nfl$Yds), y = 17, color = "grey")
  })
}

# running the app
shinyApp(ui = ui_nfl, server = server_nfl)

