library("tidyr")
library("dplyr")
library("lubridate")
library(data.table)
library(ggplot2)

###
#  Looking at the SCC names and description as well as definitions of 'Motor Vehicle'
# I decided to use the EI.Sector codes that contained 'Mobile' and 'Vehicle' as my
# SCC filter.  I also did not remove the 'Total' SCC codes and decided to just sum
# I did not feal adding a trend line was needed.


# make sure file is downloaded and unzipped, if not get it
if (!file.exists("summarySCC_PM25.rds")) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileUrl, destfile="EPA.zip", mode="wb")
    unzip("EPA.zip")
}

# read in data files
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# retreive all the motor vehicle related codes using the EI.Sector catagory
motor.vehicle.SCC <- SCC %>% 
    filter(grepl("Mobile",EI.Sector)) %>%
    filter(grepl("Vehicles",EI.Sector)) 

motor.vehicle.SCC <- data.table(motor.vehicle.SCC)
NEI <-data.table(NEI)
setkey(NEI,fips)

# subset NEI dataset by joining with motor vehicle SCC list
NEI <- inner_join(NEI, motor.vehicle.SCC, by="SCC")

# Using fips == "24510" (Baltimore City, Maryland)
by.year <- NEI["24510",.(Sum.Emissions = sum(Emissions)),by=.(year)]


png(file = "plot5.png", 
    bg = "transparent",
    width = 480, 
    height = 480)

# generate plot
g <- ggplot(by.year, aes(year, Sum.Emissions))
## Add layers
g + geom_line() +
    labs(x = "Year") +
    labs(y = expression("Total " * PM[2.5])) +
    labs(title = expression("Motor Vehicle " * PM[2.5] * " Emisions by Yeare For Baltimore City, Maryland"))

dev.off()