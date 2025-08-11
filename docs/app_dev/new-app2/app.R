library(shiny)
library(ggplot2)
library(gridlayout)
library(bslib)
library(DT)


ui <- grid_page(
  layout = c(
    "header  header    ",
    "sidebar areaReadin",
    ".       area3     "
  ),
  row_sizes = c(
    "100px",
    "1.73fr",
    "0.27fr"
  ),
  col_sizes = c(
    "260px",
    "1fr"
  ),
  gap_size = "1rem",
  grid_card(
    area = "sidebar",
    card_header("Data Upload Completion"),
    card_body(
      card(
        full_screen = TRUE,
        card_header(strong("ASV/OTU Counts Table")),
        card_body("Bacteria/Archaea (16S):")
      ),
      sliderInput(
        inputId = "numChicks",
        label = "Number of Chicks",
        min = 1,
        max = 15,
        value = 5,
        width = "100%",
        step = 1
      ),
      radioButtons(
        inputId = "distFacet",
        label = "Facet Distribution By",
        choices = list("Diet Type" = "Diet", "Measure Time" = "Time")
      ),
      textOutput(outputId = "textOutput")
    )
  ),
  grid_card_text(
    area = "header",
    content = "Uploading Input Files",
    alignment = "center",
    is_title = FALSE
  ),
  grid_card(
    area = "areaReadin",
    full_screen = FALSE,
    card_body(
      min_height = "100px",
      gap = "10px",
      card(
        full_screen = TRUE,
        card_header(
          tabsetPanel(
            nav_panel(
              title = "ASV/OTU counts table",
              strong("Formatting requirements:  samples as rows and taxa as columns")
            ),
            nav_panel(
              title = "Sample Metadata",
              strong("Formatting requirements:  samples as rows and metadata factors/variables as columns")
            )
          ),
          "Read-in .csv or .txt files ",
          strong("")
        ),
        card_body(
          min_height = "100px",
          grid_container(
            layout = c(
              "area0                      area1                     ",
              "area2                      .                         ",
              "areaUploadBacPreviewcounts areaUploadFunPreviewcounts"
            ),
            gap_size = "10px",
            col_sizes = c(
              "1fr",
              "1fr"
            ),
            row_sizes = c(
              "0.40000000000000013fr",
              "2.000000000000001fr",
              "1fr"
            ),
            grid_card_text(
              content = "Bacteria/Archaea (16S)",
              alignment = "center",
              area = "area0"
            ),
            grid_card_text(
              content = "Fungi (18S/ITS)",
              alignment = "center",
              area = "area1"
            ),
            grid_card(
              area = "area2",
              card_body(
                actionButton(inputId = "myButton", label = "My Button"),
                radioButtons(
                  inputId = "myRadioButtonsFileSep",
                  label = "Select file separator",
                  choices = list("Comma" = ",", "Semicolon" = ";", "Tab" = "\\\\t"),
                  width = "90%"
                )
              ),
              card_footer(
                selectInput(
                  inputId = "mySelectRowsToDisplay",
                  label = "Select # of rows to display",
                  choices = list("Head" = "head", "All" = "all"),
                  selected = "all",
                  width = "85%"
                )
              )
            ),
            grid_card(
              area = "areaUploadBacPreviewcounts",
              card_body(DTOutput(outputId = "myTable", width = "100%"))
            ),
            grid_card(
              area = "areaUploadFunPreviewcounts",
              card_body(DTOutput(outputId = "myTable", width = "100%"))
            )
          )
        )
      )
    )
  ),
  grid_card(
    area = "area3",
    full_screen = TRUE,
    card_header("Header")
  )
)


server <- function(input, output) {
   
  output$linePlots <- renderPlot({
    obs_to_include <- as.integer(ChickWeight$Chick) <= input$numChicks
    chicks <- ChickWeight[obs_to_include, ]
  
    ggplot(
      chicks,
      aes(
        x = Time,
        y = weight,
        group = Chick
      )
    ) +
      geom_line(alpha = 0.5) +
      ggtitle("Chick weights over time")
  })
  
  output$dists <- renderPlot({
    ggplot(
      ChickWeight,
      aes(x = weight)
    ) +
      facet_wrap(input$distFacet) +
      geom_density(fill = "#fa551b", color = "#ee6331") +
      ggtitle("Distribution of weights by diet")
  })
}

shinyApp(ui, server)
  

