#' Column Categorization UI Module
#'
#' UI for categorizing metadata columns into conceptual groups, with an optional
#' nested section for GPS coordinate format selection.
#'
#' @param id The module namespace ID
columnCategorizationUI <- function(id) {
  ns <- NS(id)

  tagList(
    optionalSectionUI(
      id = ns("metadata_categorization"),
      title = "Categorize Metadata Columns",
      icon = bs_icon("columns-gap"),
      subtitle = "Uncheck to skip",
      body_ui = tagList(

        # ── Categorization UI ──
        p("Drag and drop metadata column names into the category boxes to the right and below."),

        tags$details(
          tags$summary("Learn more about how column categorization is used", style = "cursor: pointer;"),
          p(
            "These will be stored for downstream processing for easier access during statistical testing.",
            "For example, to answer questions such as:",
            tags$ul(
              tags$li("Are any of my environmental variables spatially patterned?"),
              tags$li("Which of my environmental variables correlate with community change, and by how much?"),
              tags$li("How do microbial communities change under different Treatment conditions by Host?"),
              tags$li("Does that variation change over Time?")
            ),
            "It is perfectly fine to leave columns in the 'Unassigned' category — they will still be retained."
          )
        ),

        uiOutput(ns("metadata_column_sorter")),

        actionButton(ns("save_metadata_categorization"), "Save Column Categories", class = "btn-success mt-3"),

        # ── Embedded GPS Format Subsection ──
        hr(),
        h5("GPS Column Format"),
        p("If you assigned any columns to the 'Spatial (GPS)' category, define how those coordinates are structured and formatted."),

        uiOutput(ns("gps_column_structure_ui")),

        h5("GPS Format Identification"),
        uiOutput(ns("gps_format_ui")),

        actionButton(ns("save_gps_format"), "Save GPS Format", class = "btn-success mt-3")
      )
    )
  )
}
