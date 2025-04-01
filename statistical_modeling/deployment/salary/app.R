# salary predictions (sorted by actual salary)
library(shiny)
library(DT)
library(readr)

ui <- fluidPage(
  titlePanel("Interactive Salary Predictions"),
  mainPanel(
    DTOutput("table")
  )
)


server <- function(input, output) {
  output$table <- renderDT({
    pred_salary <- read_csv("./salary_predictions.csv")[-1]
    datatable(pred_salary, 
                           options=list(order = list(list(4, 'desc')),
                                        autoWidth=TRUE,
                                        dom='Bfrtip',
                                        buttons=c('csv', 'pdf', 'print')),
                           extensions = 'Buttons',
                           colnames=c("Player", "Catch Rate", "Predicted Salary", 
                                      "Actual Salary", "|Actual - Predicted|"))%>% 
    formatStyle('predicted', backgroundColor="lavender")
    
  })
}

shinyApp(ui = ui, server = server)