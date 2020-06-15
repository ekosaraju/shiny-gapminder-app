library(gapminder)
library(plotly)
library(ggplot2)


ui <- fluidPage(
  h1("Gapminder Data Explorer"),
  # Create a container for tab panels
  tabsetPanel(
    # Create an "Inputs" tab
    tabPanel(
      p(""),
      p("Selections made on this panel will update the data on Chart and Data Table tabs."),
      title = "Make Selections",
      p("Select life expectancy. Default range is 55 - 75 years."),
      sliderInput(inputId = "life", label = "Life expectancy",
                  min = 0, max = 120,
                  value = c(55, 75)),
      p("Select continent."),
      selectInput("continent", "Continent",
                  choices = c("All", levels(gapminder$continent))),
      p("Click on the download button below to download the csv file of the data."),
      downloadButton("download_data")
    ),
    # Create a "Chart" tab
    tabPanel(
      title = "Chart",
      plotOutput("plot")
    ),
    # Create "Data Table" tab
    tabPanel(
      title = "Data Table",
      DT::dataTableOutput("table")
    )
  )
)

server <- function(input, output) {
  filtered_data <- reactive({
    data <- gapminder
    data <- subset(
      data,
      lifeExp >= input$life[1] & lifeExp <= input$life[2]
    )
    if (input$continent != "All") {
      data <- subset(
        data,
        continent == input$continent
      )
    }
    data
  })
  
  output$table <- DT::renderDataTable({
    data <- filtered_data()
    data
  })
  
  output$download_data <- downloadHandler(
    filename = "gapminder_data.csv",
    content = function(file) {
      data <- filtered_data()
      write.csv(data, file, row.names = FALSE)
    }
  )
  
  output$plot <- renderPlot({
    data <- filtered_data()
    ggplot(data, aes(gdpPercap, lifeExp)) +
      geom_point() +
      scale_x_log10()
  })
}

shinyApp(ui, server)