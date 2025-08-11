# optionalSectionModule.R

# UI function
optionalSection_UI <- function(id, title, icon = NULL, subtitle = NULL, body_ui = NULL) {
  ns <- NS(id)

  tagList(
    div(class = "validation-section",

        # Header row with title and toggle
        fluidRow(
          column(9,
                 h4(tagList(icon, title)),
                 if (!is.null(subtitle)) p(class = "text-muted", subtitle),
                 tags$em("Optional section: slide toggle to skip")
          ),
          column(3, style = "text-align: right;",
                 checkboxInput(ns("enabled"), label = "Include", value = TRUE)
          )
        ),

        # Conditional content
        uiOutput(ns("section_body"))
    )
  )
}

# Server function
optionalSection_Server <- function(id, render_body = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$section_body <- renderUI({
      if (!isTRUE(input$enabled)) {
        return(div(class = "validation-feedback feedback-warning",
                   bs_icon("slash-circle"), "Section skipped"))
      }

      tagList(
        div(class = "validation-feedback feedback-success",
            bs_icon("check-circle"), "Section enabled"),
        if (!is.null(render_body)) render_body()
      )
    })

    # Return reactive flag
    return(reactive(input$enabled))
  })
}
