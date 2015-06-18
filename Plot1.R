library("tidyr")
library("dplyr")
library("lubridate")
library(data.table)

# make sure file is downloaded and unzipped, if not get it
if (!file.exists("summarySCC_PM25.rds")) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileUrl, destfile="EPA.zip", mode="wb")
    unzip("EPA.zip")
}

# read in data files
NEI <- readRDS("summarySCC_PM25.rds")

NEI <-data.table(NEI)

# sum emissions by year using data.table
by.year <- NEI[,.(Sum.Emissions = sum(Emissions)),by=year]


png(file = "plot1.png", 
    bg = "transparent",
    width = 480, 
    height = 480)

# generate plot
plot(by.year$year,by.year$Sum.Emissions, 
     type="b",
     main=expression("Total " * PM[2.5] * " Emisions by Year"),
     xlab="Year",
     ylab=expression("Total " * PM[2.5]))

dev.off()