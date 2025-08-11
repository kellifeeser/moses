# Dynamic Layout Generation DynamicLayoutGeneration
ui <- fluidPage(
  # Include custom CSS
  tags$head(
    tags$style(HTML("
      .custom-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 8px;
      }

      .metric-box {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        padding: 20px;
        text-align: center;
        margin-bottom: 20px;
      }

      .metric-value {
        font-size: 2.5rem;
        font-weight: bold;
        color: #0d6efd;
      }

      .metric-label {
        font-size: 0.9rem;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
    "))
  ),

  # Custom header
  div(class = "custom-header",
      h1("Analytics Dashboard", style = "margin: 0;"),
      p("Real-time business metrics and insights", style = "margin: 0; opacity: 0.9;")
  ),

  # Custom metric boxes
  fluidRow(
    column(4,
           div(class = "metric-box",
               div(class = "metric-value", "1,234"),
               div(class = "metric-label", "Total Sales")
           )
    ),
    column(4,
           div(class = "metric-box",
               div(class = "metric-value", "89%"),
               div(class = "metric-label", "Success Rate")
           )
    ),
    column(4,
           div(class = "metric-box",
               div(class = "metric-value", "567"),
               div(class = "metric-label", "Active Users")
           )
    )
  )
)

server <- function(input, output, session) {

  # Generate dynamic UI based on user selection
  output$dynamic_layout <- renderUI({
    if (input$layout_style == "grid") {
      # Grid layout
      fluidRow(
        lapply(1:input$num_panels, function(i) {
          column(12 / input$num_panels,
                 wellPanel(
                   h4(paste("Panel", i)),
                   plotOutput(paste0("plot_", i), height = "300px")
                 )
          )
        })
      )
    } else if (input$layout_style == "tabs") {
      # Tabbed layout
      do.call(tabsetPanel,
              lapply(1:input$num_panels, function(i) {
                tabPanel(paste("Tab", i),
                         plotOutput(paste0("plot_", i), height = "400px"))
              })
      )
    } else {
      # Stacked layout
      div(
        lapply(1:input$num_panels, function(i) {
          div(
            h4(paste("Section", i)),
            plotOutput(paste0("plot_", i), height = "300px"),
            hr()
          )
        })
      )
    }
  })
}
