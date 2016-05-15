#set working directory
setwd("/Users/satya/Documents/courses/Bikesharing/")

#import datasets from working directory
train <- read.csv("train.csv") 
test <- read.csv("test.csv") 

#import necessary packages
library(ggplot2)

#####Feature Engineering function: accepts data frame, returns data frame
featureEngineer <- function(df) {
  
  #convert season, holiday, workingday and weather into factors
  names <- c("season", "holiday", "workingday", "weather")
  df[,names] <- lapply(df[,names], factor)
  
  #Convert datetime into timestamps (split day and hour)
  df$datetime <- as.character(df$datetime)
  df$datetime <- strptime(df$datetime, format="%Y-%m-%d %T", tz="EST") 
  
  #convert hours to factors in separate feature
  df$hour <- as.integer(substr(df$datetime, 12,13))
  df$hour <- as.factor(df$hour)
  df$month <- as.integer(substr(df$datetime,6,7))
  df$month <- as.factor(df$month)
  
  #Day of the week
  df$weekday <- as.factor(weekdays(df$datetime))

  #extract year from date and convert to factor
  df$year <- as.integer(substr(df$datetime, 1,4))
  df$year <- as.factor(df$year)
  
  df$tzone[df$temp<10]= c("A")
  df$tzone[df$temp>=10 & df$temp<20]= c("B")
  df$tzone[df$temp>=20 & df$temp<30]= c("C")
  df$tzone[df$temp>=30]= c("D")
  df$tzone <-as.factor(df$tzone)
  
  #add new hour
  df$newhour <- NULL
  df$newhour[df$hour %in% c("0","1","2","3","4","5","6")] <- c("A")
  df$newhour[df$hour %in% c("7","8","9")] <- c("B")
  df$newhour[df$hour %in% c("10","11","12","13","14","15","16")] <- c("C")
  df$newhour[df$hour %in% c("17","18","19")] <- c("D")
  df$newhour[df$hour %in% c("20","21","22","23")] <- c("E")
  df$newhour <- as.factor(df$newhour)
  
  #return full featured data frame
  return(df)
}


######MAIN######
#Build features for train and Test set
train <- featureEngineer(train)
train_input<-train[, !(colnames(train) %in% c("datetime","registered","count","casual"))]
train_logcasual <- log(train$casual+1)
train_logregistered <- log(train$registered +1)

test <- featureEngineer(test)
test_input <-test[, !(colnames(test) %in% c("datetime"))]

# Classification tree starts here

#variables
myNtree = 2000
ID=10
S=0.01
#set the random seed
set.seed(200)
#fit and predict log(casual) through gradient boosting decistion tree
casualFit <- gbm(train_logcasual~., data=train_input,shrinkage=S,n.trees=myNtree,interaction.depth=ID,distribution='gaussian')
test$logcasual<- predict(casualFit, newdata=test_input,n.trees=myNtree)
test$casual <- exp(test$logcasual)

#fit and predict log(registered) through gradient boosting decistion tree
registeredFit <- gbm(train_logregistered~., data=train_input,shrinkage=S,n.trees=myNtree,interaction.depth=ID,distribution='gaussian')
test$logregistered<- predict(registeredFit, newdata=test_input,n.trees=myNtree)
test$registered <- exp(test$logregistered)

#combine casual & registered
test$count <- round(test$casual + test$registered, 0)

#plotting data for reference
mt <- ggplot() +
  geom_point(data=train,aes(x=datetime,y=count,color="train")) +
  geom_point(data=test,aes(x=datetime,y=count, color="test")) +
  xlab("Datetime") +
  ylab("Count")  
mt
#we can see in this graph that the test data is roughly continuous w.r.t the sorrouding train data

####create output file from dataset test with predictions
submit <- data.frame (datetime = test$datetime, count = test$count)
write.csv(submit, file = "GBM.csv", row.names=FALSE)