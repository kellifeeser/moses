#' Column Categorization Server Module
#'
#' Server logic for metadata column categorization and optional GPS format definition.
#'
#' @param id The module namespace ID
#' @param values A reactiveValues() list holding current metadata, including:
#'   - metadata_bacteria: post-resolution dataframe
#'   - metadata_categorized: result list for categorized data
#' @param validation A reactiveValues() list tracking validation flags
#' @param shared_key The name of the column used as the shared sample identifier
#' @param TRACTOR A reactiveValues-like list to store persistent outputs
columnCategorizationServer <- function(id, values, validation, shared_key, TRACTOR) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # ─────────────────────────────────────────────────────────────
    # Section toggle handling
    # ─────────────────────────────────────────────────────────────
    categorization_enabled <- optionalSectionServer(
      id = "metadata_categorization",
      render_body = function() {
        tagList(
          p("Drag and drop metadata column names into the category boxes..."),
          # Collapsible explanation
          tags$details(
            tags$summary("Learn more about how column categorization is used", style = "cursor: pointer;"),
            p(
              "These will be stored for downstream processing for easier access during statistical testing.",
              "For example, to answer questions such as:",
              tags$ul(
                tags$li("Are any of my environmental variables spatially patterned?"),
                tags$li("How do microbial communities change under different Treatment conditions by Host?"),
                tags$li("Does that variation change over Time?")
              ),
              "It is perfectly fine to leave columns in the 'Unassigned' category — they will still be retained."
            )
          ),

          uiOutput(ns("metadata_column_sorter")),
          actionButton(ns("save_metadata_categorization"), "Save Column Categories", class = "btn-success mt-3"),

          # GPS Subsection:
          hr(),
          h5("GPS Column Format"),
          p("If you assigned any columns to the 'Spatial (GPS)' category..."),
          uiOutput(ns("gps_column_structure_ui")),
          h5("GPS Format Identification"),
          uiOutput(ns("gps_format_ui")),
          actionButton(ns("save_gps_format"), "Save GPS Format", class = "btn-success mt-3")
        )
      }
    )

    gps_enabled <- optionalSectionServer(
      id = "gps_section",
      render_body = function() {
        uiOutput(ns("gps_format_ui"))
      }
    )

    # ─────────────────────────────────────────────────────────────
    # Render UI for Drag-and-Drop Categorization
    # ─────────────────────────────────────────────────────────────
    output$metadata_column_sorter <- renderUI({
      req(values$metadata_bacteria)
      df <- values$metadata_bacteria
      colnames_to_categorize <- setdiff(colnames(df), shared_key())

      bucket_list(
        header = "Drag each metadata column name into an appropriate category",
        group_name = "metadata_columns",
        add_rank_list("Unassigned", colnames_to_categorize, input_id = ns("unassigned_cols")),
        add_rank_list("Sample Info", NULL, input_id = ns("sample_info")),
        add_rank_list("Spatial (GPS)", NULL, input_id = ns("gps_info")),
        add_rank_list("Location (non-GPS)", NULL, input_id = ns("location_info")),
        add_rank_list("Treatment", NULL, input_id = ns("treatment_info")),
        add_rank_list("Environmental", NULL, input_id = ns("environmental_info")),
        add_rank_list("Host-Associated", NULL, input_id = ns("host_info")),
        add_rank_list("Temporal", NULL, input_id = ns("temporal_info"))
      )
    })

    # ─────────────────────────────────────────────────────────────
    # Save Categorization
    # ─────────────────────────────────────────────────────────────
    observeEvent(input$save_metadata_categorization, {
      if (!categorization_enabled()) {
        validation$columns_categorized <- TRUE
        values$metadata_categorized <- "skipped"
        return()
      }

      req(values$metadata_bacteria, shared_key())
      df <- values$metadata_bacteria
      id_col <- shared_key()

      build_category <- function(cols) {
        if (length(cols) == 0) return(NULL)
        df[, c(id_col, cols), drop = FALSE]
      }

      values$metadata_categorized <- list(
        sample_info     = build_category(input[[ns("sample_info")]]),
        gps_info        = build_category(input[[ns("gps_info")]]),
        location_info   = build_category(input[[ns("location_info")]]),
        treatment       = build_category(input[[ns("treatment_info")]]),
        environmental   = build_category(input[[ns("environmental_info")]]),
        host_associated = build_category(input[[ns("host_info")]]),
        temporal        = build_category(input[[ns("temporal_info")]])
      )

      TRACTOR$attributes$categorized <- values$metadata_categorized
      validation$columns_categorized <- TRUE

      showNotification("Metadata columns categorized successfully.", type = "message")
    })

    # ─────────────────────────────────────────────────────────────
    # GPS Column Format Handling (Conditional)
    # ─────────────────────────────────────────────────────────────
    output$gps_column_structure_ui <- renderUI({
      req(values$metadata_categorized$gps_info)
      gps_df <- values$metadata_categorized$gps_info
      gps_cols <- setdiff(colnames(gps_df), shared_key())

      if (length(gps_cols) == 0) return(NULL)

      tagList(
        p("How is your GPS information structured?"),
        radioButtons(ns("gps_structure_type"), NULL,
                     choices = c("Single column" = "single", "Two columns (Latitude & Longitude)" = "two"),
                     selected = "two"),
        conditionalPanel(
          condition = sprintf("input['%s'] == 'two'", ns("gps_structure_type")),
          selectInput(ns("gps_lat_col"), "Select Latitude column:", choices = gps_cols),
          selectInput(ns("gps_lon_col"), "Select Longitude column:", choices = gps_cols)
        ),
        conditionalPanel(
          condition = sprintf("input['%s'] == 'single'", ns("gps_structure_type")),
          selectInput(ns("gps_single_col"), "Select the single column containing both coordinates:",
                      choices = gps_cols)
        )
      )
    })

    output$gps_format_ui <- renderUI({
      req(values$metadata_categorized$gps_info)
      gps_df <- values$metadata_categorized$gps_info
      gps_cols <- setdiff(colnames(gps_df), shared_key())

      if (length(gps_cols) == 0) {
        return(div(
          class = "validation-feedback feedback-warning",
          p("No columns were placed into the Spatial (GPS) category."),
          checkboxInput(ns("gps_none_confirmed"), "Confirm: This dataset has no GPS data", value = FALSE)
        ))
      }

      gps_structure <- input$gps_structure_type %||% "unspecified"

      if (gps_structure == "single") {
        req(input$gps_single_col)

        tagList(
          p("Select the format used in the combined GPS coordinate column:"),
          radioButtons(
            inputId = ns(paste0("gps_format_", input$gps_single_col)),
            label = paste("Column:", input$gps_single_col),
            choices = c(
              "Decimal degrees, comma-separated" = "decimal_comma",
              "DMS combined" = "dms_combined",
              "UTM string" = "utm_single",
              "Other / unknown" = "other"
            ),
            selected = "decimal_comma"
          )
        )
      } else if (gps_structure == "two") {
        tagList(
          div(class = "validation-section",
              h4("GPS Coordinate Format"),
              p("Please select the format used for each GPS column."),
              tags$ul(
                lapply(gps_cols, function(col) {
                  radioButtons(
                    inputId = ns(paste0("gps_format_", col)),
                    label = paste("Column:", col),
                    choices = c(
                      "Decimal degrees" = "decimal",
                      "DMS" = "dms",
                      "UTM" = "utm",
                      "Other" = "other"
                    ),
                    selected = "decimal"
                  )
                })
              )
          )
        )
      }
    })

    # ─────────────────────────────────────────────────────────────
    # Save GPS Format Selection
    # ─────────────────────────────────────────────────────────────
    observeEvent(input$save_gps_format, {
      if (!isTRUE(gps_enabled())) {
        validation$gps_format_selected <- TRUE
        values$gps_column_formats <- "skipped"
        return()
      }

      gps_df <- values$metadata_categorized$gps_info
      gps_cols <- setdiff(colnames(gps_df), shared_key())

      values$gps_column_formats <- list()
      gps_structure <- input$gps_structure_type %||% "unspecified"

      if (gps_structure == "single" && !is.null(input$gps_single_col)) {
        col <- input$gps_single_col
        format_selected <- input[[ns(paste0("gps_format_", col))]] %||% "unspecified"
        values$gps_column_formats[[col]] <- format_selected

      } else if (gps_structure == "two") {
        for (col in gps_cols) {
          input_id <- ns(paste0("gps_format_", col))
          format_selected <- input[[input_id]] %||% "unspecified"
          values$gps_column_formats[[col]] <- format_selected
        }
      }

      TRACTOR$attributes$config$gps_format <- values$gps_column_formats
      TRACTOR$attributes$config$gps_structure <- list(
        structure = gps_structure,
        lat_col = input$gps_lat_col,
        lon_col = input$gps_lon_col,
        single_col = input$gps_single_col
      )

      validation$gps_format_selected <- all(
        sapply(values$gps_column_formats, function(x) x != "unspecified")
      )

      if (validation$gps_format_selected) {
        showNotification("GPS format(s) saved successfully.", type = "message")
      } else {
        showNotification("Please complete all GPS format selections.", type = "error")
      }
    })
  })
}
