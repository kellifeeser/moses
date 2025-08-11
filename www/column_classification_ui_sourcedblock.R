# ─────────────────────────────────────────────────────────────
# UI Component: Classify Metadata Columns (+ optional GPS)
# ─────────────────────────────────────────────────────────────

div(class = "validation-section",
    h4("Classify Metadata Columns"),

    # Short explainer
    p("Review and define the R data type (e.g., numeric, factor, character) for each metadata column."),

    # Optional: collapsible 'Learn more' explanation
    tags$details(
      tags$summary("Learn how column types are used", style = "cursor: pointer;"),
      p(
        "Column types help the app determine how to group, stratify, and model your data.",
        "For example:",
        tags$ul(
          tags$li("Factors define groups for statistical testing and ordination colorings."),
          tags$li("Ordered factors allow gradient-based models or visualizations."),
          tags$li("Numeric values are required for correlation, distance, or linear models.")
        ),
        "Your selections will be saved and stored with the dataset for reproducibility."
      )
    ),

    # UI: column class dropdowns rendered here
    uiOutput("column_classification_ui"),

    # Save button
    actionButton("save_column_classes", "Save Column Types", class = "btn-success mt-3"),

    # Optional coercion warning section
    uiOutput("coercion_preview"),

    hr(),

    # ───── Nested Subsection: GPS Format ─────
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
