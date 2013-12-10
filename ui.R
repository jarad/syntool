shinyUI(pageWithSidebar(

  headerPanel("Syndromic surveillance visualization tool"),

  sidebarPanel(
    conditionalPanel(condition="input.conditionedPanels==1",
      fileInput('file1', 'Choose CSV File',
                accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),

      uiOutput("aggregate")
    ),

    conditionalPanel(condition="input.conditionedPanels==2",
      radioButtons("style", "Display by:",
                   list("New cases"="new","Cumulative cases"="sum")),
      uiOutput("color"),
      uiOutput("facet_row"),
      uiOutput("facet_col")
    )
  ),

  mainPanel(
    tabsetPanel(
      tabPanel("Data",      value=1, tableOutput("data"    )),
      tabPanel("Visualize", value=2, plotOutput("visualize")),
      tabPanel("Detection/Forecasting", value=3, plotOutput("detection")),
      tabPanel("Help",      value=4, textOutput("help")),
      id = "conditionedPanels"
    )
  )
))

