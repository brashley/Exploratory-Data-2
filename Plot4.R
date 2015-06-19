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

states <- fread("FIPS_State.csv")

# read in data files
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

SCC <- data.table(SCC)
NEI <- data.table(NEI)

# retreive all the coal cumbitions related codes using the EI.Sector catagory
coal.SCC <- SCC %>% filter(grepl("Fuel Comb",EI.Sector)) %>%
                filter(grepl("Coal",EI.Sector)) 

# extract first two digets of fips code = state)
NEI <- NEI[,FIPS.Code := as.integer(substr(fips, 1, 2))]

setkey(NEI,FIPS.Code)

# look up state from states table using new FIPS.Code state digit
NEI <- inner_join(NEI, coal.SCC, by="SCC") %>%
       inner_join(states,by="FIPS.Code") %>%
       filter(FIPS.Code<=56)

by.year <- NEI[,.(Sum.Emissions = sum(Emissions)),by=.(year,State.Name)]

png(file = "plot3.png", 
    bg = "transparent",
    width = 960, 
    height = 960)

# generate plot
g <- ggplot(by.year, aes(year, Sum.Emissions))
## Add layers
g + geom_line() +
    facet_wrap( ~ State.Name) +
    labs(x = "Year") +
    labs(y = expression("Total " * PM[2.5])) +
    labs(title = expression("Total " * PM[2.5] * " Emisions by Year and State for Coal Related Combustion"))

dev.off()