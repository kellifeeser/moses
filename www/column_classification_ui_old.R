# ─────────────────────────────────────────────────────────────
# column_classification_ui.R
# ─────────────────────────────────────────────────────────────
# This component defines the UI for:
# - Column Class Assignment
# - Nested GPS Format configuration (optional)

div(class = "validation-section",
    h4("Classify Metadata Columns"),
    p("Define the expected R class for each metadata column (e.g., numeric, factor, character)."),

    uiOutput("column_classification_ui"),

    actionButton("save_column_classes", "Save Column Types", class = "btn-success mt-3"),

    hr(),

    ## Nested Subsection: GPS Format (optional)
    optionalSectionUI(
      id = "gps_section",
      title = "GPS Coordinate Format",
      icon = bs_icon("geo-alt"),
      subtitle = "Define format and structure of any spatial metadata columns.",
      body_ui = tagList(
        uiOutput("gps_column_structure_ui"),
        uiOutput("gps_format_ui"),
        actionButton("save_gps_format", "Save GPS Format", class = "btn-success mt-3")
      )
    )
)
