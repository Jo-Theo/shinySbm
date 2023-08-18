#' sbm_code UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_sbm_code_ui <- function(id){
  ns <- NS(id)
  tagList(
    strong("SBM code:"),
    verbatimTextOutput(ns("sbmCode"))
  )
}

#' sbm_code Server Functions
#'
#' @noRd
mod_sbm_code_server <- function(id,settings,networkType,exploreMin, exploreMax, directed,
                                dataset, sbm_main, sbm_current){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    sbm_code <- reactiveValues(
      applying = character(),
      change_block = character()
    )

    sbm_text <- reactive({
      paste(c(sbm_code$applying,
              sbm_code$change_block),
            collapse = '\n')
    })
    session$userData$sbm_code <- sbm_text

    observeEvent(settings$runSbm,{
      case_dep <- switch (networkType(),
                       "unipartite" = list(model = "Simple",
                                           directed = paste0(", directed = ",
                                                             directed())),
                       "bipartite" = list(model = "Bipartite",
                                          directed = "")
      )
      space_line_2 <- 36 + 3 * (networkType() == 'bipartite')
      space_line_3 <- 57 + 3 * (networkType() == 'bipartite')
      sbm_code$applying <- paste0(
        "mySbmModel <- sbm::estimate",case_dep$model,
        "SBM(netMat = myNetworkMatrix, model = ",dataset()$law,case_dep$directed,
        ",\n",paste(rep(' ',space_line_2),collapse ='')," estimOptions = list(plot = T, verbosity = ",
        session$userData$console_verbosity * 3,
        ifelse(settings$moreSettings %% 2  == 0,"",
               paste0(
                 ",\n",paste(rep(' ',space_line_3),collapse =''),
                 "exploreMin = ", exploreMin(),
                 ", exploreMax = ", exploreMax()
               )),
        "))"
      )
    })

    observeEvent(sbm_current(),{
      if (sum(sbm_main()$nbBlocks) != sum(sbm_current()$nbBlocks)) {
        sbm_code$change_block <- paste0(
          "index <- which(mySbmModel$storedModels['nbBlocks'] == ",
          sum(sbm_current()$nbBlocks), ")\n",
          "mySbmModel$setModel(index)"
        )
      } else {
        sbm_code$change_block <- ""
      }
    })

    output$sbmCode <- renderPrint({
      cat(sbm_text())
    })

  })
}

## To be copied in the UI
# mod_sbm_code_ui("sbm_code_1")

## To be copied in the server
# mod_sbm_code_server("sbm_code_1")