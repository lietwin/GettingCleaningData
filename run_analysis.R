###
## run_analys.R
## author: "Ludi Akue (Lietwin)"
###

library("dplyr")

trainfile <- "UCI_HAR_data/train/X_train.txt"
testfile <- "UCI_HAR_data/test/X_test.txt"

trainactfile <- "UCI_HAR_data/train/y_train.txt"
testactfile <- "UCI_HAR_data/test/y_test.txt"

trainsubjectfile <- "UCI_HAR_data/train/subject_train.txt"
testsubjectfile <- "UCI_HAR_data/test/subject_test.txt"

featuresfile <- "UCI_HAR_data/features.txt"
activitiesfile <- "UCI_HAR_data/activity_labels.txt"


# Test if those files exist, if not
# read.table(file.choose(),  header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")

# Get the train and test data
# Test if those files exist, if not
# read.table(file.choose(),  header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
#if(file.exists(trainfile) & file.exists(testfile)){
    
trainfeat <- read.table(trainfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
testfeat <- read.table(testfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")    

## merge them
allfeat <- rbind(trainfeat, testfeat)

## transform to numeric
tidyfeat<- as.data.frame(sapply(allfeat, as.numeric))
tidyfeat<- tbl_df(tidyfeat)

# Preparing the variables names
cols <- read.table(featuresfile, header = FALSE, strip.white = TRUE, colClasses = "character")
names(tidyfeat) <- cols$V2

## extract the mean and the sd
featmeansd <- tidyfeat[, grep("mean|std", names(tidyfeat))]

## Getting train and test activities
trainact <- read.table(trainactfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
testact <- read.table(testactfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")

## Bind them
allact <- rbind(trainact, testact)

## get activity labels as a translation dictionary
activity_dic <- read.table(activitiesfile, header = FALSE, strip.white = TRUE, colClasses = "character")

## into a nice tidy data
tidyact<- tbl_df(as.data.frame(apply(allact, 1, function(x) x = activity_dic$V2[as.numeric(x)])))
names(tidyact) <- "activity"

## the same for subject
trainsubject <- read.table(trainsubjectfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")
testsubject <- read.table(testsubjectfile, header = FALSE, strip.white = TRUE, colClasses = "character", na.strings = "")

## Bind them
allsubject <- rbind(trainsubject, testsubject)
names(allsubject) <- "subject"
tidysubject <- tbl_df(allsubject)

## new dataset from activity and subject measures
tidysubjact <- cbind(tidyact, tbl_df(allsubject))



## a new dataset with activity and subject

tidynew <- tbl_df(tidysubjact)
featmean <- featmeansd[, grep("mean", names(featmeansd))]
tidynew <- tbl_df(cbind(tidynew, featmean))



