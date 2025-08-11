# Advanced File Upload with Preview

# Advanced file upload interface
div(
  class = "file-upload-area",
  fileInput(
    inputId = "advanced_upload",
    label = "Upload Data File",
    accept = c(".csv", ".xlsx", ".txt", ".json"),
    width = "100%",
    buttonLabel = "Browse...",
    placeholder = "No file selected"
  ),
  div(
    class = "upload-instructions",
    icon("cloud-upload", class = "fa-3x"),
    h4("Drag & Drop or Click to Upload"),
    p("Supported formats: CSV, Excel, JSON (Max 25MB)")
  )
),
uiOutput("upload_progress")
uiOutput("file_preview")

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
    if (tools::file_ext(file_info$name) == "csv") {
      data <- read.csv(file_info$datapath)
    } else if (tools::file_ext(file_info$name) == "xlsx") {
      data <- readxl::read_excel(file_info$datapath)
    }

    # Store processed data
    values$uploaded_data <- data

    # Show success message
    showNotification("File uploaded successfully!", type = "success")

  }, error = function(e) {
    showNotification(paste("Error reading file:", e$message), type = "error")
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
    if (tools::file_ext(file_info$name) %in% c("csv", "xlsx")) {
      div(
        h5("Data Preview:"),
        DT::dataTableOutput("data_preview")
      )
    }
  )
})

# Custom CSS for file upload styling
tags$style(HTML("
  .file-upload-area {
    border: 2px dashed #ccc;
    border-radius: 10px;
    padding: 40px;
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
    margin-top: 20px;
  }

  .file-preview {
    margin-top: 20px;
    padding: 20px;
    background: #f8f9fa;
    border-radius: 8px;
    border: 1px solid #dee2e6;
  }
"))
