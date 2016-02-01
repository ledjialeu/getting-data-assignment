setwd("C:/Users/hp/Documents/courses/datascience/clean data")

# we load the reshape2 package which will be used in STEP 5
library(reshape2)
## STEP 0: load required packages

#download file from web and unzip
zipFile <- "DataSet.zip"
dataDir <- "UCI HAR Dataset"

if (!file.exists(dataDir)) {
  if (!file.exists(zipFile)) {
    fileURL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, zipFile)
  }
  
  if (!file.exists(dataDir)) {
    unzip(zipFile)
  }
}

testDir  <- paste0(dataDir, "/test")
trainDir <- paste0(dataDir, "/train")

## STEP 1: Merges the training and the test sets to create one data set
# load all data

test.subject    <- read.table(paste0(testDir, "/subject_test.txt"))
test.x          <- read.table(paste0(testDir, "/X_test.txt"))
test.y          <- read.table(paste0(testDir, "/y_test.txt"))

train.subject   <- read.table(paste0(trainDir, "/subject_train.txt"))
train.x         <- read.table(paste0(trainDir, "/X_train.txt"))
train.y         <- read.table(paste0(trainDir, "/y_train.txt"))

features        <- read.table(paste0(dataDir, "/features.txt"))
activity.labels <- read.table(paste0(dataDir, "/activity_labels.txt"))

# add column name for subject files
names(test.subject) <- "subjectID"
names(train.subject) <- "subjectID"

# add column names for measurement file
names(train.x) <- features$V2
names(test.x) <- features$V2

# add column name for label files
names(train.y) <- "activity"
names(test.y) <- "activity"

# combine files into one dataset
train <- cbind(train.subject, train.y, train.x)
test <- cbind(test.subject, test.y, test.x)
combined <- rbind(train, test)


## STEP 2: Extracts only the measurements on the mean and standard
## deviation for each measurement.

# determine which columns contain "mean()" or "std()"
meanstdcols <- grepl("mean\\(\\)", names(combined)) |
  grepl("std\\(\\)", names(combined))

# ensure that we also keep the subjectID and activity columns
meanstdcols[1:2] <- TRUE

# remove unnecessary columns
combined <- combined[, meanstdcols]


## STEP 3: Uses descriptive activity names to name the activities
## in the data set.


## STEP 4: Appropriately labels the data set with descriptive
## activity names. 

# convert the activity column from integer to factor
combined$activity <- factor(combined$activity, labels=c("Walking",
                                                        "Walking Upstairs", "Walking Downstairs", "Sitting", "Standing", "Laying"))


## STEP 5: Creates a second, independent tidy data set with the
## average of each variable for each activity and each subject.

# create the tidy data set
melted <- melt(combined, id=c("subjectID","activity"))
tidy <- dcast(melted, subjectID+activity ~ variable, mean)

# write the tidy data set to a file
write.csv(tidy, "tidy.csv", row.names=FALSE)