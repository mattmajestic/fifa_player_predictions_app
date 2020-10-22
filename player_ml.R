library(caret)
library(dplyr)
library(stringr)
library(foreach)
library(doParallel)

data(iris)
fifa <- read.csv("fifa_19.csv") %>%
  dplyr::filter(Position != "GK") %>% 
  dplyr::slice(1:6000) %>% 
  dplyr::select(Crossing,Dribbling,Skill.Moves,Composure,Marking,Position,Overall) %>%
  dplyr::mutate(Position = if_else(str_detect(Position,"B"),"Defense","Attack") %>% as.factor())
# rename the dataset
dataset <- iris
dataset <- fifa

validation_index <- createDataPartition(dataset$Position, p=0.80, list=FALSE)

validation <- dataset[-validation_index,]

dataset <- dataset[validation_index,]

dim(dataset)

percentage <- prop.table(table(dataset$Position)) * 100
cbind(freq=table(dataset$Position), percentage=percentage)

summary(dataset)

x <- dataset[,1:5]
y <- dataset[,6]
featurePlot(x=x, y=y, plot="ellipse")
featurePlot(x=x, y=y, plot="box")


scales <- list(x=list(relation="free"), y=list(relation="free"))
featurePlot(x=x, y=y, plot="density", scales=scales)

control <- trainControl(method="cv", number=10)
metric <- "Accuracy"

library(e1071)
# a) linear algorithms
set.seed(7)
fit.lda <- train(Position~., data=dataset, method="lda", metric=metric, trControl=control)
# b) nonlinear algorithms
# CART
set.seed(7)
fit.cart <- train(Position~., data=dataset, method="rpart", metric=metric, trControl=control)
# kNN
set.seed(7)
fit.knn <- train(Position~., data=dataset, method="knn", metric=metric, trControl=control)
# c) advanced algorithms
# SVM
set.seed(7)
fit.svm <- train(Position~., data=dataset, method="svmRadial", metric=metric, trControl=control)
# Random Forest
set.seed(7)
fit.rf <- train(Position~., data=dataset, method="rf", metric=metric, trControl=control)

model_vec <- c("lda","rpart","knn","svmRadial","rf")
model_list <- list()

cores <- as.numeric(detectCores())
parallel_cluster <- makeCluster(cores - 1)
registerDoSNOW(cl)

foreach(model=1:length(model_vec)) %dopar% {
  set.seed(7)
  model_list[[model]] <- train(Position~., data=dataset, method=model_vec[model], metric=metric, trControl=control)
  print(paste0("This is ",as.numeric(model/length(model_vec) *100),"%"))
}

# summarize accuracy of models
results <- resamples(list(lda=fit.lda, cart=fit.cart, knn=fit.knn, svm=fit.svm, rf=fit.rf))
summary(results)

dotplot(results)

predictions <- predict(fit.lda, validation) 
confusionMatrix(predictions, validation$Position)