# touchdown predictions (sorted by actual number of touchdowns)
library(shiny)
library(DT)
library(readr)

ui <- fluidPage(
  titlePanel("Interactive Touchdown Predictions"),
  mainPanel(
    DTOutput("table")
  )
)


server <- function(input, output) {
  output$table <- renderDT({
    pred_td <- read_csv("./td_predictions.csv")[-1]
    datatable(pred_td, 
                       options=list(order = list(list(6, 'desc')),
                                    autoWidth=TRUE,
                                    dom='Bfrtip',
                                    buttons=c('csv', 'pdf', 'print')),
                       extensions = 'Buttons',
                       colnames=c("Player", "Receptions over 40 yds", 
                                  "1st Down Receptions", "Targets", 
                                  "Predicted Touchdowns", 
                                  "Actual Touchdowns","Actual - Predicted")) %>% 
      formatStyle('predicted', backgroundColor="lavender") %>%
      formatStyle('difference', backgroundColor=styleInterval(-1, c('mistyrose', 
                                                                   'white')))
    
  })
}

shinyApp(ui = ui, server = server)