# UI Module Function
optionalSectionUI <- function(id, title, icon = NULL, subtitle = NULL, body_ui = NULL) {
  ns <- NS(id)

  tagList(
    div(class = "validation-section",

        # Title row (left) and checkbox + label (right)
        fluidRow(
          column(9,
                 h4(tagList(icon, title)),
                 if (!is.null(subtitle)) p(class = "text-muted", subtitle)
          ),
          column(3,
                 div(
                   style = "display: flex; justify-content: flex-end; align-items: center; gap: 8px;",
                   span("Optional section: uncheck to skip",
                        style = "font-style: italic; font-size: 0.85em;"),
                   checkboxInput(ns("enabled"), label = "Include", value = TRUE)
                 )
          )
        ),

        # Section body
        uiOutput(ns("section_body"))
    )
  )
}

# Server Module Function
optionalSectionServer <- function(id, render_body = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$section_body <- renderUI({
      if (!isTRUE(input$enabled)) {
        return(div(class = "validation-feedback feedback-warning",
                   span("⛔ Section skipped")))
      }

      tagList(
        # div(class = "validation-feedback feedback-success"#,
        #     # span("✅ Section enabled")
        #     ),
        if (!is.null(render_body)) render_body()
      )
    })

    # Return reactive TRUE/FALSE to track toggle state
    return(reactive(input$enabled))
  })
}
