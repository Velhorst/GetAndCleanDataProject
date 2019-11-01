## Load libraries
library(dplyr)
library(reshape2)


## data directory
if(!file.exists("./data")){dir.create("./data")}
datadir <- "./data/UCI HAR Dataset"


# Load data  ----------------------------------------------------------

## Download data
if(!file.exists(datadir)){
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
  destf <- "./data/getdata_projectfiles_UCI HAR Dataset.zip"
  download.file(fileUrl,destfile = destf)
  unzip(destf)
}

## load activity labels
fp <- file.path(datadir,"activity_labels.txt")
act_labels <- read.table(fp,col.names = c("activityIndex","activity"))

## load features
fp <- file.path(datadir,"features.txt")
ftr_labels <- read.table(fp,col.names = c("featureIndex","features"))
# substitute "-" and ","
ftr_labels$features = gsub("[-,]","_",ftr_labels$features)
# remove characters ()
ftr_labels$features = gsub("[()]","",ftr_labels$features)

## Load training set
# Subject identifiers
fp <- file.path(datadir,"train","subject_train.txt")
subj_train <-  read.table(fp, col.names = "subjectId")
# training set, use features as columns
fp <- file.path(datadir,"train","X_train.txt")
x_train <-  read.table(fp,col.names = ftr_labels$features)
# training labels, use activitylabels
fp <- file.path(datadir,"train","y_train.txt")
y_train <-  read.table(fp,col.names = "activityIndex")
y_train$activity <- factor(y_train$activityIndex, 
                           levels = act_labels$activityIndex, 
                           labels = act_labels$activity)

## Load test set
# Subject identifiers
fp <- file.path(datadir,"test","subject_test.txt")
subj_test <-  read.table(fp, col.names = "subjectId")
# training set, use features as columns
fp <- file.path(datadir,"test","X_test.txt")
x_test <-  read.table(fp,col.names = ftr_labels$features)
# training labels, use activitylabels
fp <- file.path(datadir,"test","y_test.txt")
y_test <-  read.table(fp,col.names = "activityIndex")
y_test$activity <- factor(y_test$activityIndex, 
                          levels = act_labels$activityIndex, 
                          labels = act_labels$activity)


# Clean the data ----------------------------------------------------------



## Merge the training and the test sets to one dataset
train_xysubj = cbind(x_train,activity=y_train[,"activity"],subj_train)
test_xysubj = cbind(x_test,activity=y_test[,"activity"],subj_test)
merged_xysubj = rbind(train_xysubj,test_xysubj)

## Extracts only the measurements on the mean and standard deviation for each measurement
selection_xysubj <- select(merged_xysubj,
                           matches("mean|std"),
                           one_of("activity","subjectId"))

## From the selection, create a second, independent tidy data set with the average of each variable for each activity and each subject.
my_tidy_data <- melt(selection_xysubj,id=c("activity","subjectId"))
my_tidy_data <- dcast(my_tidy_data, 
                      activity + subjectId ~ variable,
                      mean)


# Save the data ----------------------------------------------------------

## Save data
write.table(my_tidy_data,"my_tidy_data.txt",row.name=FALSE,sep=';')
