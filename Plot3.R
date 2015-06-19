library("tidyr")
library("dplyr")
library("lubridate")
library(data.table)
library(ggplot2)

# make sure file is downloaded and unzipped, if not get it
if (!file.exists("summarySCC_PM25.rds")) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileUrl, destfile="EPA.zip", mode="wb")
    unzip("EPA.zip")
}

# read in data files
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

NEI <-data.table(NEI)
setkey(NEI,fips)

# Using fips == "24510" (Baltimore City, Maryland)
by.year.type <- NEI["24510",.(Sum.Emissions = sum(Emissions)),by=.(year,type)]


png(file = "plot3.png", 
    bg = "transparent",
    width = 960, 
    height = 480)

# generate plot
g <- ggplot(by.year.type, aes(year, Sum.Emissions))
## Add layers
g + geom_line() +
    facet_wrap( ~ type , nrow = 1) +
    labs(x = "Year") +
    labs(y = expression("Total " * PM[2.5])) +
    labs(title = expression("Total " * PM[2.5] * " Emisions by Year/Type For Baltimore City, Maryland"))

dev.off()