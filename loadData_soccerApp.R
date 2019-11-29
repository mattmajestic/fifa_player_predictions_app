Fifa_data <- read.csv("/home/rstudio/fifa_19.csv") 
Fifa_data <- Fifa_data[,1:67]
variables <- c('Skill.Moves','Work.Rate','Crossing','Finishing','Volleys','Dribbling','Agility','BallControl','SprintSpeed','Acceleration')
