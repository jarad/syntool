library(plyr)
library(ggplot2)

d = read.csv("zimbabwe-measles.csv")

shinyServer(function(input, output) {

  raw <- reactive({
    inFile <- input$file1
    if (!is.null(inFile)) {
      d = read.csv(inFile$datapath)
      if (is.null(d$cases)) d$cases = 1
    }
    
    return(d)
  }) 


  output$aggregate <- renderUI({
    nms = setdiff(names(raw()), c("cases","date"))
    checkboxGroupInput("aggregate", "Aggregate by", nms, nms)
  }) 

  aggregated = reactive({    
    d = raw()
    d$date = as.Date(d$date, "%Y-%m-%d")

    ddply(d, setdiff(names(d), c(input$aggregate,"cases")), summarize, cases=sum(cases))
  })



  # Data output  
  output$data <- renderTable({
    d = aggregated()
    d$date = as.character(d$date)
    d
  })




  # Visualization 
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

    if (input$style=="sum") {
      nms = setdiff(names(d), c("cases","date"))
      d = ddply(d, nms, transform, cases=cumsum(cases))
    }

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


  # Detection
  output$detection = renderPlot({
    require(qcc)
    d = aggregated()
    qcc(d, sizes=d$cases, type="g")
  })


  # Help
  output$help = renderText({
    "This is a prototype for a syndromic surveillance visualization tool. You should be able to upload your data in the DATA tab using a csv file format. The csv file should have the following columns: date (YYYY-MM-DD)."
  })
})

