# ============================================================================
# Shiny App: Single and Dual-Kingdom Microbiome Metadata Processor
# ============================================================================
# Author: Kelli Feeser
# Project: moses
# Description:
# This app allows users to upload one or two metadata files for paired analysis
# across 🦠 Bacteria/Archaea (16S) and 🍄 Fungi (ITS/18S),
# validate the inputs, assess sample ID overlap,
# apply resolution strategies, and categorize metadata
# ─────────────────────────────────────────────────────────────
#
# TO-DO: ####
## reduce font size of subheader and in Validation Summary Field Status
## add subheaders under Field Status for req vs optional
## in form metrics, add count of optional fields completed
## change background of optional modules
## add in questions before categorization to guide cats shown
## log disabled sections into TRACTOR$attributes$config
## dynamically hide categories like "Spatial (GPS)" inside the module body when the top-level categorization toggle is off
## add collapsible "Learn more" dropdown using HTML's <details> + <summary> tag combo.
### for GPS
## change colors everywhere for optional fields
## change sortable dropping bucket_list() and remove readxl
### for sortable: use selectInput(multiple = TRUE) or rework as checklists
##
## PROBLEMATIC PKGS:
### shinyWidgets::switchInput() ❌ (not WebR-compatible)
### sortable::bucket_list() ❌ (uses htmlwidgets + jQuery UI → not WebR-safe yet)
##
## OPTIONAL SECTIONS
  ### so far:
  #### Always shows section title
  #### Toggle "Include" checkbox with line that says “Optional section: uncheck to skip”
  #### Conditionally renders content
  #### Automatically updates feedback icon and status line
  #### Ability to pass arbitrary nested UI into the module (like radioButtons, conditionalPanel, etc.)
  #### Returns reactive() boolean to server
  #### Can be placed in another file and sourced into your app from ../../../www/
  #### UNKNOWN: Does the vaildation section update right?
    ##### If you want to update a validation$gps_format_selected flag only if GPS is enabled:
      # observeEvent(input$save_gps_format, {
      # if (isTRUE(gps_enabled())) {
      #   # perform format saving as usual
      # } else {
      #   validation$gps_format_selected <- TRUE  # Skip, but mark as "valid"
      #   values$gps_column_formats <- "skipped"
      # }
      # })
    ##### might have to do this:  bs_icon in the feedback line should change based on whether the section is active or skipped
  #### Layout:
  ##### Avoid hardcoded column(9) / column(3)
  ##### Let layout be flexible and clean — e.g., use a fluidRow() for the title bar, but avoid unnecessary grid clutter
  #### Inner toggles (subsections):
  ##### You may want to define nested toggles later — so we need to keep the outer toggle scoped only to the main content area, not the entire section block.
##
## TRACTOR/PASTURETOOLS
### add attributes/config
#### Save which sections were skipped in TRACTOR
#### Track multiple optional sections in a config list for export/logging
##### TRACTOR$attributes$config$column_classes
### COLUMNS.... {SEE CHARLES}
  #### add Column type selection UI by implementing auto-suggest
  #### Saved to TRACTOR$attributes$config$column_*
  #### Detect coercion issues by implementing optional warning panel
  #### Export cat abd class definitions to .yaml or .csv or .json for reuse across projects
  ####
### COLUMN CATEGORIZATION
  #### GPS data preview (2 rows) below/next to format selection
  ####
  ####
### COLUMN CLASSIFICATION
  #### Enable prefilled class suggestions (e.g., detect numerics)
  #### Enable bulk class assignment (e.g., "Set all to numeric")
  #### Predefine column types from a template
  #### Visualize which columns are coercible
  ####
#### {SEE CHARLES FOR}
  ##### Visual feedback on coercibility
  ##### 2-row GPS data preview
  ##### Column class assignment with prefilled suggestions
    ###### How to Let Users Define Column Classes in the App
    ####### After categorization is saved, loop over each category:
      ########  Show each variable name
      ######## Let users choose the column class from a dropdown:
      ######### "numeric", "factor", "ordered", "character"
    ###### UI Example (using uiOutput)
      ####### uiOutput("column_classification_ui")
  #####
    #####
####
####
####
####
####
##
##
##
##
##
##
##
##
## DETAILED COLLASPIBLE TOGGLES
##
##
##
##
##
##
##
##
##
##
##
##
#
# Key Features:
# ─────────────────────────────────────────────────────────────
# ✔ Upload 1 or 2 metadata files (single or dual kingdom, if single then labeled)
# ✔ Select per-kingdom sample ID columns and shared linking key
# ✔ Highlight and validate key columns in preview tables
# ✔ Validate sample ID overlap between kingdoms
# ✔ Offer mismatch resolution strategies (subset/intersect/pad)
# ✔ Categorize metadata for easier downstream testing and statistics
# ✔ Track field-level validation with visual feedback and summary
#
# Usage Conventions:
# ─────────────────────────────────────────────────────────────
# • All validation flags stored in `validation <- reactiveValues(...)`
# • All uploaded/processed metadata stored in `values <- reactiveValues(...)`
# • DT tables are used for preview with colored column highlights
# • UI logic (what to show) is separated from processing logic
#
# Section Layout:
# ─────────────────────────────────────────────────────────────
# ---UI SECTION---
# 01. Libraries and Dependencies
# - Theme, CSS, Bootstrap options
# 02. Page Header
# - Metadata formatting guidelines
# 02. File Upload Panels
# - Single vs dual kingdom
# - Labeling of single kingdom (Bac or Fun)
# - Conditional fileInputs
# - Shared key / sample column inputs
# 03. Preview Panels
# - DT::dataTableOutput
# - Column highlights and row counts
# - Per-kingdom legends
# 04. Validation Panels
# - Metadata validation
# - Sample column + key checks
# - Visual feedback (green/yellow/red)
# 05. Sample Overlap + Matching Controls
# - Count display
# - Missing ID preview
# - Strategy radioButtons
# 06. Resolution Strategy
# - ConditionalPanel
# - ActionButton to trigger server logic
#
# ─────────────────────────────────────────────────────────────
# ---SERVER SECTION---
# 01. Reactive State Setup (values, validation)
# - values <- reactiveValues(...)
# - validation <- reactiveValues(...)
# 02. Metadata File Upload (Observers)
# - observeEvent(input$metadata_upload_*)
# 03. Metadata Previews (Tables + Highlight Styling)
# - renderDataTable() for 16S, 18S, Single
# - highlight sample ID and shared key cols
# 04. Sample Count and Overlap Feedback
# - output$kingdom_match_feedback
# - output$sample_overlap_check
# 05. Resolution Strategy UI + Logic
# - observeEvent(input$resolve_mismatch)
# - Applies subset/intersect/NA-padding logic
# 06. Categorize Metadata
# 07. Validation: Format & Column Checks
# - observe() to set validation flags
# - Checks for column presence
# 08. Validation Summary Metrics + Submit
# - output$validation_summary
# - Form metrics: valid_count, error_count
# 09. Clear / Reset Actions
# - observeEvent(input$clear_all)
#
# Notes:
# • Shared key column = must exist in both metadata tables
# • Sample ID columns may differ across kingdoms
# • Preview tables are limited to 6 rows by default
#
# Search Tags (for quick code navigation):
# INPUT: fileInput()
# OUTPUT: renderUI / renderDataTable
# VALIDATION: validation$*
# LOGIC: observeEvent() for strategy resolution
# ============================================================================

# ─────────────────────────────────────────────────────────────
# KINGDOM SAMPLE MATCHING LOGIC
# - Detects mismatches between 16S and 18S metadata sample IDs
# - Displays resolution strategies only if mismatches exist
# - Applies selected strategy via event handler
# - Strategies:
#   - intersect: keep only shared samples
#   - keep_16S: keep all bacteria, pad fungi
#   - keep_18S: keep all fungi, pad bacteria
#   - union: keep all from both (pad both sides)
# ─────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────
# COLUMN CATEGORIZATION AND CLASSIFICATION
# - Step: UI
#   - uiOutput("column_classification_ui") (also uiOutput("column_categorization_ui"))
#   - actionButton("save_column_classes", ...)
# - Step: Server
#   - output$column_classification_ui loop and
#   - observeEvent(input$save_column_classes)
# - Step: Storage
#   - Save into TRACTOR$attributes$config$column_classes
# - Step: Validation
#   - validation$column_classes_saved <- TRUE
# - Displays resolution strategies only if mismatches exist
# - Applies selected strategy via event handler
# - Strategies:
#   - intersect: keep only shared samples
#   - keep_16S: keep all bacteria, pad fungi
#   - keep_18S: keep all fungi, pad bacteria
#   - union: keep all from both (pad both sides)
# ─────────────────────────────────────────────────────────────

# webr problems ####
# sortable::bucket_list() (for drag-and-drop) - problem: Requires drag-and-drop JS bindings
#   → use selectInput(multiple = TRUE) or rework as checklists
# readxl - problem: Relies on compiled C code, not wasm-portable
#   → ask users to upload .csv instead of .xlsx



# ─────────────────────────────────────────────────────────────
# LOAD REQUIRED LIBRARIES ####
# ─────────────────────────────────────────────────────────────
library(shiny)
library(bsicons)
library(bslib)
library(DT)
library(tools)
library(sortable)
library(readxl)
# Read-in module helper scripts
source("../../../www/optionalValidationSectionModule.R")
source("../../../www/column_categorization_ui.R")
source("../../../www/column_categorization_server.R")
# source("www/optionalValidationSectionModule.R")
# source("www/column_categorization_ui.R")
# source("www/column_categorization_server.R")

# ─────────────────────────────────────────────────────────────
# UI SECTION ####
# ─────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────
# UI-01. UI Setup & Styling ####
# ─────────────────────────────────────────────────────────────
# - Theme, CSS, Bootstrap options
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
      .metadata-format-box {
        border: 2px solid #0d6efd;
        border-radius: 10px;
        background-color: #f1f8ff;
        padding: 20px;
        margin-bottom: 10px;
        font-size: 1rem;
        box-shadow: 0 0 6px rgba(0,0,0,0.05);
      }

      .metadata-format-box h4 {
        color: #0d6efd;
        font-weight: 600;
        margin-bottom: 10px;
      }
      .dataTable tbody td {
        padding: 4px 8px !important; /* Less vertical padding = shorter rows */
        font-size: 0.85rem;          /* Optional: slightly smaller text */
      }
      .dataTable tbody {
        line-height: 1.0 !important;
      }
      .nested-subsection {
      margin-top: 2rem;
      padding-left: 1rem;
      border-left: 3px solid #ddd;
    }
    "))
  ),

# ─────────────────────────────────────────────────────────────
# UI-02. Page Header ####
# ─────────────────────────────────────────────────────────────
  div(class = "container-fluid",
      ## Page Title ####
      h3(bs_icon("shield-check"), "Sample Metadata Upload and Validation",
         class = "text-center mb-4"),
      p("Upload, process, and validate sample metadata file(s) | Compatible with single and dual kingdom metadata (a.k.a 'mapping') files.",
        class = "text-center lead text-muted mb-4"),

      ## Metadata formatting guidelines ####
      div(class = "metadata-format-box",
          h4(bs_icon("info-circle"), "Metadata File Format Requirements"),
          p(
            strong("Samples must be rows and metadata factors/variables must be columns."),
            br(),
            "Accepted file formats: .csv, .txt (excel and other coming soon? - webr snag)",
            br(),
            "Dual kingdom metadata can be provided as 1 combined or 2 individual per-kingdom files.",
            "Processing requires a ",
            strong("shared key"),
            " (file column) that joins paired samples, and a ",
            strong("per-kingdom sample column"),
            " that maps each kingdom’s ASV/OTU table rownames to their corresponding sample metadata row.",
            "The shared and per-kingdom keys can all be the same column/key."
          )
      ),

      # ─── Main Layout: Left = Upload + Config | Right = Summary ─
      fluidRow(
        # Left Column
        column(8,

# ─────────────────────────────────────────────────────────────
# UI-03. File Upload Panels ####
# ─────────────────────────────────────────────────────────────
# - Single vs dual kingdom
# - If the user uploads a single kingdom metadata file, allow them to specify whether it represents 16S (Bacteria/Archaea) or ITS (Fungi).
# - Conditional fileInputs
# - Shared key / sample column inputs

# ── Metadata Upload Configuration ──
## Single or Dual Kingdom Selection ####
div(class = "validation-section",
    h4(bs_icon("file-earmark-medical"), "1. Metadata File Upload Configuration"),
    p("Specify the structure of your metadata files and how they map to ASV/OTU tables.",
      class = "text-muted"),

    radioButtons("kingdom_mode", "How many kingdoms are you processing?",
                 choices = c("Single Kingdom", "Dual Kingdoms"),
                 selected = "Dual Kingdoms",
                 inline = TRUE),

    ## Label Single Kingdom as Bac or Fun ####
    conditionalPanel(
      condition = "input.kingdom_mode == 'Single Kingdom'",
      div(class = "validation-section",
          h4("Label Single Kingdom Dataset"),
          radioButtons("single_kingdom_type", "Select type:",
                       choices = c("Bacteria/Archaea (16S)", "Fungi (ITS/18S)"),
                       selected = "Bacteria/Archaea (16S)")
      )
    ),

    ## Ask for sample name columns per kingdom ####
    conditionalPanel(
      condition = "input.kingdom_mode == 'Single Kingdom'",
      textInput("sample_col_single", "Which column matches the ASV/OTU sample names?",
                placeholder = "e.g., SampleID")
    ),


    conditionalPanel(
      condition = "input.kingdom_mode == 'Dual Kingdoms'",

      radioButtons("dual_file_mode", "How is your metadata structured?",
                   choices = c("One file with paired kingdom info",
                               "Two separate metadata files"),
                   selected = "Two separate metadata files",
                   inline = FALSE) #,
    ),


    conditionalPanel(
      condition = "input.kingdom_mode == 'Dual Kingdoms'",
      textInput("shared_key", "Shared column key to join the two metadata files:",
                placeholder = "e.g., SampleID"),
      textInput("sample_col_bacteria", "Column in 16S metadata that matches the 16S ASV/OTU sample names:",
                placeholder = "e.g., BacSampleID"),
      textInput("sample_col_fungi", "Column in ITS/18S metadata that matches the ITS/18S ASV/OTU sample names",
                placeholder = "e.g., FunSampleID")
    ),
),

# ─────────────────────────────────────────────────────────────
# UI-04. Preview Panels ####
# ─────────────────────────────────────────────────────────────
# - DT::dataTableOutput
# - Column highlights and row counts
# - Per-kingdom legends

               # Single file upload (used in both single-kingdom and dual-kingdom w/ one file)
               conditionalPanel(
                 condition = "input.kingdom_mode == 'Single Kingdom' || input.dual_file_mode == 'One file with paired kingdom info'",
                 div(class = "file-upload-area",
                     fileInput(
                       inputId = "metadata_upload_single",
                       label = strong("Upload Metadata File"),
                       accept = c(".csv", ".txt", ".xlsx"),
                       width = "80%"
                     ),
                     div(class = "upload-instructions",
                         icon("cloud-upload", class = "fa-3x"),
                         h5("Drag & Drop or Click to Upload"),
                         p("Supported formats: CSV, TXT, Excel (Max 25MB)")
                     )
                 ),
                 uiOutput("file_preview_single")
               ),

               # Two separate file uploads for Dual Kingdom
               conditionalPanel(
                 condition = "input.kingdom_mode == 'Dual Kingdoms' && input.dual_file_mode == 'Two separate metadata files'",

                 div(class = "file-upload-area",
                     fileInput(
                       inputId = "metadata_upload_bacteria",
                       label = strong("Upload Metadata File for 16S / Bacteria-Archaea"),
                       accept = c(".csv", ".txt", ".xlsx"),
                       width = "80%"
                     ),
                     div(class = "upload-instructions",
                         icon("cloud-upload", class = "fa-3x"),
                         h5("Drag & Drop or Click to Upload"),
                         p("Supported formats: CSV, TXT, Excel (Max 25MB)"),
                         uiOutput("file_preview_bacteria")
                         )
                 ),


                 div(class = "file-upload-area mt-4",
                     fileInput(
                       inputId = "metadata_upload_fungi",
                       label = strong("Upload Metadata File for ITS/18S / Fungi"),
                       accept = c(".csv", ".txt", ".xlsx"),
                       width = "80%"
                     ),
                     div(class = "upload-instructions",
                         icon("cloud-upload", class = "fa-3x"),
                         h5("Drag & Drop or Click to Upload"),
                         p("Supported formats: CSV, TXT, Excel (Max 25MB)"),
                         uiOutput("file_preview_fungi")
                     )
                 )
               ),

# ─────────────────────────────────────────────────────────────
# UI-05. Sample Metadata Processing Panels ####
# ─────────────────────────────────────────────────────────────
# - Metadata validation
# - Sample column + key checks
# - Visual feedback (green/yellow/red)

               ## Cross-Kingdom Matching and Resolution ####
               div(class = "validation-section",
                   h4(bs_icon("diagram-3"), "Kingdom Sample Matching"),
                   p("Check for matching paired samples across 16S and 18S metadata", class = "text-muted"),
                   uiOutput("kingdom_match_feedback"),
                   hr(),
                   uiOutput("sample_overlap_check"),

                   conditionalPanel(
                     condition = "output.show_resolution_controls === true",
                     div(
                       hr(),
                       h5("Choose resolution strategy:"),
                       radioButtons("subset_strategy", NULL,
                                    choices = c(
                                      "Keep only shared samples (intersection)" = "intersect",
                                      "Keep all 16S, pad 18S with NA" = "keep_16S",
                                      "Keep all 18S, pad 16S with NA" = "keep_18S",
                                      "Keep all samples (union)" = "union"
                                    )),
                       actionButton("resolve_mismatch", "Apply Strategy", class = "btn-primary mt-2")
                     )
                   )
               ),


## Categorize Metadata Columns ####
# div(class = "validation-section",
#     h4("Categorize Metadata Columns"),
#     p("Drag and drop metadata column names into the category boxes
#       to the right and below."),
#       # "These will be stored for downstream
#       # processing for easier access during statistical testing
#       # (i.e., to answer questions such as: Are any of my environmental variables spatially patterned?, or How do communities change under differing Treatment conditions by Host, and does that vary by Time?). Note that it is ok to leave column names in the 'Unassigned' category. They will still be retained."),
#
#     # Collapsible extended explanation
#     tags$details(
#       tags$summary("Learn more about how column categorization is used", style = "cursor: pointer;"),
#       p(
#         "These will be stored for downstream processing for easier access during statistical testing.",
#         "For example, to answer questions such as:",
#         tags$ul(
#           tags$li("Are any of my environmental variables spatially patterned?"),
#           tags$li("Which of any of my environmental variables correlate with community change, and by how much?"),
#           tags$li("How do microbial communities change under different Treatment conditions by Host?"),
#           tags$li("Does that variation change over Time?")
#         ),
#         "It is perfectly fine to leave columns in the 'Unassigned' category — they will still be retained."
#       )
#     ),
#
#     uiOutput("metadata_column_sorter"),
#
#     actionButton("save_metadata_categorization", "Save Column Categories", class = "btn-success mt-3")
# ),

## test optional categorization
# optionalSectionUI(
#   id = "metadata_categorization",
#   title = "Categorize Metadata Columns",
#   icon = bs_icon("columns-gap"),
#   subtitle = NULL,
#   body_ui = uiOutput("categorization_body_ui")  # placeholder target for server output
# ),

## Classify Metadata Columns ####
### GPS Format Section (after categorization UI) ####
# div(class = "validation-section",
#     h4("Classify Metadata Columns"),
#
#     h5("GPS Column Format"),
#     uiOutput("gps_column_structure_ui"),
#
#     h5("GPS Format Identification"),
#
#     uiOutput("gps_format_ui"),  # dynamic format selectors per GPS column
#
#     actionButton("save_gps_format", "Save GPS Format", class = "btn-success mt-3")
# ),
#
# # test optional section ####
# # optionalSection_UI("gps_format", title = "GPS Coordinate Format",
# #                   help = "Specify the format for your GPS columns if applicable."),
#
# # optionalSection_UI(
# #   id = "gps_section",
# #   title = "GPS Coordinate Format",
# #   icon = bs_icon("geo-alt"),
# #   subtitle = "If GPS coordinates are present, define structure and format.",
# #   body_ui = uiOutput("gps_format_ui")
# # ),
# optionalSectionUI(
#   id = "gps_section",
#   title = "GPS Coordinate Format",
#   icon = bs_icon("geo-alt"),
#   subtitle = "Define format and structure of any spatial metadata columns.",
#   body_ui = uiOutput("gps_format_ui")
# ),


# test column_categorization_ui section ####
columnCategorizationUI("categorize"),

# optionalSection_UI(
#   id = "gps_section2",
#   title = "GPS Coordinate Format 2",
#   icon = bs_icon("geo-alt"),
#   subtitle = "Define format and structure of any spatial metadata columns.",
#   body_ui = uiOutput("gps_format_ui")
# ),

               # # Email Validation
               # div(class = "validation-section",
               #     h4(bs_icon("envelope"), "Email Validation"),
               #     p("Test email format validation with instant feedback", class = "text-muted"),
               #
               #     textInput("email_input", "Email Address:",
               #               placeholder = "Enter your email address"),
               #     uiOutput("email_feedback")
               # ),
               #
               # # Password Validation
               # div(class = "validation-section",
               #     h4(bs_icon("key"), "Password Strength Validation"),
               #     p("Experience comprehensive password validation with visual feedback", class = "text-muted"),
               #
               #     passwordInput("password_input", "Create Password:",
               #                   placeholder = "Enter a secure password"),
               #     passwordInput("password_confirm", "Confirm Password:",
               #                   placeholder = "Re-enter your password"),
               #
               #     uiOutput("password_validation")
               # ),

               # # Numeric Range Validation
               # div(class = "validation-section",
               #     h4(bs_icon("123"), "Numeric Range Validation"),
               #     p("Validate numeric inputs with custom constraints", class = "text-muted"),
               #
               #     fluidRow(
               #       column(6,
               #              numericInput("age_input", "Age (13-120):",
               #                           value = NULL, min = 13, max = 120)
               #       ),
               #       column(6,
               #              numericInput("salary_input", "Annual Salary ($):",
               #                           value = NULL, min = 0, step = 1000)
               #       )
               #     ),
               #     uiOutput("numeric_feedback")
               # ),

               # # Custom Business Logic Validation
               # div(class = "validation-section",
               #     h4(bs_icon("building"), "Business Logic Validation"),
               #     p("Complex validation with interdependent fields", class = "text-muted"),
               #
               #     fluidRow(
               #       column(6,
               #              selectInput("country_input", "Country:",
               #                          choices = c("", "USA", "Canada", "UK", "Germany", "France"))
               #       ),
               #       column(6,
               #              textInput("postal_code", "Postal/ZIP Code:",
               #                        placeholder = "Enter postal code")
               #       )
               #     ),
               #     fluidRow(
               #       column(6,
               #              dateInput("start_date", "Start Date:", value = Sys.Date())
               #       ),
               #       column(6,
               #              dateInput("end_date", "End Date:", value = Sys.Date() + 30)
               #       )
               #     ),
               #     uiOutput("business_logic_feedback")
               # ),

               ## Form Submission ####
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

        # Validation Summary Column ####
        column(4,
               div(class = "form-summary",
                   h4(bs_icon("clipboard-data"), "Validation Summary"),

                   h5("Field Status:"),
                   uiOutput("validation_summary"),

                   hr(),

                   ## Form Metrics ####
                   h5("Form Metrics:"),
                   div(
                     strong("Valid Required Fields: "), textOutput("valid_count", inline = TRUE), "/7",
                     br(),
                     strong("Error Count: "), textOutput("error_count", inline = TRUE),
                     br(),
                     strong("Completion: "), textOutput("completion_percent", inline = TRUE), "%"
                   ),

                   hr(),

                   ## Quick Actions ####
                   h5("Quick Actions:"),
                   div(
                     # actionButton("fill_valid", "Fill Valid Data",
                     #              class = "btn-outline-success btn-sm mb-2 w-100"),
                     # actionButton("fill_invalid", "Fill Invalid Data",
                     #              class = "btn-outline-danger btn-sm mb-2 w-100"),
                     actionButton("clear_all", "Clear All",
                                  class = "btn-outline-secondary btn-sm w-100")
                   ),

                   hr(),

                   # ## Validation Tips ####
                   # h5("Validation Tips:"),
                   # div(class = "small text-muted",
                   #     tags$ul(
                   #       tags$li("File Uploads: .txt file must be tab-separated"),
                   #       tags$li("Shared and per-kingdom identifiers: row strings must match corresponding ASV/OTU table row names (or column A). It is acceptable to have 1 single set (column) of sample IDs among kingdoms; also acceptable are unique per-kingdom ID column if an additional shared key column is present."),
                   #       tags$li("Columns Categorized: Metadata column names do not need to be categorized")
                   #       # tags$li("Password: 8+ chars, mixed case, number, special"),
                   #       # tags$li("Age: Between 13-120 years"),
                   #       # tags$li("Dates: End date must be after start date"),
                   #       # tags$li("Postal: Format depends on selected country")
                   #     )
                   # ), # end Validation Tips: div(class = "small text-muted"
                   #
                   # hr(),

                   ## Validation Tips ####
                   h5("Validation Tips:"),
                   div(class = "small text-muted",
                       tags$ul(

                         # Tip 1: File Uploads
                         tags$li(
                           strong("File Uploads:"), ".txt files must be tab-separated."
                         ),

                         # Tip 2: Sample Identifiers
                         tags$li(
                           HTML(
                             paste0(
                               strong("Sample Identifiers: "), " Sample IDs in your metadata must match those in the OTU/ASV table.<br/>",
                               "<details style='margin-top:4px;'><summary style='cursor:pointer;'>Learn more</summary>",
                               "<ul style='margin-top:6px;'>",
                               "<li>Row order does not need to match, but IDs must match exactly (case-sensitive).</li>",
                               "<li>You may use a single shared ID column across both kingdoms.</li>",
                               "<li>Alternatively, you may use separate per-kingdom IDs with a shared join key.</li>",
                               "</ul></details>"
                             )
                           )
                         ),

                         # Tip 3: Column Categorization
                         tags$li(
                           HTML(
                             paste0(
                               strong("Column Categorization: "), em("(Optional)")," You do not need to categorize every column.",
                               "<details style='margin-top:4px;'><summary style='cursor:pointer;'>Learn more</summary>",
                               "<ul style='margin-top:6px;'>",
                               "<li>Leave columns in 'Unassigned' if they are not relevant for analysis.</li>",
                               "<li>Categories help organize data for filtering, modeling, and stratification.</li>",
                               "</ul></details>"
                             )
                           )
                         ),

                         # Tip 4: GPS Columns
                         tags$li(
                           HTML(
                             paste0(
                               strong("GPS Columns: "), em("(Optional)")," Place spatial columns into the 'Spatial (GPS)' category.",
                               "<details style='margin-top:4px;'><summary style='cursor:pointer;'>Learn more</summary>",
                               "<ul style='margin-top:6px;'>",
                               "<li>You will be asked to specify the format (e.g., decimal, UTM, DMS).</li>",
                               "<li>If using two separate columns, be sure to correctly identify latitude and longitude.</li>",
                               "<li>GPS data can be optional; confirm 'No GPS' to proceed if not applicable.</li>",
                               "</ul></details>"
                             )
                           )
                         )
                       )# end Validation Tips2: div(class = "small text-muted"
                   )

               )
        )
      )
  )
)

# ─────────────────────────────────────────────────────────────
# SERVER SECTION ####
# ─────────────────────────────────────────────────────────────

server <- function(input, output, session) {

  # SERV-01. Reactive values for validation state ####
  validation <- reactiveValues(
    file_uploaded = FALSE,
    sample_col_b_ok = FALSE,
    sample_col_f_ok = FALSE,
    sample_cols_ok = FALSE,  # this one will be derived
    shared_key_ok = FALSE,
    resolution_applied = FALSE,
    columns_categorized = FALSE,
    columns_classified = FALSE,
    gps_format_selected = FALSE,
    # email = FALSE,
    # password = FALSE,
    # password_match = FALSE,
    # age = FALSE,
    # # salary = FALSE,
    # country_postal = FALSE,
    # date_range = FALSE
  )

  # reactive list to hold metadata
  values <- reactiveValues(
    uploaded_data = NULL,
    metadata_single = NULL,
    metadata_bacteria = NULL,
    metadata_fungi = NULL
  )

# ─────────────────────────────────────────────────────────────
# SERV-02. Metadata File Upload and Preview ####
# ─────────────────────────────────────────────────────────────


  ## Utility: Load a file based on extension ####
  load_metadata_file <- function(file) {
    ext <- tools::file_ext(file$name)
    switch(ext,
           csv = read.csv(file$datapath, stringsAsFactors = FALSE),
           txt = read.delim(file$datapath, stringsAsFactors = FALSE),
           xlsx = readxl::read_excel(file$datapath),
           stop("Unsupported file type: must be .csv, .txt, or .xlsx")
    )
  }

  # single v Dual Kingdoms metadata file upload - OLD ###
  # observe({
  #   req(values$uploaded_data)
  #
  #   if (input$kingdom_mode == "Single Kingdom") {
  #     values$metadata_single <- values$uploaded_data
  #   } else if (input$dual_file_mode == "Two separate metadata files") {
  #     # you'd need to support a second fileInput and parse it similarly
  #     values$metadata_bacteria <- values$uploaded_data  # placeholder
  #     values$metadata_fungi <- NULL                     # set from second input
  #   } else {
  #     # One file with two kingdoms' info — keep entire thing in one df
  #     values$metadata_single <- values$uploaded_data
  #   }
  # })
  #
  # # Server logic for file preview
  # output$file_preview <- renderUI({
  #   req(input$advanced_upload)
  #
  #   file_info <- input$advanced_upload
  #
  #   # Validate file type and size
  #   validate(
  #     need(tools::file_ext(file_info$name) %in% c("csv", "xlsx", "txt"),
  #          "Please upload a CSV, Excel, or text file"),
  #     need(file_info$size < 10 * 1024^2,  # 10MB limit
  #          "File size must be less than 10MB")
  #   )
  #
  #   # Process the file
  #   tryCatch({
  #     ext <- tools::file_ext(file_info$name)
  #     if (ext == "csv") {
  #       data <- read.csv(file_info$datapath)
  #     } else if (ext == "xlsx") {
  #       data <- readxl::read_excel(file_info$datapath)
  #     } else if (ext == "txt") {
  #       data <- read.delim(file_info$datapath, sep = "\t", header = TRUE)
  #     } else {
  #       stop("Unsupported file type: must be .csv, .txt, or .xlsx")
  #     }
  #     # Store processed data
  #     values$uploaded_data <- data
  #
  #     # Show success message
  #     showNotification("File uploaded successfully!", type = "success")
  #
  #   }, error = function(e) {
  #     showNotification(paste("Error reading file:", e$message), type = "error")
  #     data <- NULL
  #   })
  #
  #   div(
  #     class = "file-preview",
  #     h5("File Information:"),
  #     tags$ul(
  #       tags$li(paste("Name:", file_info$name)),
  #       tags$li(paste("Size:", round(file_info$size / 1024^2, 2), "MB")),
  #       tags$li(paste("Type:", tools::file_ext(file_info$name)))
  #     ),
  #
  #     # Show data preview if it's a data file
  #     if (tools::file_ext(file_info$name) %in% c("csv", ".txt", "xlsx")) {
  #       div(
  #         h5("Data Preview:"),
  #         DT::dataTableOutput("data_preview")
  #       )
  #     }
  #   )
  # })


  ### Observe File Upload Config (Single & Dual Kingdom) ####

  #### Single Kingdom or Dual Kingdoms - ONE FILE ####
  observeEvent(input$metadata_upload_single, {
    req(input$metadata_upload_single)
    tryCatch({
      df <- load_metadata_file(input$metadata_upload_single)
      values$metadata_single <- df

      # Label the uploaded metadata based on user's selection
      values$kingdom_label <- input$single_kingdom_type

      showNotification(paste("Metadata uploaded and labeled as:", values$kingdom_label),
                       type = "message")
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })

  #### Dual Kingdoms - TWO FILES ####
  observeEvent(input$metadata_upload_bacteria, {
    req(input$metadata_upload_bacteria)
    tryCatch({
      df <- load_metadata_file(input$metadata_upload_bacteria)
      values$metadata_bacteria <- df
      showNotification("Bacteria/Archaea metadata uploaded.", type = "message")
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })

  observeEvent(input$metadata_upload_fungi, {
    req(input$metadata_upload_fungi)
    tryCatch({
      df <- load_metadata_file(input$metadata_upload_fungi)
      values$metadata_fungi <- df
      showNotification("Fungi metadata uploaded.", type = "message")
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })

  ## DYNAMIC PREVIEWS ####

  #### File Preview Renderers ####

  ##### meta single DT preview render ####
  # INPUT: metadata_upload_single
  # OUTPUT: preview_table_single
  output$file_preview_single <- renderUI({
    req(values$metadata_single)
    div(class = "file-preview",
        h5("Preview: Metadata (Single File)"),
        DT::dataTableOutput("preview_table_single"))
  })

  output$preview_table_single <- DT::renderDataTable({
    req(values$metadata_single)
    DT::datatable(head(values$metadata_single, 20),
                  options = list(scrollX = TRUE,
                                 pageLength = 6,            # Show only 6 rows on initial load
                                 lengthMenu = c(6, 10, 25, 50)  # Let user choose how many rows to view
                  )
    )
  })

  ##### meta BAC DT preview render ####
  # INPUT: metadata_bacteria
  # OUTPUT: preview_table_bacteria
  output$file_preview_bacteria <- renderUI({
    req(values$metadata_bacteria)
    df <- values$metadata_bacteria

    sample_col <- input$sample_col_bacteria %||% ""
    shared_col <- input$shared_key %||% ""

    n_rows <- nrow(df)
    n_samples <- if (sample_col %in% colnames(df)) length(unique(df[[sample_col]])) else NA
    n_shared <- if (shared_col %in% colnames(df)) length(unique(df[[shared_col]])) else NA

    # Legend
    legend <- tags$div(
      style = "margin-bottom: 8px;",
      tags$span(style = "background:#cce5ff;padding:4px 8px;margin-right:10px;border-radius:4px;", "16S Sample Column"),
      tags$span(style = "background:#fff3cd;padding:4px 8px;border-radius:4px;", "Shared Key Column")
      )

    div(class = "file-preview",
        h5("Preview: Bacteria Metadata (16S)"),
        tags$ul(
          tags$li(strong("Rows:"), paste(n_rows)),
          if (!is.na(n_samples)) tags$li(strong("Unique Sample IDs:"), paste(n_samples)),
          if (!is.na(n_shared)) tags$li(strong("Unique Shared Keys:"), paste(n_shared))
        ),
        legend,
        DT::dataTableOutput("preview_table_bacteria")
    )
  })

  output$preview_table_bacteria <- DT::renderDataTable({
    req(values$metadata_bacteria)

    df <- values$metadata_bacteria

    # Apply colors based on role
    sample_col <- input$sample_col_bacteria %||% ""
    shared_col <- input$shared_key %||% ""

    sample_color <- if (sample_col %in% colnames(df)) sample_col else NULL
    shared_color <- if (shared_col %in% colnames(df)) shared_col else NULL

    DT::datatable(
      df,
      options = list(
        scrollX = TRUE,
        pageLength = 6,
        lengthMenu = c(6, 10, 25, 50)
      )
    ) %>%
      {
        tbl <- .
        if (!is.null(sample_color)) {
          tbl <- tbl %>%
            DT::formatStyle(
              columns = sample_color,
              backgroundColor = "#cce5ff"
            )
        }
        if (!is.null(shared_color)) {
          tbl <- tbl %>%
            DT::formatStyle(
              columns = shared_color,
              backgroundColor = "#fff3cd"
            )
        }
        tbl
      }
  })

  # output$file_preview_fungi <- renderUI({
  #   req(values$metadata_fungi)
  #   div(class = "file-preview",
  #       h5("Preview: Fungi Metadata (ITS/18S)"),
  #       DT::dataTableOutput("preview_table_fungi"))
  # })

  ##### meta FUN DT preview render ####
  # INPUT: metadata_fungi
  # OUTPUT: preview_table_fungi
  output$file_preview_fungi <- renderUI({
    req(values$metadata_fungi)
    df <- values$metadata_fungi

    sample_col <- input$sample_col_fungi %||% ""
    shared_col <- input$shared_key %||% ""

    n_rows <- nrow(df)
    n_samples <- if (sample_col %in% colnames(df)) length(unique(df[[sample_col]])) else NA
    n_shared <- if (shared_col %in% colnames(df)) length(unique(df[[shared_col]])) else NA

    # Legend
    legend <- tags$div(
      style = "margin-bottom: 8px;",
      tags$span(style = "background:#d1e7dd;padding:4px 8px;margin-right:10px;border-radius:4px;", "ITS/18S Sample Column"),
      tags$span(style = "background:#fff3cd;padding:4px 8px;border-radius:4px;", "Shared Key Column")
    )

    div(class = "file-preview",
        h5("Preview: Fungi Metadata (ITS/18S)"),
        tags$ul(
          tags$li(strong("Rows:"), paste(n_rows)),
          if (!is.na(n_samples)) tags$li(strong("Unique Sample IDs:"), paste(n_samples)),
          if (!is.na(n_shared)) tags$li(strong("Unique Shared Keys:"), paste(n_shared))
        ),
        legend,
        DT::dataTableOutput("preview_table_fungi")
    )
  })


  output$preview_table_fungi <- DT::renderDataTable({
    req(values$metadata_fungi)

    df <- values$metadata_fungi
    sample_col <- input$sample_col_fungi %||% ""
    shared_col <- input$shared_key %||% ""

    sample_color <- if (sample_col %in% colnames(df)) sample_col else NULL
    shared_color <- if (shared_col %in% colnames(df)) shared_col else NULL

    DT::datatable(
      df,
      options = list(
        scrollX = TRUE,
        pageLength = 6,
        lengthMenu = c(6, 10, 25, 50)
      )
    ) %>%
      {
        tbl <- .
        if (!is.null(sample_color)) {
          tbl <- tbl %>%
            DT::formatStyle(
              columns = sample_color,
              backgroundColor = "#d1e7dd"  # Light green for 18S sample column
            )
        }
        if (!is.null(shared_color)) {
          tbl <- tbl %>%
            DT::formatStyle(
              columns = shared_color,
              backgroundColor = "#fff3cd"
            )
        }
        tbl
      }
  })





  ## File Upload Config (Single vs. dual, 1 file vs. 2) ####
  ### Single kingdom ####
  observe({
    if (input$kingdom_mode == "Single Kingdom") {
      df <- values$metadata_single
      if (!is.null(df)) {
        validation$file_uploaded <- TRUE

        if (!is.null(input$sample_col_single) && input$sample_col_single %in% colnames(df)) {
          validation$sample_cols_ok <- TRUE
        }

        if (!is.null(input$shared_key) && input$shared_key %in% colnames(df)) {
          validation$shared_key_ok <- TRUE
        }
      }
    }

    ### Dual Kingdoms (1 or 2 meta files?)
    if (input$kingdom_mode == "Dual Kingdoms" &&
        input$dual_file_mode == "One file with paired kingdom info") {

      df <- values$metadata_single
      if (!is.null(df)) {
        validation$file_uploaded <- TRUE

        if (!is.null(input$sample_col_bacteria) && input$sample_col_bacteria %in% colnames(df) &&
            !is.null(input$sample_col_fungi) && input$sample_col_fungi %in% colnames(df)) {
          validation$sample_cols_ok <- TRUE
        }

        if (!is.null(input$shared_key) && input$shared_key %in% colnames(df)) {
          validation$shared_key_ok <- TRUE
        }
      }
    }

    if (input$kingdom_mode == "Dual Kingdoms" &&
        input$dual_file_mode == "Two separate metadata files") {

      df_b <- values$metadata_bacteria
      df_f <- values$metadata_fungi
      sample_b_col <- input$sample_col_bacteria %||% ""
      sample_f_col <- input$sample_col_fungi %||% ""
      shared_col <- input$shared_key %||% ""

      if (!is.null(df_b) && !is.null(df_f)) {
        validation$file_uploaded <- TRUE

        validation$sample_col_b_ok <- sample_b_col != "" && sample_b_col %in% colnames(df_b)
        validation$sample_col_f_ok <- sample_f_col != "" && sample_f_col %in% colnames(df_f)
        validation$sample_cols_ok <- validation$sample_col_b_ok && validation$sample_col_f_ok

        validation$shared_key_ok <- shared_col != "" &&
          shared_col %in% colnames(df_b) &&
          shared_col %in% colnames(df_f)
        }
      }
  })

  ## File Upload Config
  output$file_validation_feedback <- renderUI({
    feedback <- list()

    ## Single Kingdom & single metadata file (case 1)
    if (input$kingdom_mode == "Single Kingdom") {
      df <- values$metadata_single
      sample_col <- input$sample_col_single %||% ""
      shared_col <- input$shared_key %||% ""

      if (!is.null(df)) {
        validation$file_uploaded <- TRUE
        feedback[["file"]] <- div(class = "validation-feedback feedback-success",
                                  bs_icon("check-circle"), " Metadata file uploaded")

        if (sample_col != "" && sample_col %in% colnames(df)) {
          validation$sample_cols_ok <- TRUE
          feedback[["sample_col"]] <- div(class = "validation-feedback feedback-success",
                                          bs_icon("check-circle"),
                                          " Sample column found: ", code(sample_col))
        } else {
          feedback[["sample_col"]] <- div(class = "validation-feedback feedback-danger",
                                          bs_icon("x-circle"),
                                          " Sample column missing or incorrect")
        }

        if (shared_col != "" && shared_col %in% colnames(df)) {
          validation$shared_key_ok <- TRUE
          feedback[["shared_col"]] <- div(class = "validation-feedback feedback-success",
                                          bs_icon("check-circle"),
                                          " Shared key column found: ", code(shared_col))
        } else {
          feedback[["shared_col"]] <- div(class = "validation-feedback feedback-danger",
                                          bs_icon("x-circle"),
                                          " Shared key column missing or incorrect")
        }

      } else {
        feedback[["file"]] <- div(class = "validation-feedback feedback-danger",
                                  bs_icon("x-circle"), " No metadata file uploaded")
      }

    ## Dual Kingdoms & 2 metadata files (case 2)
    } else if (input$kingdom_mode == "Dual Kingdoms" &&
               input$dual_file_mode == "Two separate metadata files") {
      df_bact <- values$metadata_bacteria
      df_fun <- values$metadata_fungi
      sample_b <- input$sample_col_bacteria %||% ""
      sample_f <- input$sample_col_fungi %||% ""
      shared_col <- input$shared_key %||% ""

      feedback[["file_bacteria"]] <- if (!is.null(df_bact)) {
        div(class = "validation-feedback feedback-success",
            bs_icon("check-circle"), " Bacteria metadata uploaded")
      } else {
        div(class = "validation-feedback feedback-danger",
            bs_icon("x-circle"), " Bacteria metadata file missing")
      }

      feedback[["file_fungi"]] <- if (!is.null(df_fun)) {
        div(class = "validation-feedback feedback-success",
            bs_icon("check-circle"), " Fungi metadata uploaded")
      } else {
        div(class = "validation-feedback feedback-danger",
            bs_icon("x-circle"), " Fungi metadata file missing")
      }

      if (!is.null(df_bact) && !is.null(df_fun)) {
        validation$file_uploaded <- TRUE

        if (sample_b != "" && sample_b %in% colnames(df_bact) &&
            sample_f != "" && sample_f %in% colnames(df_fun)) {
          validation$sample_cols_ok <- TRUE
        }

        if (shared_col != "" &&
            shared_col %in% colnames(df_bact) &&
            shared_col %in% colnames(df_fun)) {
          validation$shared_key_ok <- TRUE
        }
      }

      if (shared_col != "" &&
          !is.null(df_bact) && shared_col %in% colnames(df_bact) &&
          !is.null(df_fun) && shared_col %in% colnames(df_fun)) {
        feedback[["shared_col"]] <- div(class = "validation-feedback feedback-success",
                                        bs_icon("check-circle"),
                                        " Shared key exists in both metadata files")
      } else {
        feedback[["shared_col"]] <- div(class = "validation-feedback feedback-danger",
                                        bs_icon("x-circle"),
                                        " Shared key column not found in one or both files")
      }

      sample_b <- input$sample_col_bacteria %||% ""
      sample_f <- input$sample_col_fungi %||% ""

      feedback[["sample_b"]] <- if (sample_b != "" && !is.null(df_bact) &&
                                    sample_b %in% colnames(df_bact)) {
        div(class = "validation-feedback feedback-success",
            bs_icon("check-circle"),
            " 16S Sample ID column found: ", code(sample_b))
      } else {
        div(class = "validation-feedback feedback-danger",
            bs_icon("x-circle"), " 16S Sample ID column missing")
      }

      feedback[["sample_f"]] <- if (sample_f != "" && !is.null(df_fun) &&
                                    sample_f %in% colnames(df_fun)) {
        div(class = "validation-feedback feedback-success",
            bs_icon("check-circle"),
            " 18S Sample ID column found: ", code(sample_f))
      } else {
        div(class = "validation-feedback feedback-danger",
            bs_icon("x-circle"), " 18S Sample ID column missing")
      }

    ## Dual Kingdoms & 1 metadata file (case 3)
    } else if (input$kingdom_mode == "Dual Kingdoms" &&
               input$dual_file_mode == "One file with paired kingdom info") {

      df <- values$metadata_single
      sample_b <- input$sample_col_bacteria %||% ""
      sample_f <- input$sample_col_fungi %||% ""
      shared_col <- input$shared_key %||% ""

      if (!is.null(df)) {
        validation$file_uploaded <- TRUE
        feedback[["file"]] <- div(class = "validation-feedback feedback-success",
                                  bs_icon("check-circle"), " Combined metadata file uploaded")

        # Sample columns
        valid_sample_b <- sample_b != "" && sample_b %in% colnames(df)
        valid_sample_f <- sample_f != "" && sample_f %in% colnames(df)

        validation$sample_cols_ok <- valid_sample_b && valid_sample_f

        feedback[["sample_b"]] <- if (valid_sample_b) {
          div(class = "validation-feedback feedback-success",
              bs_icon("check-circle"), " 16S Sample ID column found: ", code(sample_b))
        } else {
          div(class = "validation-feedback feedback-danger",
              bs_icon("x-circle"), " 16S Sample ID column missing or invalid")
        }

        feedback[["sample_f"]] <- if (valid_sample_f) {
          div(class = "validation-feedback feedback-success",
              bs_icon("check-circle"), " 18S Sample ID column found: ", code(sample_f))
        } else {
          div(class = "validation-feedback feedback-danger",
              bs_icon("x-circle"), " 18S Sample ID column missing or invalid")
        }

        # Shared key
        shared_key_ok <- shared_col != "" && shared_col %in% colnames(df)
        validation$shared_key_ok <- shared_key_ok

        feedback[["shared_col"]] <- if (shared_key_ok) {
          div(class = "validation-feedback feedback-success",
              bs_icon("check-circle"),
              " Shared key column found: ", code(shared_col))
        } else {
          div(class = "validation-feedback feedback-danger",
              bs_icon("x-circle"),
              " Shared key column missing or invalid")
        }
      } else {
        feedback[["file"]] <- div(class = "validation-feedback feedback-danger",
                                  bs_icon("x-circle"), " No metadata file uploaded")
      }

    do.call(tagList, feedback)
    }
  })

  ## Kingdom Sample Matching and Resolution ####
  ### Sample Matching Checks	 ####
  output$kingdom_match_feedback <- renderUI({
    req(values$metadata_bacteria, values$metadata_fungi)
    req(input$shared_key)

    df_b <- values$metadata_bacteria
    df_f <- values$metadata_fungi
    key <- input$shared_key

    # Validate key columns exist
    if (!(key %in% colnames(df_b)) || !(key %in% colnames(df_f))) {
      return(div(class = "validation-feedback feedback-danger",
                 bs_icon("x-circle"), " Shared key column not found in both metadata files"))
    }

    # Extract unique sample IDs
    bac_ids <- unique(na.omit(df_b[[key]]))
    fun_ids <- unique(na.omit(df_f[[key]]))

    n_bac <- length(bac_ids)
    n_fun <- length(fun_ids)
    shared <- intersect(bac_ids, fun_ids)
    n_shared <- length(shared)

    # validation$shared_overlap_ok <- (n_bac == n_fun) && (n_bac == n_shared)

    #### Count Display ####
    tagList(
      h5("Sample Counts:"),
      div(
        class = if (n_bac == n_fun) "validation-feedback feedback-success"
        else "validation-feedback feedback-warning",
        bs_icon(if (n_bac == n_fun) "check-circle" else "exclamation-triangle"),
        paste("🦠 16S / Bacteria Samples:", n_bac)
      ),
      div(
        class = if (n_bac == n_fun) "validation-feedback feedback-success"
        else "validation-feedback feedback-warning",
        bs_icon(if (n_bac == n_fun) "check-circle" else "exclamation-triangle"),
        paste("🍄 ITS / Fungi Samples:", n_fun)
      )
    )
  })

  ### Show Mismatched Samples + Previews ####
  output$sample_overlap_check <- renderUI({
    req(values$metadata_bacteria, values$metadata_fungi, input$shared_key)

    df_b <- values$metadata_bacteria
    df_f <- values$metadata_fungi
    key  <- input$shared_key

    bac_ids <- unique(na.omit(df_b[[key]]))
    fun_ids <- unique(na.omit(df_f[[key]]))

    missing_in_fun <- setdiff(bac_ids, fun_ids)
    missing_in_bac <- setdiff(fun_ids, bac_ids)

    feedback <- list(
      h5("Overlap Check:")
    )

    if (length(missing_in_fun) == 0 && length(missing_in_bac) == 0) {
      feedback <- append(feedback, list(
        div(class = "validation-feedback feedback-success",
            bs_icon("check-circle"), "All sample IDs match between kingdoms")
      ))
    } else {
      if (length(missing_in_fun) > 0) {
        feedback <- append(feedback, list(
          div(class = "validation-feedback feedback-danger",
              bs_icon("x-circle"),
              paste("❌ 🦠 16S sample IDs missing in fungal metadata:", length(missing_in_fun))),
          DT::renderDataTable({
            data.frame("Missing in Fungi" = head(missing_in_fun, 10))
          })
        ))
      }
      if (length(missing_in_bac) > 0) {
        feedback <- append(feedback, list(
          div(class = "validation-feedback feedback-danger",
              bs_icon("x-circle"),
              paste("❌ 🍄 Fungal sample IDs missing in bacterial metadata:", length(missing_in_bac))),
          DT::renderDataTable({
            data.frame("Missing in Bacteria" = head(missing_in_bac, 10))
          })
        ))
      }
    }

    do.call(tagList, feedback)
  })

  ## show_resolution_controls - UI Gating Logic ####
  # This reactive output returns TRUE if sample IDs differ across metadata tables.
  # It is used in the UI to conditionally display the "Choose resolution strategy" options.
  output$show_resolution_controls <- reactive({
    # Make sure both metadata files and the shared key exist before evaluating
    req(values$metadata_bacteria, values$metadata_fungi, input$shared_key)

    key <- input$shared_key

    # Extract sample ID values from both metadata tables using the shared key
    bac_ids <- unique(na.omit(values$metadata_bacteria[[key]]))
    fun_ids <- unique(na.omit(values$metadata_fungi[[key]]))

    # Return TRUE only if there are mismatches in either direction
    length(setdiff(bac_ids, fun_ids)) > 0 || length(setdiff(fun_ids, bac_ids)) > 0
  })

  # Ensure the UI will re-render when this output changes,
  # even if it goes from TRUE → FALSE or vice versa
  outputOptions(output, "show_resolution_controls", suspendWhenHidden = FALSE)


  ## Resolution Strategy Application - Action Handler - resolve_mismatch/subsetting ####
  # Apply user-selected resolution strategy. This event is triggered when the user clicks the "Apply Strategy" button
  observeEvent(input$resolve_mismatch, {
    req(values$metadata_bacteria, values$metadata_fungi, input$shared_key)
    df_b <- values$metadata_bacteria
    df_f <- values$metadata_fungi
    key <- input$shared_key

    ids_b <- unique(na.omit(df_b[[key]]))
    ids_f <- unique(na.omit(df_f[[key]]))

    strat <- input$subset_strategy
    all_ids <- union(ids_b, ids_f)
    shared_ids <- intersect(ids_b, ids_f)

    if (strat == "intersect") {
      values$metadata_bacteria <- dplyr::filter(df_b, .data[[key]] %in% shared_ids)
      values$metadata_fungi    <- dplyr::filter(df_f, .data[[key]] %in% shared_ids)

    } else if (strat == "keep_16S") {
      pad <- dplyr::tibble(!!key := setdiff(ids_b, ids_f)) %>%
        dplyr::left_join(dplyr::distinct(df_b, .data[[key]]), by = key)
      values$metadata_fungi <- bind_rows(dplyr::filter(df_f, .data[[key]] %in% ids_f), pad)
      values$metadata_bacteria <- df_b

    } else if (strat == "keep_18S") {
      pad <- dplyr::tibble(!!key := setdiff(ids_f, ids_b)) %>%
        dplyr::left_join(dplyr::distinct(df_f, .data[[key]]), by = key)
      values$metadata_bacteria <- bind_rows(dplyr::filter(df_b, .data[[key]] %in% ids_b), pad)
      values$metadata_fungi <- df_f

    } else if (strat == "union") {
      all_keys <- tibble(!!key := all_ids)
      values$metadata_bacteria <- dplyr::right_join(df_b, all_keys, by = key)
      values$metadata_fungi    <- dplyr::right_join(df_f, all_keys, by = key)
    }

    validation$resolution_applied <- TRUE

    showNotification(paste("Applied strategy:", strat), type = "message")
  })

  # ## categorization body function ####
  # categorization_body <- function() {
  #   tagList(
  #     # Short description
  #     p("Drag and drop metadata column names into the category boxes to the right and below."),
  #
  #     # Collapsible explanation
  #     tags$details(
  #       tags$summary("Learn more about how column categorization is used", style = "cursor: pointer;"),
  #       p(
  #         "These will be stored for downstream processing for easier access during statistical testing.",
  #         "For example, to answer questions such as:",
  #         tags$ul(
  #           tags$li("Are any of my environmental variables spatially patterned?"),
  #           tags$li("How do microbial communities change under different Treatment conditions by Host?"),
  #           tags$li("Does that variation change over Time?")
  #         ),
  #         "It is perfectly fine to leave columns in the 'Unassigned' category — they will still be retained."
  #       )
  #     ),
  #
  #     uiOutput("metadata_column_sorter"),
  #
  #     actionButton("save_metadata_categorization", "Save Column Categories", class = "btn-success mt-3")
  #   )
  # }

  # categorization_enabled <- optionalSectionServer(
  #   id = "metadata_categorization",
  #   render_body = categorization_body
  # )

  # ## Render Drag-and-Drop UI to Categorize Metadata Columns ####
  # output$metadata_column_sorter <- renderUI({
  #   # Use the post-resolution metadata (assumes 16S and 18S aligned via shared key)
  #   req(values$metadata_bacteria, input$shared_key)
  #
  #   df <- values$metadata_bacteria
  #   colnames_to_categorize <- setdiff(colnames(df), input$shared_key)
  #
  #   # Create sortable UI
  #   bucket_list(
  #     header = "Drag each metadata column name into an appropriate category",
  #     group_name = "metadata_columns",
  #
  #     add_rank_list("Unassigned", colnames_to_categorize, input_id = "unassigned_cols"),
  #
  #     add_rank_list("Sample Info",  NULL, input_id = "sample_info"),
  #     add_rank_list("Spatial (GPS)", NULL, input_id = "gps_info"),
  #     add_rank_list("Location (non-GPS)", NULL, input_id = "location_info"),
  #     add_rank_list("Treatment", NULL, input_id = "treatment_info"),
  #     add_rank_list("Environmental", NULL, input_id = "environmental_info"),
  #     add_rank_list("Host-Associated", NULL, input_id = "host_info"),
  #     add_rank_list("Temporal", NULL, input_id = "temporal_info")
  #   )
  # })
  #
  # ### Observe, Capture and Store Categorization ####
  # observeEvent(input$save_metadata_categorization, {
  #   if (!categorization_enabled()) {
  #     validation$columns_categorized <- TRUE
  #     values$metadata_categorized <- "skipped"
  #     return()
  #   }
  #   req(values$metadata_bacteria, input$shared_key)
  #
  #   df <- values$metadata_bacteria
  #   id_col <- input$shared_key
  #
  #   # Function to create each category df
  #   build_category <- function(cols) {
  #     if (length(cols) == 0) return(NULL)
  #     df_selected <- df[, c(id_col, cols), drop = FALSE]
  #     return(df_selected)
  #   }
  #
  #   values$metadata_categorized <- list(
  #     sample_info     = build_category(input$sample_info),
  #     gps_info        = build_category(input$gps_info),
  #     location_info   = build_category(input$location_info),
  #     treatment   = build_category(input$treatment_info),
  #     environmental   = build_category(input$environmental_info),
  #     host_associated = build_category(input$host_info),
  #     temporal        = build_category(input$temporal_info)
  #   )
  #
  #   validation$columns_categorized <- TRUE
  #
  #   showNotification("Metadata columns categorized successfully!", type = "message")
  # })

  # how to access later:
  # values$metadata_categorized$environmental

# SERV-GPS format detection + selection ####
  # - Pull only the columns placed in the "Spatial (GPS)" category
  # - Show a radio button group per column to let the user select the format

#   ## GPS column structure ####
#   output$gps_column_structure_ui <- renderUI({
#     req(values$metadata_categorized$gps_info)
#
#     gps_df <- values$metadata_categorized$gps_info
#     gps_cols <- setdiff(colnames(gps_df), input$shared_key)
#
#     if (length(gps_cols) == 0) {
#       return(NULL)  # No GPS columns provided, nothing to ask
#     }
#
#     tagList(
#       p("How is your GPS information structured?"),
#       radioButtons("gps_structure_type", NULL,
#                    choices = c("Single column" = "single", "Two columns (Latitude & Longitude)" = "two"),
#                    selected = "two"
#       ),
#       conditionalPanel(
#         condition = "input.gps_structure_type == 'two'",
#         selectInput("gps_lat_col", "Select Latitude column:", choices = gps_cols),
#         selectInput("gps_lon_col", "Select Longitude column:", choices = gps_cols)
#       ),
#       conditionalPanel(
#         condition = "input.gps_structure_type == 'single'",
#         selectInput("gps_single_col", "Select the single column containing both coordinates:",
#                     choices = gps_cols)
#       )
#     )
#   })
#
#   ## GPS format detection + selection ####
#   output$gps_format_ui <- renderUI({
#     req(values$metadata_categorized$gps_info)
#
#     gps_df <- values$metadata_categorized$gps_info
#     gps_cols <- setdiff(colnames(gps_df), input$shared_key)
#
#     if (length(gps_cols) == 0) {
#       return(div(
#         class = "validation-feedback feedback-warning",
#         p("No columns were placed into the Spatial (GPS) category."),
#         checkboxInput("gps_none_confirmed", "Confirm: This dataset has no GPS data", value = FALSE)
#       ))
#     }
#
#     gps_structure <- input$gps_structure_type %||% "unspecified"
#
#     if (gps_structure == "single") {
#       req(input$gps_single_col)
#
#       tagList(
#         p("Select the format used in the combined GPS coordinate column:"),
#         radioButtons(
#           inputId = paste0("gps_format_", input$gps_single_col),
#           label = paste("Column:", input$gps_single_col),
#           choices = c(
#             "Decimal degrees, comma-separated (e.g., 35.6, -106.3)" = "decimal_comma",
#             "DMS (degrees-minutes-seconds) combined (e.g., 35°45′N 106°33′W)" = "dms_combined",
#             "UTM full string (e.g., 13S 432000 3974000)" = "utm_single",
#             "Other / unknown" = "other"
#           ),
#           selected = "decimal_comma"
#         )
#       )
#
#     } else if (gps_structure == "two") {
#     # Render a format picker for each selected lat/lon column
#     tagList(
#       div(class = "validation-section",
#           h4("GPS Coordinate Format"),
#           p("Please select the format used for each column you placed into the Spatial (GPS) category."),
#           tags$ul(
#             lapply(gps_cols, function(col) {
#               radioButtons(
#                 inputId = paste0("gps_format_", col),
#                 label = paste("Column:", col),
#                 choices = c(
#                   "Decimal degrees (e.g., -106.12345)" = "decimal",
#                   "DMS (degrees-minutes-seconds, e.g., 35°45'23\"N)" = "dms",
#                   "UTM (e.g., 13S 432000 3974000)" = "utm",
#                   "Other / unknown format" = "other"
#                 ),
#                 selected = "decimal"
#               )
#             })
#           )
#       )
#     )
#   }
# })
#
#   ### optional gps ####
#   gps_enabled <- optionalSectionServer("gps_section", render_body = function() {
#     uiOutput("gps_format_ui")
#   })
#   # gps_enabled <- optionalSection_Server(
#   #   id = "gps_section",
#   #   render_body = function() {
#   #     uiOutput("gps_format_ui")
#   #   }
#   # )
#
#   observeEvent(input$save_gps_format, {
#     if (isTRUE(gps_enabled())) {
#       # perform format saving as usual
#     } else {
#       validation$gps_format_selected <- TRUE  # Skip, but mark as "valid"
#       values$gps_column_formats <- "skipped"
#     }
#   })
#
#   ### Save GPS Format - Capture Choices When "Save GPS Format" is Clicked
#   observeEvent(input$save_gps_format, {
#     gps_df <- values$metadata_categorized$gps_info
#     gps_cols <- setdiff(colnames(gps_df), input$shared_key)
#
#     values$gps_column_formats <- list()
#
#     gps_structure <- input$gps_structure_type %||% "unspecified"
#
#     if (gps_structure == "single" && !is.null(input$gps_single_col)) {
#       col <- input$gps_single_col
#       format_selected <- input[[paste0("gps_format_", col)]] %||% "unspecified"
#       values$gps_column_formats[[col]] <- format_selected
#
#     } else if (gps_structure == "two") {
#       for (col in gps_cols) {
#         input_id <- paste0("gps_format_", col)
#         format_selected <- input[[input_id]] %||% "unspecified"
#         values$gps_column_formats[[col]] <- format_selected
#       }
#     }
#
#     # Final validation flag
#     validation$gps_format_selected <- all(
#       sapply(values$gps_column_formats, function(x) x != "unspecified")
#     )
#
#     if (validation$gps_format_selected) {
#       showNotification("GPS format(s) saved successfully.", type = "message")
#     } else {
#       showNotification("Please complete all GPS format selections.", type = "error")
#     }
#   })
#



  # # Email validation
  # output$email_feedback <- renderUI({
  #   if (is.null(input$email_input) || input$email_input == "") {
  #     return(NULL)
  #   }
  #
  #   email <- input$email_input
  #   email_pattern <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[A-Za-z]{2,}$"
  #
  #   if (grepl(email_pattern, email)) {
  #     validation$email <- TRUE
  #     div(class = "validation-feedback feedback-success",
  #         bs_icon("check-circle"), " Valid email address")
  #   } else {
  #     validation$email <- FALSE
  #     div(class = "validation-feedback feedback-danger",
  #         bs_icon("x-circle"), " Please enter a valid email address")
  #   }
  # })
  #
  # # Password validation
  # output$password_validation <- renderUI({
  #   password <- input$password_input %||% ""
  #   confirm <- input$password_confirm %||% ""
  #
  #   if (password == "") {
  #     validation$password <- FALSE
  #     validation$password_match <- FALSE
  #     return(NULL)
  #   }
  #
  #   # Password strength checks
  #   checks <- list(
  #     length = nchar(password) >= 8,
  #     lowercase = grepl("[a-z]", password),
  #     uppercase = grepl("[A-Z]", password),
  #     number = grepl("[0-9]", password),
  #     special = grepl("[^a-zA-Z0-9]", password)
  #   )
  #
  #   strength_score <- sum(unlist(checks))
  #   validation$password <- strength_score >= 4
  #
  #   # Password match check
  #   if (confirm != "") {
  #     validation$password_match <- password == confirm
  #   } else {
  #     validation$password_match <- FALSE
  #   }
  #
  #   # Strength meter
  #   strength_colors <- c("#dc3545", "#fd7e14", "#ffc107", "#20c997", "#198754")
  #   strength_levels <- c("Very Weak", "Weak", "Fair", "Good", "Strong")
  #   meter_color <- strength_colors[min(strength_score + 1, 5)]
  #   meter_width <- (strength_score / 5) * 100
  #
  #   # Requirements list
  #   requirement_items <- tagList(
  #     div(class = paste("requirement-item", if(checks$length) "text-success" else "text-danger"),
  #         bs_icon(if(checks$length) "check" else "x"), " At least 8 characters"),
  #     div(class = paste("requirement-item", if(checks$lowercase) "text-success" else "text-danger"),
  #         bs_icon(if(checks$lowercase) "check" else "x"), " Lowercase letter"),
  #     div(class = paste("requirement-item", if(checks$uppercase) "text-success" else "text-danger"),
  #         bs_icon(if(checks$uppercase) "check" else "x"), " Uppercase letter"),
  #     div(class = paste("requirement-item", if(checks$number) "text-success" else "text-danger"),
  #         bs_icon(if(checks$number) "check" else "x"), " Number"),
  #     div(class = paste("requirement-item", if(checks$special) "text-success" else "text-danger"),
  #         bs_icon(if(checks$special) "check" else "x"), " Special character")
  #   )
  #
  #   # Password match feedback
  #   match_feedback <- if (confirm != "") {
  #     if (validation$password_match) {
  #       div(class = "requirement-item text-success",
  #           bs_icon("check"), " Passwords match")
  #     } else {
  #       div(class = "requirement-item text-danger",
  #           bs_icon("x"), " Passwords do not match")
  #     }
  #   }
  #
  #   div(class = "password-requirements",
  #       div(
  #         strong("Password Strength: "),
  #         span(strength_levels[min(strength_score + 1, 5)],
  #              style = paste0("color: ", meter_color))
  #       ),
  #       div(class = "strength-meter",
  #           div(class = "strength-fill",
  #               style = paste0("width: ", meter_width, "%; background: ", meter_color))
  #       ),
  #       requirement_items,
  #       match_feedback
  #   )
  # })

  # # Numeric validation
  # output$numeric_feedback <- renderUI({
  #   feedback_items <- list()
  #
  #   # Age validation
  #   if (!is.null(input$age_input)) {
  #     if (is.na(input$age_input)) {
  #       validation$age <- FALSE
  #       feedback_items$age <- div(class = "validation-feedback feedback-danger",
  #                                 bs_icon("x-circle"), " Age must be a number")
  #     } else if (input$age_input < 13 || input$age_input > 120) {
  #       validation$age <- FALSE
  #       feedback_items$age <- div(class = "validation-feedback feedback-danger",
  #                                 bs_icon("x-circle"), " Age must be between 13 and 120")
  #     } else {
  #       validation$age <- TRUE
  #       feedback_items$age <- div(class = "validation-feedback feedback-success",
  #                                 bs_icon("check-circle"), " Valid age")
  #     }
  #   } else {
  #     validation$age <- FALSE
  #   }
  #
  # #   # Salary validation
  # #   if (!is.null(input$salary_input)) {
  # #     if (is.na(input$salary_input)) {
  # #       validation$salary <- FALSE
  # #       feedback_items$salary <- div(class = "validation-feedback feedback-danger",
  # #                                    bs_icon("x-circle"), " Salary must be a number")
  # #     } else if (input$salary_input < 0) {
  # #       validation$salary <- FALSE
  # #       feedback_items$salary <- div(class = "validation-feedback feedback-danger",
  # #                                    bs_icon("x-circle"), " Salary cannot be negative")
  # #     } else if (input$salary_input > 10000000) {
  # #       validation$salary <- FALSE
  # #       feedback_items$salary <- div(class = "validation-feedback feedback-warning",
  # #                                    bs_icon("exclamation-triangle"), " Please verify this salary amount")
  # #     } else {
  # #       validation$salary <- TRUE
  # #       feedback_items$salary <- div(class = "validation-feedback feedback-success",
  # #                                    bs_icon("check-circle"), " Valid salary")
  # #     }
  # #   } else {
  # #     validation$salary <- FALSE
  # #   }
  # #
  #   do.call(tagList, feedback_items)
  # })

  # # Business logic validation
  # output$business_logic_feedback <- renderUI({
  #   feedback_items <- list()
  #
  #   # Country and postal code validation
  #   country <- input$country_input %||% ""
  #   postal <- input$postal_code %||% ""
  #
  #   if (country != "" && postal != "") {
  #     # Define postal code patterns by country
  #     postal_patterns <- list(
  #       "USA" = "^\\d{5}(-\\d{4})?$",
  #       "Canada" = "^[A-Za-z]\\d[A-Za-z] ?\\d[A-Za-z]\\d$",
  #       "UK" = "^[A-Z]{1,2}\\d[A-Z\\d]? ?\\d[A-Z]{2}$",
  #       "Germany" = "^\\d{5}$",
  #       "France" = "^\\d{5}$"
  #     )
  #
  #     pattern <- postal_patterns[[country]]
  #     if (!is.null(pattern) && grepl(pattern, postal)) {
  #       validation$country_postal <- TRUE
  #       feedback_items$postal <- div(class = "validation-feedback feedback-success",
  #                                    bs_icon("check-circle"),
  #                                    paste("Valid", country, "postal code"))
  #     } else {
  #       validation$country_postal <- FALSE
  #       example_formats <- list(
  #         "USA" = "12345 or 12345-6789",
  #         "Canada" = "A1A 1A1",
  #         "UK" = "SW1A 1AA",
  #         "Germany" = "12345",
  #         "France" = "75001"
  #       )
  #       feedback_items$postal <- div(class = "validation-feedback feedback-danger",
  #                                    bs_icon("x-circle"),
  #                                    paste("Invalid format. Example for", country, ":",
  #                                          example_formats[[country]]))
  #     }
  #   } else if (country != "" && postal == "") {
  #     validation$country_postal <- FALSE
  #     feedback_items$postal <- div(class = "validation-feedback feedback-warning",
  #                                  bs_icon("exclamation-triangle"),
  #                                  "Please enter postal code for selected country")
  #   } else {
  #     validation$country_postal <- FALSE
  #   }
  #
  #   # Date range validation
  #   start_date <- input$start_date
  #   end_date <- input$end_date
  #
  #   if (!is.null(start_date) && !is.null(end_date)) {
  #     if (end_date <= start_date) {
  #       validation$date_range <- FALSE
  #       feedback_items$dates <- div(class = "validation-feedback feedback-danger",
  #                                   bs_icon("x-circle"),
  #                                   "End date must be after start date")
  #     } else if (as.numeric(end_date - start_date) > 365) {
  #       validation$date_range <- FALSE
  #       feedback_items$dates <- div(class = "validation-feedback feedback-warning",
  #                                   bs_icon("exclamation-triangle"),
  #                                   "Date range is longer than 1 year. Please verify.")
  #     } else {
  #       validation$date_range <- TRUE
  #       days_diff <- as.numeric(end_date - start_date)
  #       feedback_items$dates <- div(class = "validation-feedback feedback-success",
  #                                   bs_icon("check-circle"),
  #                                   paste("Valid date range (", days_diff, "days)"))
  #     }
  #   } else {
  #     validation$date_range <- FALSE
  #   }
  #
  #   do.call(tagList, feedback_items)
  # })


  # SERV-Test Col Cat ####
  columnCategorizationServer(
    id = "categorize",
    values = values,
    validation = validation,
    shared_key = reactive(input$shared_key),
    TRACTOR = TRACTOR
  )


  # SERV-Validation ##########
  ## Validation Summary ####
  ### Val Summary Column ####
  output$validation_summary <- renderUI({
    fields <- list(
      "Metadata File(s) Uploaded" = validation$file_uploaded,
      "Shared Key Present" = validation$shared_key_ok,
      "16S Sample Column Present" = validation$sample_col_b_ok,
      "ITS/18S Sample Column Present" = validation$sample_col_f_ok,
      "Sample Matching Resolved" = validation$resolution_applied,
      "Columns Categorized"       = validation$columns_categorized,
      "Columns Classified"       = validation$columns_classified,
      "GPS Format Selected" = validation$gps_format_selected
      # "Email" = validation$email,
      # "Password" = validation$password,
      # "Password Match" = validation$password_match,
      # "Age" = validation$age,
      # "Salary" = validation$salary,
      # "Postal Code" = validation$country_postal,
      # "Date Range" = validation$date_range
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

  ### Form metrics ####
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

  ## Enable/disable submit button ####
  observe({
    all_valid <- all(unlist(reactiveValuesToList(validation)))

    if (all_valid) {
      updateActionButton(session, "submit_form",
                         label = "Submit Form ✓",
                         disabled = FALSE)
    } else {
      updateActionButton(session, "submit_form",
                         label = "Submit Sample Metadata",
                         disabled = TRUE)
    }
  })

  # Form submission ####
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

  # SERV-Quick action buttons ####
  # observeEvent(input$fill_valid, {
  #   updateTextInput(session, "email_input", value = "user@example.com")
  #   updateTextInput(session, "password_input", value = "SecurePass123!")
  #   updateTextInput(session, "password_confirm", value = "SecurePass123!")
  #   updateNumericInput(session, "age_input", value = 25)
  #   updateNumericInput(session, "salary_input", value = 75000)
  #   updateSelectInput(session, "country_input", selected = "USA")
  #   updateTextInput(session, "postal_code", value = "12345")
  #   updateDateInput(session, "start_date", value = Sys.Date())
  #   updateDateInput(session, "end_date", value = Sys.Date() + 30)
  #
  #   showNotification("Form filled with valid data", type = "success")
  # })
  #
  # observeEvent(input$fill_invalid, {
  #   updateTextInput(session, "email_input", value = "invalid-email")
  #   updateTextInput(session, "password_input", value = "weak")
  #   updateTextInput(session, "password_confirm", value = "different")
  #   updateNumericInput(session, "age_input", value = 5)
  #   updateNumericInput(session, "salary_input", value = -1000)
  #   updateSelectInput(session, "country_input", selected = "USA")
  #   updateTextInput(session, "postal_code", value = "invalid")
  #   updateDateInput(session, "start_date", value = Sys.Date() + 10)
  #   updateDateInput(session, "end_date", value = Sys.Date())
  #
  #   showNotification("Form filled with invalid data", type = "warning")
  # })

  ## SERV-Clear All Inputs #####
  observeEvent(input$clear_all, {
    updateTextInput(session, "email_input", value = "")
    updateTextInput(session, "password_input", value = "")
    updateTextInput(session, "password_confirm", value = "")
    updateNumericInput(session, "age_input", value = NA)
    # updateNumericInput(session, "salary_input", value = NA)
    # updateSelectInput(session, "country_input", selected = "")
    # updateTextInput(session, "postal_code", value = "")
    # updateDateInput(session, "start_date", value = Sys.Date())
    # updateDateInput(session, "end_date", value = Sys.Date())

    showNotification("All fields cleared", type = "info")
  })
}


## SERV-TRACTOR Assembly Placeholder (observeEvent(input$submit_form)) ####
observeEvent(input$submit_form, {
  TRACTOR <- list(
    table = tibble::tibble(),  # placeholder for count data
    ranks = tibble::tibble(),  # placeholder for taxonomy
    attributes = switch(input$kingdom_mode,
                        "Single Kingdom" = values$metadata_single,
                        "Dual Kingdoms" = {
                          if (input$dual_file_mode == "Two separate metadata files") {
                            list(
                              bacteria = values$metadata_bacteria,
                              fungi = values$metadata_fungi
                            )
                          } else {
                            values$metadata_single
                          }
                        }
    ),
    clustering = tibble::tibble(),
    ties = list()
  )

  showNotification("TRACTOR object assembled!", type = "message")
  # print(TRACTOR) or further downstream use
})

shinyApp(ui = ui, server = server)
