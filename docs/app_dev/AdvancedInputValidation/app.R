# Advanced Input Validation Workshop
# Comprehensive demonstration of validation patterns and user feedback

library(shiny)
library(bsicons)
library(bslib)
library(DT)
library(tools)

ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),

  tags$head(
    tags$style(HTML("
        .file-upload-area {
        border: 2px dashed #ccc;
        border-radius: 10px;
        padding: 30px;
        text-align: center;
        background: #fafafa;
        transition: all 0.3s ease;
      }

      .file-upload-area:hover {
        border-color: #007bff;
        background: #f0f8ff;
      }

      .upload-instructions {
        color: #666;
        margin-top: 10px;
      }

      .file-preview {
        margin-top: 20px;
        padding: 20px;
        background: #f8f9fa;
        border-radius: 8px;
        border: 1px solid #dee2e6;
      }

      .validation-section {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 20px;
      }
      .validation-feedback {
        margin-top: 8px;
        padding: 8px 12px;
        border-radius: 4px;
        font-size: 0.9em;
      }
      .feedback-success {
        background: #d1edff;
        border: 1px solid #0ea5e9;
        color: #0369a1;
      }
      .feedback-warning {
        background: #fef3c7;
        border: 1px solid #f59e0b;
        color: #92400e;
      }
      .feedback-danger {
        background: #fee2e2;
        border: 1px solid #ef4444;
        color: #dc2626;
      }
      .password-requirements {
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        border-radius: 6px;
        padding: 15px;
        margin-top: 10px;
      }
      .requirement-item {
        margin: 5px 0;
        font-size: 0.9em;
      }
      .form-summary {
        background: white;
        border: 2px solid #007bff;
        border-radius: 8px;
        padding: 20px;
        position: sticky;
        top: 20px;
      }
      .strength-meter {
        height: 8px;
        background: #e9ecef;
        border-radius: 4px;
        overflow: hidden;
        margin: 10px 0;
      }
      .strength-fill {
        height: 100%;
        transition: all 0.3s ease;
      }
    "))
  ),

  div(class = "container-fluid",
      h2(bs_icon("shield-check"), "Sample Metadata Upload and Validation",
         class = "text-center mb-4"),
      p("Upload, process, and validate sample metadata file(s) | Compatible with single and dual kingdom metadata (a.k.a mapping) files.",
        class = "text-center lead text-muted mb-4"),
      p("Compatible with single and dual kingdom metadata (a.k.a mapping) files.",
        class = "text-center lead text-muted"),

      fluidRow(
        # Validation Examples Column
        column(8,

               div(class = "validation-section",
                   h4(bs_icon("file-earmark-medical"), "Metadata Upload Configuration"),
                   p("Specify the structure of your metadata files and how they map to ASV/OTU tables.",
                     class = "text-muted"),

                   radioButtons("kingdom_mode", "How many kingdoms are you processing?",
                                choices = c("Single Kingdom", "Dual Kingdom"),
                                selected = "Single Kingdom",
                                inline = TRUE),

                   conditionalPanel(
                     condition = "input.kingdom_mode == 'Dual Kingdom'",

                     radioButtons("dual_file_mode", "How is your metadata structured?",
                                  choices = c("One file with paired kingdom info",
                                              "Two separate metadata files"),
                                  selected = "One file with paired kingdom info",
                                  inline = FALSE),

                     conditionalPanel(
                       condition = "input.dual_file_mode == 'Two separate metadata files'",

                       textInput("shared_key", "Shared column key to join the two metadata files:",
                                 placeholder = "e.g., SampleID")
                     )
                   ),

                   # Ask for sample name columns per kingdom
                   conditionalPanel(
                     condition = "input.kingdom_mode == 'Single Kingdom'",
                     textInput("sample_col_single", "Which column matches the ASV/OTU sample names? (i.e., the shared key)",
                               placeholder = "e.g., SampleID")
                   ),

                   conditionalPanel(
                     condition = "input.kingdom_mode == 'Dual Kingdom'",
                     textInput("sample_col_bacteria", "Column name for sample IDs (16S / Bacteria-Archaea):",
                               placeholder = "e.g., BactSample"),
                     textInput("sample_col_fungi", "Column name for sample IDs (18S/ITS / Fungi):",
                               placeholder = "e.g., FungSample")
                   ),

                   hr(),
                   h4("Metadata File Format Requirements:"),
                   strong("Samples as rows and metadata factors/variables as columns. Dual kingdom processing requires a shared key (file column) that joins paired samples and a key that maps sample ASV/OTU table row names from each kingdom to their corresponding shared sample metadata. ")
               ),

               # Advanced file upload interface
               div(
                 class = "file-upload-area",
                 fileInput(
                   inputId = "advanced_upload",
                   label = NULL,
                   accept = c(".csv", ".txt", ".xlsx"),
                   width = "80%"
                 ),
                 div(
                   class = "upload-instructions",
                   icon("cloud-upload", class = "fa-3x"),
                   h5("Drag & Drop or Click to Upload"),
                   p("Supported formats: CSV, TXT, and Excel (Max 25MB)")
                 )
               ),
               uiOutput("file_preview"),


               # Email Validation
               div(class = "validation-section",
                   h4(bs_icon("envelope"), "Email Validation"),
                   p("Test email format validation with instant feedback", class = "text-muted"),

                   textInput("email_input", "Email Address:",
                             placeholder = "Enter your email address"),
                   uiOutput("email_feedback")
               ),

               # Password Validation
               div(class = "validation-section",
                   h4(bs_icon("key"), "Password Strength Validation"),
                   p("Experience comprehensive password validation with visual feedback", class = "text-muted"),

                   passwordInput("password_input", "Create Password:",
                                 placeholder = "Enter a secure password"),
                   passwordInput("password_confirm", "Confirm Password:",
                                 placeholder = "Re-enter your password"),

                   uiOutput("password_validation")
               ),

               # Numeric Range Validation
               div(class = "validation-section",
                   h4(bs_icon("123"), "Numeric Range Validation"),
                   p("Validate numeric inputs with custom constraints", class = "text-muted"),

                   fluidRow(
                     column(6,
                            numericInput("age_input", "Age (13-120):",
                                         value = NULL, min = 13, max = 120)
                     ),
                     column(6,
                            numericInput("salary_input", "Annual Salary ($):",
                                         value = NULL, min = 0, step = 1000)
                     )
                   ),
                   uiOutput("numeric_feedback")
               ),

               # Custom Business Logic Validation
               div(class = "validation-section",
                   h4(bs_icon("building"), "Business Logic Validation"),
                   p("Complex validation with interdependent fields", class = "text-muted"),

                   fluidRow(
                     column(6,
                            selectInput("country_input", "Country:",
                                        choices = c("", "USA", "Canada", "UK", "Germany", "France"))
                     ),
                     column(6,
                            textInput("postal_code", "Postal/ZIP Code:",
                                      placeholder = "Enter postal code")
                     )
                   ),
                   fluidRow(
                     column(6,
                            dateInput("start_date", "Start Date:", value = Sys.Date())
                     ),
                     column(6,
                            dateInput("end_date", "End Date:", value = Sys.Date() + 30)
                     )
                   ),
                   uiOutput("business_logic_feedback")
               ),

               # Form Submission
               div(class = "validation-section",
                   h4(bs_icon("check-circle"), "Form Submission"),
                   p("Complete form validation before submission", class = "text-muted"),

                   div(class = "d-grid",
                       actionButton("submit_form", "Submit Form",
                                    class = "btn-primary btn-lg",
                                    disabled = TRUE)
                   ),
                   uiOutput("submission_feedback")
               )
        ),

        # Validation Summary Column
        column(4,
               div(class = "form-summary",
                   h4(bs_icon("clipboard-data"), "Validation Summary"),

                   h5("Field Status:"),
                   uiOutput("validation_summary"),

                   hr(),

                   h5("Form Metrics:"),
                   div(
                     strong("Valid Fields: "), textOutput("valid_count", inline = TRUE), "/7",
                     br(),
                     strong("Error Count: "), textOutput("error_count", inline = TRUE),
                     br(),
                     strong("Completion: "), textOutput("completion_percent", inline = TRUE), "%"
                   ),

                   hr(),

                   h5("Quick Actions:"),
                   div(
                     actionButton("fill_valid", "Fill Valid Data",
                                  class = "btn-outline-success btn-sm mb-2 w-100"),
                     actionButton("fill_invalid", "Fill Invalid Data",
                                  class = "btn-outline-danger btn-sm mb-2 w-100"),
                     actionButton("clear_all", "Clear All",
                                  class = "btn-outline-secondary btn-sm w-100")
                   ),

                   hr(),

                   h5("Validation Tips:"),
                   div(class = "small text-muted",
                       tags$ul(
                         tags$li("File Uploads: .txt file must be tab-separated"),
                         tags$li("Email: Must contain @ and valid domain"),
                         tags$li("Password: 8+ chars, mixed case, number, special"),
                         tags$li("Age: Between 13-120 years"),
                         tags$li("Dates: End date must be after start date"),
                         tags$li("Postal: Format depends on selected country")
                       )
                   )
               )
        )
      )
  )
)

server <- function(input, output, session) {

  # Reactive values for validation state
  validation <- reactiveValues(
    email = FALSE,
    password = FALSE,
    password_match = FALSE,
    age = FALSE,
    salary = FALSE,
    country_postal = FALSE,
    date_range = FALSE
  )

  # reactive list to hold metadata
  values <- reactiveValues(
    uploaded_data = NULL,
    metadata_single = NULL,
    metadata_bacteria = NULL,
    metadata_fungi = NULL
  )

  # single v dual kingdom
  observe({
    req(values$uploaded_data)

    if (input$kingdom_mode == "Single Kingdom") {
      values$metadata_single <- values$uploaded_data
    } else if (input$dual_file_mode == "Two separate metadata files") {
      # you'd need to support a second fileInput and parse it similarly
      values$metadata_bacteria <- values$uploaded_data  # placeholder
      values$metadata_fungi <- NULL                     # set from second input
    } else {
      # One file with two kingdoms' info — keep entire thing in one df
      values$metadata_single <- values$uploaded_data
    }
  })

  # Server logic for file preview
  output$file_preview <- renderUI({
    req(input$advanced_upload)

    file_info <- input$advanced_upload

    # Validate file type and size
    validate(
      need(tools::file_ext(file_info$name) %in% c("csv", "xlsx", "txt"),
           "Please upload a CSV, Excel, or text file"),
      need(file_info$size < 10 * 1024^2,  # 10MB limit
           "File size must be less than 10MB")
    )

    # Process the file
    tryCatch({
      ext <- tools::file_ext(file_info$name)
      if (ext == "csv") {
        data <- read.csv(file_info$datapath)
      } else if (ext == "xlsx") {
        data <- readxl::read_excel(file_info$datapath)
      } else if (ext == "txt") {
        data <- read.delim(file_info$datapath, sep = "\t", header = TRUE)
      } else {
        stop("Unsupported file type: must be .csv, .txt, or .xlsx")
      }
      # Store processed data
      values$uploaded_data <- data

      # Show success message
      showNotification("File uploaded successfully!", type = "success")

    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
      data <- NULL
    })

    div(
      class = "file-preview",
      h5("File Information:"),
      tags$ul(
        tags$li(paste("Name:", file_info$name)),
        tags$li(paste("Size:", round(file_info$size / 1024^2, 2), "MB")),
        tags$li(paste("Type:", tools::file_ext(file_info$name)))
      ),

      # Show data preview if it's a data file
      if (tools::file_ext(file_info$name) %in% c("csv", ".txt", "xlsx")) {
        div(
          h5("Data Preview:"),
          DT::dataTableOutput("data_preview")
        )
      }
    )
  })


  # Email validation
  output$email_feedback <- renderUI({
    if (is.null(input$email_input) || input$email_input == "") {
      return(NULL)
    }

    email <- input$email_input
    email_pattern <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[A-Za-z]{2,}$"

    if (grepl(email_pattern, email)) {
      validation$email <- TRUE
      div(class = "validation-feedback feedback-success",
          bs_icon("check-circle"), " Valid email address")
    } else {
      validation$email <- FALSE
      div(class = "validation-feedback feedback-danger",
          bs_icon("x-circle"), " Please enter a valid email address")
    }
  })

  # Password validation
  output$password_validation <- renderUI({
    password <- input$password_input %||% ""
    confirm <- input$password_confirm %||% ""

    if (password == "") {
      validation$password <- FALSE
      validation$password_match <- FALSE
      return(NULL)
    }

    # Password strength checks
    checks <- list(
      length = nchar(password) >= 8,
      lowercase = grepl("[a-z]", password),
      uppercase = grepl("[A-Z]", password),
      number = grepl("[0-9]", password),
      special = grepl("[^a-zA-Z0-9]", password)
    )

    strength_score <- sum(unlist(checks))
    validation$password <- strength_score >= 4

    # Password match check
    if (confirm != "") {
      validation$password_match <- password == confirm
    } else {
      validation$password_match <- FALSE
    }

    # Strength meter
    strength_colors <- c("#dc3545", "#fd7e14", "#ffc107", "#20c997", "#198754")
    strength_levels <- c("Very Weak", "Weak", "Fair", "Good", "Strong")
    meter_color <- strength_colors[min(strength_score + 1, 5)]
    meter_width <- (strength_score / 5) * 100

    # Requirements list
    requirement_items <- tagList(
      div(class = paste("requirement-item", if(checks$length) "text-success" else "text-danger"),
          bs_icon(if(checks$length) "check" else "x"), " At least 8 characters"),
      div(class = paste("requirement-item", if(checks$lowercase) "text-success" else "text-danger"),
          bs_icon(if(checks$lowercase) "check" else "x"), " Lowercase letter"),
      div(class = paste("requirement-item", if(checks$uppercase) "text-success" else "text-danger"),
          bs_icon(if(checks$uppercase) "check" else "x"), " Uppercase letter"),
      div(class = paste("requirement-item", if(checks$number) "text-success" else "text-danger"),
          bs_icon(if(checks$number) "check" else "x"), " Number"),
      div(class = paste("requirement-item", if(checks$special) "text-success" else "text-danger"),
          bs_icon(if(checks$special) "check" else "x"), " Special character")
    )

    # Password match feedback
    match_feedback <- if (confirm != "") {
      if (validation$password_match) {
        div(class = "requirement-item text-success",
            bs_icon("check"), " Passwords match")
      } else {
        div(class = "requirement-item text-danger",
            bs_icon("x"), " Passwords do not match")
      }
    }

    div(class = "password-requirements",
        div(
          strong("Password Strength: "),
          span(strength_levels[min(strength_score + 1, 5)],
               style = paste0("color: ", meter_color))
        ),
        div(class = "strength-meter",
            div(class = "strength-fill",
                style = paste0("width: ", meter_width, "%; background: ", meter_color))
        ),
        requirement_items,
        match_feedback
    )
  })

  # Numeric validation
  output$numeric_feedback <- renderUI({
    feedback_items <- list()

    # Age validation
    if (!is.null(input$age_input)) {
      if (is.na(input$age_input)) {
        validation$age <- FALSE
        feedback_items$age <- div(class = "validation-feedback feedback-danger",
                                  bs_icon("x-circle"), " Age must be a number")
      } else if (input$age_input < 13 || input$age_input > 120) {
        validation$age <- FALSE
        feedback_items$age <- div(class = "validation-feedback feedback-danger",
                                  bs_icon("x-circle"), " Age must be between 13 and 120")
      } else {
        validation$age <- TRUE
        feedback_items$age <- div(class = "validation-feedback feedback-success",
                                  bs_icon("check-circle"), " Valid age")
      }
    } else {
      validation$age <- FALSE
    }

    # Salary validation
    if (!is.null(input$salary_input)) {
      if (is.na(input$salary_input)) {
        validation$salary <- FALSE
        feedback_items$salary <- div(class = "validation-feedback feedback-danger",
                                     bs_icon("x-circle"), " Salary must be a number")
      } else if (input$salary_input < 0) {
        validation$salary <- FALSE
        feedback_items$salary <- div(class = "validation-feedback feedback-danger",
                                     bs_icon("x-circle"), " Salary cannot be negative")
      } else if (input$salary_input > 10000000) {
        validation$salary <- FALSE
        feedback_items$salary <- div(class = "validation-feedback feedback-warning",
                                     bs_icon("exclamation-triangle"), " Please verify this salary amount")
      } else {
        validation$salary <- TRUE
        feedback_items$salary <- div(class = "validation-feedback feedback-success",
                                     bs_icon("check-circle"), " Valid salary")
      }
    } else {
      validation$salary <- FALSE
    }

    do.call(tagList, feedback_items)
  })

  # Business logic validation
  output$business_logic_feedback <- renderUI({
    feedback_items <- list()

    # Country and postal code validation
    country <- input$country_input %||% ""
    postal <- input$postal_code %||% ""

    if (country != "" && postal != "") {
      # Define postal code patterns by country
      postal_patterns <- list(
        "USA" = "^\\d{5}(-\\d{4})?$",
        "Canada" = "^[A-Za-z]\\d[A-Za-z] ?\\d[A-Za-z]\\d$",
        "UK" = "^[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}$",
        "Germany" = "^\\d{5}$",
        "France" = "^\\d{5}$"
      )

      pattern <- postal_patterns[[country]]
      if (!is.null(pattern) && grepl(pattern, postal)) {
        validation$country_postal <- TRUE
        feedback_items$postal <- div(class = "validation-feedback feedback-success",
                                     bs_icon("check-circle"),
                                     paste("Valid", country, "postal code"))
      } else {
        validation$country_postal <- FALSE
        example_formats <- list(
          "USA" = "12345 or 12345-6789",
          "Canada" = "A1A 1A1",
          "UK" = "SW1A 1AA",
          "Germany" = "12345",
          "France" = "75001"
        )
        feedback_items$postal <- div(class = "validation-feedback feedback-danger",
                                     bs_icon("x-circle"),
                                     paste("Invalid format. Example for", country, ":",
                                           example_formats[[country]]))
      }
    } else if (country != "" && postal == "") {
      validation$country_postal <- FALSE
      feedback_items$postal <- div(class = "validation-feedback feedback-warning",
                                   bs_icon("exclamation-triangle"),
                                   "Please enter postal code for selected country")
    } else {
      validation$country_postal <- FALSE
    }

    # Date range validation
    start_date <- input$start_date
    end_date <- input$end_date

    if (!is.null(start_date) && !is.null(end_date)) {
      if (end_date <= start_date) {
        validation$date_range <- FALSE
        feedback_items$dates <- div(class = "validation-feedback feedback-danger",
                                    bs_icon("x-circle"),
                                    "End date must be after start date")
      } else if (as.numeric(end_date - start_date) > 365) {
        validation$date_range <- FALSE
        feedback_items$dates <- div(class = "validation-feedback feedback-warning",
                                    bs_icon("exclamation-triangle"),
                                    "Date range is longer than 1 year. Please verify.")
      } else {
        validation$date_range <- TRUE
        days_diff <- as.numeric(end_date - start_date)
        feedback_items$dates <- div(class = "validation-feedback feedback-success",
                                    bs_icon("check-circle"),
                                    paste("Valid date range (", days_diff, "days)"))
      }
    } else {
      validation$date_range <- FALSE
    }

    do.call(tagList, feedback_items)
  })

  # Validation summary
  output$validation_summary <- renderUI({
    fields <- list(
      "Email" = validation$email,
      "Password" = validation$password,
      "Password Match" = validation$password_match,
      "Age" = validation$age,
      "Salary" = validation$salary,
      "Postal Code" = validation$country_postal,
      "Date Range" = validation$date_range
    )

    field_items <- lapply(names(fields), function(name) {
      status <- fields[[name]]
      icon_name <- if (status) "check-circle-fill" else "x-circle"
      color_class <- if (status) "text-success" else "text-danger"

      div(class = paste("mb-1", color_class),
          bs_icon(icon_name), " ", name)
    })

    do.call(tagList, field_items)
  })

  # Form metrics
  output$valid_count <- renderText({
    valid_fields <- sum(unlist(reactiveValuesToList(validation)))
    as.character(valid_fields)
  })

  output$error_count <- renderText({
    total_fields <- length(reactiveValuesToList(validation))
    valid_fields <- sum(unlist(reactiveValuesToList(validation)))
    as.character(total_fields - valid_fields)
  })

  output$completion_percent <- renderText({
    valid_fields <- sum(unlist(reactiveValuesToList(validation)))
    total_fields <- length(reactiveValuesToList(validation))
    percentage <- round((valid_fields / total_fields) * 100)
    as.character(percentage)
  })

  # Enable/disable submit button
  observe({
    all_valid <- all(unlist(reactiveValuesToList(validation)))

    if (all_valid) {
      updateActionButton(session, "submit_form",
                         label = "Submit Form ✓",
                         disabled = FALSE)
    } else {
      updateActionButton(session, "submit_form",
                         label = "Complete All Fields",
                         disabled = TRUE)
    }
  })

  # Form submission
  observeEvent(input$submit_form, {
    showNotification("Form submitted successfully! All validations passed.",
                     type = "success", duration = 5)
  })

  output$submission_feedback <- renderUI({
    req(input$submit_form)

    div(class = "validation-feedback feedback-success mt-3",
        bs_icon("check-circle"),
        " Form submitted successfully! All validation rules were satisfied.")
  })

  # Quick action buttons
  observeEvent(input$fill_valid, {
    updateTextInput(session, "email_input", value = "user@example.com")
    updateTextInput(session, "password_input", value = "SecurePass123!")
    updateTextInput(session, "password_confirm", value = "SecurePass123!")
    updateNumericInput(session, "age_input", value = 25)
    updateNumericInput(session, "salary_input", value = 75000)
    updateSelectInput(session, "country_input", selected = "USA")
    updateTextInput(session, "postal_code", value = "12345")
    updateDateInput(session, "start_date", value = Sys.Date())
    updateDateInput(session, "end_date", value = Sys.Date() + 30)

    showNotification("Form filled with valid data", type = "success")
  })

  observeEvent(input$fill_invalid, {
    updateTextInput(session, "email_input", value = "invalid-email")
    updateTextInput(session, "password_input", value = "weak")
    updateTextInput(session, "password_confirm", value = "different")
    updateNumericInput(session, "age_input", value = 5)
    updateNumericInput(session, "salary_input", value = -1000)
    updateSelectInput(session, "country_input", selected = "USA")
    updateTextInput(session, "postal_code", value = "invalid")
    updateDateInput(session, "start_date", value = Sys.Date() + 10)
    updateDateInput(session, "end_date", value = Sys.Date())

    showNotification("Form filled with invalid data", type = "warning")
  })

  observeEvent(input$clear_all, {
    updateTextInput(session, "email_input", value = "")
    updateTextInput(session, "password_input", value = "")
    updateTextInput(session, "password_confirm", value = "")
    updateNumericInput(session, "age_input", value = NA)
    updateNumericInput(session, "salary_input", value = NA)
    updateSelectInput(session, "country_input", selected = "")
    updateTextInput(session, "postal_code", value = "")
    updateDateInput(session, "start_date", value = Sys.Date())
    updateDateInput(session, "end_date", value = Sys.Date())

    showNotification("All fields cleared", type = "info")
  })
}

shinyApp(ui = ui, server = server)
