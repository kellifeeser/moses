# R/mod_explorer.R ---------------------------------------------------------

# ---------- UI -----------------------------------------------------------
mod_explorer_ui <- function(id) {
  ns <- NS(id)

  tagList(
    useShinyjs(),

    # Hidden tracker: wrap textInput in a div with `display:none;`
    div(
      style = "display:none;",
      textInput(
        ns("currentApp"),
        NULL,
        "home"
      )
    ),

    # --- LOAD DATA -------------------------------------------------------
    div(class = "load-data-section", style = "padding-left:130px;",
        div(id = ns("loadWrapper"),
            style = "position:relative; display:flex; align-items:center; gap:10px;",
            tags$div(id = ns("startHerePill"), class = "start-here-pill-left",
                     icon("circle-arrow-right"), "Start Here"),
            actionButton(ns("loadData"), "Load Data", class = "load-data-btn")
        ),
        uiOutput(ns("dataSourceMenu")),
        uiOutput(ns("preloadedUI")),
        uiOutput(ns("importUI")),
        uiOutput(ns("loadedDatasetLabel"))
    ),

    # --- BLUE BUTTON ROW -------------------------------------------------
    div(class = "nav-bar-with-dropdowns",
        style = "display:flex; justify-content:center; padding:10px;",
        uiOutput(ns("buttonRow"))       # generated from modules tibble
    ),

    # --- MAIN LAYOUT -----------------------------------------------------
    fluidRow(
      column(3,
             actionButton(ns("advancedMode"), "Advanced Mode", class = "advanced-mode-btn"),
             uiOutput(ns("advancedSidebarUI"))
      ),
      column(9,
             div(class = "main-frame",
                 uiOutput(ns("dynamicContent"))
             )
      )
    ),

    # --- JS --------------------------------------------------------------
    tags$script("
      function toggleExploreSubmenu(){
        var s=document.getElementById('exploreSubmenu');
        var a=document.querySelector('.arrow-down');
        if(!s) return;
        if(s.style.display==='none'||s.style.display===''){
          s.style.display='block'; a.classList.add('open');
        }else{ s.style.display='none'; a.classList.remove('open'); }
      }
    ")
  )
}

# ---------- SERVER -------------------------------------------------------
mod_explorer_server <- function(id, physeq_bac, physeq_fun) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    ## reactive flags
    values <- reactiveValues(data_loaded = FALSE,
                             data_source = NULL,
                             data_name   = NULL,
                             advanced_open = FALSE)

    ## ----- LOAD DATA HANDLERS ------------------------------------------
    observeEvent(input$loadData, {
      shinyjs::hide(ns("startHerePill"))
      values$data_loaded <- FALSE
      values$data_source <- NULL
      values$data_name   <- NULL
      showNotification("Please choose a data source", type = "message")
    })

    observeEvent(input$usePreloaded, { values$data_source <- "preloaded" })
    observeEvent(input$importData,   { values$data_source <- "import"     })

    observeEvent(input$loadRAM, {
      withProgress("Loading RAM dataset...", value = 0.4, {
        physeq_bac(readRDS("../data/PreloadedDatasets/RAM/Bac_wholecommunity.rds"))
        incProgress(0.3)
        physeq_fun(readRDS("../data/PreloadedDatasets/RAM/Fun_wholecommunity.rds"))
      })
      values$data_loaded <- TRUE
      values$data_name   <- "RAM"
      showNotification("RAM datasets loaded successfully!", type = "message")
    })

    ## ----- LOAD-DATA UIs ----------------------------------------------
    output$dataSourceMenu <- renderUI({
      req(!values$data_loaded)
      div(class="data-menu-panel", style="margin-top:15px;",
          h5("Select Data Type:"),
          actionButton(ns("usePreloaded"), "Use Preloaded Data",
                       class="btn btn-outline-primary"),
          actionButton(ns("importData"),   "Import My Data",
                       class="btn btn-outline-secondary")
      )
    })

    output$preloadedUI <- renderUI({
      req(!values$data_loaded, values$data_source == "preloaded")
      div(class="data-menu-panel", style="margin-top:10px;",
          h5("Available Preloaded Sets:"),
          actionButton(ns("loadRAM"), "RAM", class="btn btn-success"),
          actionButton(ns("placeholderPreloaded"), "Placeholder",
                       class="btn btn-secondary", disabled = TRUE)
      )
    })

    output$importUI <- renderUI({
      req(!values$data_loaded, values$data_source == "import")
      div(class="data-menu-panel", style="margin-top:10px;",
          h5("My Data Import Format:"),
          actionButton(ns("importExcel"),  "Excel (.csv)", class="btn btn-secondary", disabled=TRUE),
          actionButton(ns("importQIIME"),  "QIIME",        class="btn btn-secondary", disabled=TRUE),
          actionButton(ns("importDADA2"),  "dada2",        class="btn btn-secondary", disabled=TRUE),
          actionButton(ns("importPhyloseq"),"phyloseq",    class="btn btn-secondary", disabled=TRUE)
      )
    })

    output$loadedDatasetLabel <- renderUI({
      req(values$data_name)
      span(style="font-weight:600; color:#6c757d;",
           glue("Loaded: {values$data_name}"))
    })

    ## ----- ADVANCED SIDEBAR -------------------------------------------
    observeEvent(input$advancedMode, {
      values$advanced_open <- !values$advanced_open
    })

    output$advancedSidebarUI <- renderUI({
      req(values$advanced_open)
      adv <- modules |> filter(parent == "advanced")
      div(class = "advanced-sidebar",
          h4("Advanced tools"),
          lapply(seq_len(nrow(adv)), function(i){
            d <- adv[i,]
            aClass <- if (isReady(d$key) && ( !d$need_data || values$data_loaded))
              "advanced-nav-item" else "advanced-nav-item disabled"
            tags$a(d$title, class = aClass,
                   onclick = if (isReady(d$key))
                     glue("Shiny.setInputValue('{ns('currentApp')}', '{d$key}')"))
          }),
          tags$a("Explore data", class="advanced-nav-item",
                 onclick = "toggleExploreSubmenu()",
                 span(class="arrow-down","▼")),
          div(id="exploreSubmenu", class="submenu",
              tags$a("Taxonomy", class="advanced-nav-item",
                     onclick=glue("Shiny.setInputValue('{ns('currentApp')}','taxonomyExplore')")),
              tags$a("Metadata testing", class="advanced-nav-item",
                     onclick=glue("Shiny.setInputValue('{ns('currentApp')}','metadataTesting')")),
              tags$a("Spatial struct.", class="advanced-nav-item",
                     onclick=glue("Shiny.setInputValue('{ns('currentApp')}','spatialStruct')"))
          )
      )
    })

    ## ----- BLUE BUTTON ROW  (root buttons + dropdowns) -----------------
    output$buttonRow <- renderUI({
      root <- modules |> filter(parent == "root")
      tagList(lapply(seq_len(nrow(root)), function(i){
        r <- root[i,]
        ready  <- isReady(r$key)
        hasDD  <- any(modules$parent == r$key)
        btnID  <- ns(glue("{r$key}Btn"))
        mainBtn <- actionButton(btnID, r$title,
                                class="btn btn-primary btn-sm",
                                icon = icon(r$icon),
                                onclick = if (ready && !hasDD)
                                  glue("Shiny.setInputValue('{ns('currentApp')}', '{r$key}')"))
        if (!hasDD) return(mainBtn)

        dd <- modules |> filter(parent == r$key)
        div(class="dropdown-btn",
            mainBtn,
            div(class="dropdown-content",
                lapply(seq_len(nrow(dd)), function(j){
                  d <- dd[j,]
                  ready2 <- isReady(d$key) && (!d$need_data || values$data_loaded)
                  aClass <- if (ready2) "" else "disabled"
                  tags$a(d$title, class=aClass,
                         onclick = if (ready2)
                           glue("Shiny.setInputValue('{ns('currentApp')}', '{d$key}')"))
                })
            )
        )
      }))
    })

    ## ----- DYNAMIC CONTENT --------------------------------------------
    output$dynamicContent <- renderUI({
      app <- input$currentApp %||% "home"

      # HOME screen
      if (app == "home")
        return(div(class="content-placeholder",
                   h3("Welcome to the Data Explorer Platform"),
                   p("Load data with the blue button above to begin."),
                   p("Then explore via the MOOSE buttons or Advanced Mode.")))

      # Pre-rendered HTML?
      d <- modules |> filter(key == app)
      if (nrow(d) && !is.na(d$html)) return(includeHTML(d$html))

      # Shiny module UI
      if (app %in% names(module_ui_map)) return(module_ui_map[[app]](ns(app)))

      div("Module not found or not yet implemented.")
    })

    ## ----- CHILD MODULE SERVERS (research Qs, barplot, etc.) -----------
    observeEvent(input$currentApp, {
      k <- input$currentApp
      if (k %in% names(module_server_map))
        module_server_map[[k]](ns(k), physeq_bac, physeq_fun)
    })

    ## Placeholder text outputs -----------------------------------------
    output$placeholder1 <- renderText("Raw seq processing coming soon…")
    output$placeholder2 <- renderText("Annotation tools coming soon…")
  })
}
