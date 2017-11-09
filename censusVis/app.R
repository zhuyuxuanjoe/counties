library(shiny)
library(ggplot2)
library(dplyr)
# user interface

ui <- fluidPage(
  titlePanel(title = "USA Census Visualisation"),
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with information from the 2010 Census"),
      selectInput(inputId = "var",
                  label = "Choose a Variable",
                  choices = list("Percent White","Percent Black","Percent Hispanic","Percent Asian"),
                  selected = "Percent Asian")
    ),
    mainPanel(
      # textOutput(outputId = "selected_var"),
      plotOutput(outputId = "map")
    )
  )
)

#server

server <- function(input, output) {
  # output$selected_var = renderText(
  #   # print("You chose a variable"),
  #   paste("You have selected", input$var)
  
  output$map = renderPlot({
  
    counties <- reactive({
      
      race = readRDS("Data/counties.rds")
      
      counties_map = map_data("county")
      
      counties_map = counties_map %>%
        mutate(name = paste(region, subregion, sep = ","))
      
      right_join(race,counties_map,by = "name")
      
    })
    
    myrace = switch(input$var,
                    "Percent White" = counties()$white,
                    "Percent Black" = counties()$black,
                    "Percent Hispanic" = counties()$hispanic,
                    "Percent Asian" = counties()$asian)
    
  ggplot(counties(), aes(x = long, 
                       y = lat, 
                       group = group,
                       fill = myrace)) +
    geom_polygon()+
    scale_fill_gradient(low = "white",
                        high = "darkred") +
    theme_void()
  })
}

shinyApp(ui,server)