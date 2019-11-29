pacman::p_load(shiny,shinydashboard,dplyr,plotly,DT,rhandsontable,shinyWidgets)
source('loadData_soccerapp.R')

ui <- dashboardPage(dashboardHeader(title = "Soccer App"),
                    dashboardSidebar(sidebarMenu(menuItem("Basic EDA",tabName = "EDA",icon = icon('futbol')),
                                                 menuItem("Predictions", tabName = "Predict",icon = icon('futbol')))),
                    dashboardBody(
                      tabItems(
                        tabItem("EDA",
                                fluidPage(
                                  fluidRow(
                                    selectInput('nationality','Select Player Nationality',choices = unique(Fifa_data$Nationality)),
                                    sliderInput('players','Select Amount of Players to Look at',min = 11,max = 150,value = 50),
                                    plotlyOutput('box'),
                                    plotlyOutput('bar'),
                                    plotlyOutput('violin')))),
                        tabItem("Predict",
                                fluidPage(
                                  fluidRow(
                                    h2("Rate the Players between 1:10 in the Third Column"),
                                    pickerInput('variables','Select Important Player Characteristics',multiple = TRUE,choices = variables),
                                    actionButton("save_players",label = "Save When you Configure the Player List"),
                                    rHandsontableOutput("player_gen"),
                                    h3("Players You May Like"),
                                    dataTableOutput('predictions')
                                  )
                                ))
                        # fluidRow(
                        #   DTOutput('table'),
                        #   rHandsontableOutput('hot')
                      )))

server <- function(input,output,session){
  
  Fifa_reactive <- reactive({
    Fifa_filter <- Fifa_data %>% filter(Nationality == input$nationality) %>% arrange(desc(Overall)) 
    Fifa_filter[1:input$players,]
  })
  
  # Basic EDA #
  
  observeEvent(c("input$nationality","input$players"),{
    output$box <- renderPlotly({plot_ly(Fifa_reactive(),x=~Skill.Moves,y=~Overall,size=~Potential,text=~Name,color =~Overall,type = 'scatter')})
    output$bar <- renderPlotly({plot_ly(Fifa_reactive(),x=~Age,y=~Potential,type = 'violin')})
    output$violin <- renderPlotly({plot_ly(Fifa_reactive(),x=~Nationality,y=~Potential,type = 'violin')})
    #output$table <- renderDataTable({datatable(Fifa_reactive())})
    #output$hot <- renderRHandsontable({rhandsontable(Fifa_reactive())})
  })
  
  # Predictions #
  
  Fifa_player_gen <- reactive({
    player_gen <- sample(1:150,50)
    Fifa_data[player_gen,c('Name','Position','Club')] %>% mutate(Personal_Player_Rating = 5)
  })
  
  output$player_gen <- renderRHandsontable({rhandsontable(Fifa_player_gen())})
  
  observeEvent(input$save_players,{
    player_hot <- hot_to_r(input$player_gen)
    Fifa_lm_reactive <- reactive({
      fifa_v1 <- Fifa_data %>% filter(Name %in% player_hot$Name)
      merge(fifa_v1,player_hot)
    })
    Fifa_lm_predict <- reactive({
      Fifa_data[1:300,] %>% filter(!Name %in% player_hot$Name) %>% select(Name,Skill.Moves,Crossing,Finishing,Volleys,Dribbling,Agility,BallControl,SprintSpeed,Acceleration)
    })
    
    Fifa_lm <- lm(Personal_Player_Rating ~ Skill.Moves + Crossing + Finishing + Volleys + Dribbling + Agility + BallControl + SprintSpeed + Acceleration, data = Fifa_lm_reactive())
    output$predictions <- renderDataTable({
      predictions_df <- data.frame(cbind(Fifa_lm_predict(),data.frame("predictions" = predict(Fifa_lm,Fifa_lm_predict()))))
      predictions_df %>% arrange(desc(predictions)) %>% select(Name,predictions)
    })
    
  })
  
}

options(shiny.host = '0.0.0.0')
options(shiny.port = 8888)
shinyApp(ui,server)
