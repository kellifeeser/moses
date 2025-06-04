mod_barplot_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Taxa Barplot"),
    plotOutput(ns("plot"))
  )
}

mod_barplot_server <- function(id, data_r) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      req(data_r())
      barplot(c(5, 3, 8, 2),
              names.arg = c("Taxa A","B","C","D"),
              main = "Taxonomy Barplots")
    })
  })
}
