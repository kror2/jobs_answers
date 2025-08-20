library(readr)
library(dplyr)
library(lubridate)
library(pROC)
library(caret)
library(ROSE)

jobs <- read.csv("Jobs_wrangled.csv")
jobs <- jobs[,c("accepted","cat_1", "cat_2","cat_3", "cat_4", "cat_5",  "cat_6" ,"cat_7" , "cat_8",  "cat_9" , "hour_of_day",  "sunday", "monday" , "tuesday" ,
               "wednesday"  ,"thursday" ,"friday", "saturday",  "number_of_tradies" ,"impression_per_tradie" , "small",  "medium")]
set.seed(123)

idx <- createDataPartition(jobs$accepted, p = 0.75, list = FALSE)

train <- jobs[idx,]
test <- jobs[-idx,]

train_balanced <- ROSE(accepted~., data = jobs, seed =123)$data

logit <- glm(accepted ~ cat_1 + cat_2 + cat_3 + cat_4 + cat_5 + cat_6 + cat_7 + cat_8 + cat_9 + hour_of_day + sunday + monday + tuesday 
                        + wednesday + thursday + friday + saturday + number_of_tradies + impression_per_tradie + small + medium,
            data = train_balanced, family = binomial() )
summary(logit)

test$proba_logit <- predict(logit, newdata = test, typ = "response")

roc_logit <- roc(test$accepted, test$proba_logit)
print(auc(roc_logit))
test$pred_class <- ifelse(test$proba_logit > 0.5, 1,0 )

conf_matrix <- table (Predicted = test$pred_class, Actual = test$accepted)
print(conf_matrix)

accuracy <- mean(test$pred_class == test$accepted)
print(accuracy)
