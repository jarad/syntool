library(plyr)
library(ggplot2)

d = read.csv("zimbabwe-measles.csv")

shinyServer(function(input, output) {

  raw <- reactive({
    inFile <- input$file1
    if (is.null(inFile)) return(d)
    read.csv(inFile$datapath)
  }) 

  output$aggregate <- renderUI({
    nms = setdiff(names(raw()),c("cases","date"))
    checkboxGroupInput("aggregate", "Aggregate by", nms)
  }) 

  aggregated = reactive({    
    d = raw()
    d$date = as.Date(d$date, "%Y-%m-%d")

    ddply(d, setdiff(names(d), c(input$aggregate,"cases")), summarize, cases=sum(cases))
  })

  output$color = renderUI({
    nms = setdiff(names(aggregated()), c("cases","date"))
    selectInput('color', 'Color', c("None", nms))
  })

  output$facet_row = renderUI({
    nms = setdiff(names(aggregated()), c("cases","date"))
    selectInput('facet_row', 'Facet Row', c(None='.', nms))
  })

  output$facet_col = renderUI({
    nms = setdiff(names(aggregated()), c("cases","date"))
    selectInput('facet_col', 'Facet Column', c(None='.', nms))
  })

  output$visualize <- renderPlot({
    d = aggregated()

    p <- ggplot(d, aes(x=date, y=cases)) + geom_point()
    if (input$color != 'None')
      p <- p + aes_string(color=input$color)
    facets <- paste(input$facet_row, '~', input$facet_col)
    if (facets != '. ~ .')
      p <- p + facet_grid(facets)
#    if (input$jitter)
#      p <- p + geom_jitter()
#    if (input$smooth)
#      p <- p + geom_smooth()
    print(p)
  })

  output$contents <- renderTable({
    
    # input$file1 will be NULL initially. After the user selects and uploads a 
    # file, it will be a data frame with 'name', 'size', 'type', and 'datapath' 
    # columns. The 'datapath' column will contain the local filenames where the 
    # data can be found.

    d = aggregated()
    d$date = as.character(d$date)
    d
  })
})

