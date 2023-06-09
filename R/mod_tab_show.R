#' tab_show UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_tab_show_ui <- function(id) {
  ns <- NS(id)
  ns_tab_upload <- function(id) {
    paste0("tab_upload_1-", id)
  }
  tagList(
    shinydashboard::box(
      title = "Visual settings", solidHeader = T,
      status = "info", collapsible = T,
      column(
        6,
        radioButtons(ns("whichShow"), "Type of visualisation",
          choices = list(
            "Plot a matrix" = "plot",
            "Print a table" = "print"
          ),
          inline = T
        ),
        radioButtons(ns("whichMatrix"), "Select Ploted Matrix",
          choices = list("Raw Matrix" = "raw")
        ),
        conditionalPanel(
          condition = "input.whichShow == 'plot'", ns = ns,
          hr(),
          fluidRow(
            column(
              width = 8,
              textInput(ns("fileName"),
                label = "File Name",
                value = "Shiny_Matrix_Plot"
              )
            ),
            column(
              width = 4,
              selectInput(ns("fileExtention"),
                "Extension",
                choices = list(
                  ".png" = ".png",
                  ".jpeg" = ".jpeg",
                  ".svg" = ".svg"
                ),
                selected = ".png",
                width = "600px"
              )
            )
          ),
          div(
            style = "display:inline-block; float:right",
            downloadButton(ns("downloadPlot"),
              label = " Save Plot",
              icon = icon("download", lib = "font-awesome")
            )
          )
        )
      ),
      column(
        6,
        conditionalPanel(
          condition = "input.whichShow == 'plot'", ns = ns,
          textInput(ns("setTitle"),
            label = "Title :",
            value = NULL
          ),
          checkboxInput(ns("showPred"), "Show Predicted Values", value = T),
          checkboxInput(ns("showLegend"), "Print legend", value = T),
          conditionalPanel(
            condition = "input.showLegend", ns = ns,
            textInput(ns("interactionName"),
              label = "Name of observed interraction",
              value = "Connection"
            )
          ),
          conditionalPanel(
            condition = "input.networkType == 'bipartite'", ns = ns_tab_upload,
            checkboxInput(ns("showTransposed"), "Invert Columns and Rows", value = F)
          )
        )
      )
    ),
    mod_select_nb_groups_ui(ns("select_nb_groups_1")),
    shinydashboard::box(
      title = "Color settings", solidHeader = T,
      status = "info", collapsible = T, collapsed = T, width = 3,
      colourpicker::colourInput(
        ns("colorValues"),
        label = "Select colour for initial values",
        value = "black"
      ),
      colourpicker::colourInput(
        ns("colorPred"),
        label = "Select colour for Predicted values",
        value = "red"
      )
    ),
    shinydashboard::box(
      title = "Plots", solidHeader = T,
      status = "info", width = 12,
      conditionalPanel(
        condition = "input.whichShow == 'print'", ns = ns,
        DT::dataTableOutput(ns("matrixPrint")),
        tags$head(tags$style(css_big_table(ns("matrixPrint"))))
      ),
      conditionalPanel(
        condition = "input.whichShow != 'print'", ns = ns,
        imageOutput(ns("matrixPlot"))
      )
    )
  )
}

#' tab_show Server Functions
#'
#' @noRd
mod_tab_show_server <- function(id, r) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    my_sbm <- mod_select_nb_groups_server(
      "select_nb_groups_1",
      r$sbm$main_sbm,
      r$upload$labels
    )

    output$matrixPrint <- DT::renderDataTable({
      # probleme : taille et position, wrapping des titres, fixer la colonnne de rownames
      req(input$whichShow)
      if (input$whichShow != "print") {
        return(NULL)
      }
      DT::datatable(
        as.data.frame(r$upload$Dataset()),
        extensions = c("FixedColumns", "FixedHeader", "KeyTable"),
        option = list(
          fixedHeader = TRUE,
          fixedColumns = list(leftColumns = 1),
          scrollX = T,
          scrollY = T,
          keys = TRUE,
          paging = F
        )
      ) %>%
        DT::formatStyle(c(1:dim(r$upload$Dataset())[2]), border = "1px solid #ddd")
    })


    PlotMat <- reactive({
      req(input$whichShow)
      if (input$whichShow == "plot") {
        x <- as.matrix(r$upload$Dataset())
        labels_list <- r$upload$labels()
        my_Options <- list(
          title =  if (input$setTitle == "") {
            NULL
          } else {
            input$setTitle
          },
          showLegend = input$showLegend,
          showPredictions = input$showPred,
          colPred = input$colorPred,
          colValue = input$colorValues,
          interactionName = input$interactionName
        )

        if (session$userData$vars$sbm$runSbm != 0) {
          data_sbm <- my_sbm()$clone()
          switch(input$whichMatrix,
            "raw" = plotSbm(data_sbm,
              ordered = FALSE, transpose = input$showTransposed,
              labels = labels_list,
              plotOptions = my_Options
            ),
            "ordered" = plotSbm(data_sbm,
              ordered = TRUE, transpose = input$showTransposed,
              labels = labels_list,
              plotOptions = my_Options
            ),
            "expected" = plotSbm(data_sbm,
              ordered = TRUE, transpose = input$showTransposed,
              labels = labels_list,
              plotOptions = c(my_Options, showValues = F)
            )
          )
        } else {
          plotSbm(x,
            transpose = input$showTransposed,
            labels = labels_list, plotOptions = my_Options
          )
        }
      } else {
        return(NULL)
      }
    })


    output$matrixPlot <- renderImage(
      {
        # Read myImage's width and height. These are reactive values, so this
        # expression will re-run whenever they change.
        width <- session$clientData$`output_tab_show_1-matrixPlot_width`
        height <- session$clientData$`output_tab_show_1-matrixPlot_height`

        # For high-res displays, this will be greater than 1
        pixelratio <- session$clientData$pixelratio

        # A temp file to save the output.
        outfile <- tempfile(fileext = ".png")

        # Generate the image file
        png(outfile,
          width = width * pixelratio, height = height * pixelratio,
          res = 72 * pixelratio
        )
        plot(PlotMat())
        dev.off()

        # Return a list containing the filename
        list(
          src = outfile,
          width = width,
          height = height
        )
      },
      deleteFile = TRUE
    )


    output$downloadPlot <- downloadHandler(
      filename = eventReactive(c(input$whichMatrix,input$fileName,input$fileExtention),{
        if(input$whichMatrix != 'raw'){
          add_group <- paste0('_',sum(my_sbm()$nbBlocks),'_blocks')
        }else{
          add_group <- ''
        }
        return(paste0(input$fileName,add_group,input$fileExtention))
      }),
      content = function(file) {
        width <- session$clientData$`output_tab_show_1-matrixPlot_width`
        height <- session$clientData$`output_tab_show_1-matrixPlot_height`
        pixelratio <- session$clientData$pixelratio
        switch(input$fileExtention,
          ".svg" = svg(file),
          ".jpeg" = jpeg(file,
            width = width * pixelratio, height = height * pixelratio,
            res = 72 * pixelratio, quality = 100
          ),
          ".png" = png(file,
            width = width * pixelratio, height = height * pixelratio,
            res = 72 * pixelratio
          )
        )
        print(PlotMat())
        dev.off()
      }
    )


    showParameters <- list(
      title =  reactive({if (input$setTitle == "") {
        NULL
      } else {
        input$setTitle
      }}),
      showLegend = reactive({input$showLegend}),
      showPredictions = reactive({input$showPred}),
      colPred = reactive({input$colorPred}),
      colValue = reactive({input$colorValues}),
      interactionName = reactive({input$interactionName}),
      whichMatrix = reactive({input$whichMatrix}),
      showTransposed = reactive({input$showTransposed})
    )

    return(showParameters)
  })
}








## To be copied in the UI
# mod_tab_show_ui("tab_show_1")

## To be copied in the server
# mod_tab_show_server("tab_show_1")
