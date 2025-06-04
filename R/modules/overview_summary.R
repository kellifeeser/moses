# ─────────────────────────────────────────────────────────────────────────────
# File: R/modules/overview_summary.R
# Defines overview_summary_ui()  and overview_summary_srv()
# ─────────────────────────────────────────────────────────────────────────────

# UI function for “Overview / summary statistics”
overview_summary_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::fluidRow(
    # ───────────────────────────────────────────────────────────────────────────
    # Bacteria column (always width = 6). If physeq_bac() is NULL, the table will
    # be blank. Once data are loaded, overviewTableBac will render.
    shiny::column(
      width = 6,
      style = "text-align:center; margin-bottom:20px;",
      shiny::h4(shiny::strong("Bacteria")),
      shiny::tableOutput(ns("overviewTableBac"))
    ),

    # ───────────────────────────────────────────────────────────────────────────
    # Fungi column (always width = 6). If physeq_fun() is NULL, the table will
    # be blank. Once data are loaded, overviewTableFun will render.
    shiny::column(
      width = 6,
      style = "text-align:center; margin-bottom:20px;",
      shiny::h4(shiny::strong("Fungi")),
      shiny::tableOutput(ns("overviewTableFun"))
    )
  )
}


# Server logic for “Overview / summary statistics”
overview_summary_srv <- function(id, physeq_bac, physeq_fun) {
  shiny::moduleServer(id, function(input, output, session) {

    # ─────────────────────────────────────────────────────────────────────────
    # Bacteria summary table
    output$overviewTableBac <- shiny::renderTable({
      req(physeq_bac())  # only run if physeq_bac() is non-NULL

      # Basic summary statistics for bacteria phyloseq object:
      n_samps     <- phyloseq::nsamples(physeq_bac())
      n_taxa      <- phyloseq::ntaxa(physeq_bac())
      total_reads <- sum(phyloseq::sample_sums(physeq_bac()))

      richness_df   <- phyloseq::estimate_richness(
        physeq_bac(),
        measures = c("Observed", "Shannon")
      )
      mean_obs    <- round(mean(richness_df$Observed), 0)
      mean_shannon <- round(mean(richness_df$Shannon), 2)

      data.frame(
        Statistic = c("Samples", "Taxa", "Total reads", "Mean Observed OTUs", "Mean Shannon"),
        Value     = c(n_samps,   prettyNum(n_taxa, big.mark = ","),   prettyNum(total_reads, big.mark = ","),     mean_obs,       mean_shannon),
        check.names = FALSE,
        row.names   = NULL
      )
    }, striped = TRUE, hover = TRUE, spacing = "l")


    # ─────────────────────────────────────────────────────────────────────────
    # Fungi summary table
    output$overviewTableFun <- shiny::renderTable({
      req(physeq_fun())  # only run if physeq_fun() is non-NULL

      n_samps_f     <- phyloseq::nsamples(physeq_fun())
      n_taxa_f      <- phyloseq::ntaxa(physeq_fun())
      total_reads_f <- sum(phyloseq::sample_sums(physeq_fun()))

      richness_df_f   <- phyloseq::estimate_richness(
        physeq_fun(),
        measures = c("Observed", "Shannon")
      )
      mean_obs_f   <- round(mean(richness_df_f$Observed), 0)
      mean_shannon_f <- round(mean(richness_df_f$Shannon), 2)

      data.frame(
        Statistic = c("Samples", "Taxa", "Total reads", "Mean Observed", "Mean Shannon"),
        Value     = c(n_samps_f,  prettyNum(n_taxa_f, big.mark = ","),  prettyNum(total_reads_f, big.mark = ","),  mean_obs_f,  mean_shannon_f),
        check.names = FALSE,
        row.names   = NULL
      )
    }, striped = TRUE, hover = TRUE, spacing = "l")
  })
}
