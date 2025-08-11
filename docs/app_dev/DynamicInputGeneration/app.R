# Dynamic Input Generation

# UI
numericInput("num_variables", "Number of Variables:", value = 3, min = 1, max = 10),
uiOutput("dynamic_variables")

# Server logic for dynamic input generation
output$dynamic_variables <- renderUI({
  req(input$num_variables)

  # Generate inputs dynamically
  input_list <- lapply(1:input$num_variables, function(i) {
    div(
      class = "row",
      div(
        class = "col-sm-6",
        textInput(paste0("var_name_", i),
                  label = paste("Variable", i, "Name:"),
                  value = paste0("Variable_", i))
      ),
      div(
        class = "col-sm-3",
        selectInput(paste0("var_type_", i),
                    label = "Type:",
                    choices = c("Numeric", "Character", "Factor"),
                    selected = "Numeric")
      ),
      div(
        class = "col-sm-3",
        numericInput(paste0("var_default_", i),
                     label = "Default:",
                     value = 0)
      )
    )
  })

  div(
    h4("Variable Configuration:"),
    do.call(tagList, input_list)
  )
})

# Collect dynamic input values
observe({
  req(input$num_variables)

  # Collect all dynamic input values
  variable_config <- data.frame(
    name = sapply(1:input$num_variables, function(i) {
      input[[paste0("var_name_", i)]] %||% paste0("Variable_", i)
    }),
    type = sapply(1:input$num_variables, function(i) {
      input[[paste0("var_type_", i)]] %||% "Numeric"
    }),
    default = sapply(1:input$num_variables, function(i) {
      input[[paste0("var_default_", i)]] %||% 0
    }),
    stringsAsFactors = FALSE
  )

  # Store configuration for use in other parts of the app
  values$variable_config <- variable_config
})
