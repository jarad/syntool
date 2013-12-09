shinyUI(pageWithSidebar(
  headerPanel("Syndromic surveillance"),

  sidebarPanel(
    fileInput('file1', 'Choose CSV File',
              accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),

    uiOutput("aggregate"),

    uiOutput("color"),
    uiOutput("facet_row"),
    uiOutput("facet_col")    
  ),

  mainPanel(
    tabsetPanel(
      tabPanel("Data", tableOutput('contents')),
      tabPanel("Visualize", plotOutput("visualize"))
    )
  )
))

