###
## run_analys.R
## author: "Ludi Akue (Lietwin)"
###

message("Cleaning the environment to avoid inconsistencies")
rm(list = ls())

message("Make sure that the data has been download in your working directory")
message("Make sure you set your working directory correctly. Hint: swd()")
#datadir <- "UCI_HAR_data"

if(!file.exists("UCI_HAR_data")){
    stop("Oops. Make sure the name of the UCI Human Activity Recognition data directory is UCI_HAR_datar")
}

if(!existsFunction("tbl_df")){
    library(dplyr)
}

message("Setting the files paths")

trainfeatfile <- "UCI_HAR_data/train/X_train.txt"
testfeatfile <- "UCI_HAR_data/test/X_test.txt"

trainactfile <- "UCI_HAR_data/train/y_train.txt"
testactfile <- "UCI_HAR_data/test/y_test.txt"

trainsubjectfile <- "UCI_HAR_data/train/subject_train.txt"
testsubjectfile <- "UCI_HAR_data/test/subject_test.txt"

featuresfile <- "UCI_HAR_data/features.txt"
activitiesfile <- "UCI_HAR_data/activity_labels.txt"

message("Charging the data sets")

## Getting train and test features measures data set
trainfeat <- read.table(trainfeatfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
testfeat <- read.table(testfeatfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")    

## Getting train and test activities data set
trainact <- read.table(trainactfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
testact <- read.table(testactfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")

## the same for subject data set
trainsubject <- read.table(trainsubjectfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
testsubject <- read.table(testsubjectfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")

message("1. Merging the training and the test sets to create one data set")
message("---> for the features measurements")

allfeat <- rbind(trainfeat, testfeat)
tidyfeat<- as.data.frame(sapply(allfeat, as.numeric))
tidyfeat<- tbl_df(tidyfeat)
## Preparing the variables names
features_dic <- read.table(featuresfile, header = FALSE, strip.white = TRUE, colClasses = "character")
names(tidyfeat) <- features_dic$V2


message("---> for the activities measurements")

allact <- rbind(trainact, testact)
tidyact<- tbl_df(allact)




message("---> for the subjects measurements")

allsubject <- rbind(trainsubject, testsubject)
names(allsubject) <- "subject"
tidysubject <- tbl_df(allsubject)


message("2. Extracting only the measurements on the mean and standard deviation for each measurement") 
## extract the mean and the sd
featmeansd <- tidyfeat[, grep("mean|std", names(tidyfeat))]

message("3. Uses descriptive activity names to name the activities in the data set")
## get activity labels as a translation dictionary
activity_dic <- read.table(activitiesfile, header = FALSE, strip.white = TRUE, colClasses = "character")
## into a nice tidy data
tidyact<- tbl_df(as.data.frame(apply(allact, 1, function(x) x = activity_dic$V2[as.numeric(x)])))
names(tidyact) <- "activity"


message("4. Appropriately labels the data set with descriptive variable names. ")
message("---> replacing prefix t by time")
names(tidyfeat) <- gsub("^t", "time", names(tidyfeat))

message("---> replacing prefix f by frequency")
names(tidyfeat) <- gsub("^f", "frequency", names(tidyfeat))

message("---> replacing Acc by Accelerometer")
names(tidyfeat) <- gsub("Acc", "Accelerometer", names(tidyfeat))

message("---> replacing Mag by Magnitude")
names(tidyfeat) <- gsub("Mag", "Magnitude", names(tidyfeat))

message("---> replacing Gyro by Gyroscope")
names(tidyfeat) <- gsub("Gyro", "Gyroscope", names(tidyfeat))

message("5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.")
## grabing all the means
featmean <- tidyfeat[, grep("mean", names(tidyfeat))]
tidysubjactfeat <- cbind(tidysubject,tidyact, featmean)
tidynew <- tbl_df(tidysubjactfeat)
tidynew <- tidynew %>% group_by(subject, activity) %>% summarise_each(funs(mean))
print(tidynew)

## save it to a file named tidydata.txt
write.table(tidynew, "tidydata.txt", row.names = FALSE)


