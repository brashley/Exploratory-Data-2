library("tidyr")
library("dplyr")
library("lubridate")
library(data.table)
library(ggplot2)

###
# I decided that "Across the United States" meant that looking how PM2.5 was changing 
# in different location in the US.  To do this I convertid the 'fips' codes into 'States' 
# and then graphed the change for each state.  Also, I used the sum of the PM2.5 as is 
# because I wanted to see absolute magnitude of the level and the change to focus on the 
# biggest sifts. (for example Indiana) After looking at a lot of SCC codes and reading 
# some of the EPA documentation I decided to use the EI.Sector codes and searched for 
# 'Coal' and "Fuel Comb'.  I included the 'Total' SCC codes in my sums. At some point
# this is about the graph and not the data minipulation.

# make sure file is downloaded and unzipped, if not get it
if (!file.exists("summarySCC_PM25.rds")) {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
    download.file(fileUrl, destfile="EPA.zip", mode="wb")
    unzip("EPA.zip")
}

# state fips prefix from epa.gove at http://www.epa.gov/enviro/html/codes/state.html
states <- fread("FIPS_State.csv")

# read in data files
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

SCC <- data.table(SCC)
NEI <- data.table(NEI)

# retreive all the coal cumbitions related codes using the EI.Sector catagory
coal.SCC <- SCC %>% 
            filter(grepl("Fuel Comb",EI.Sector)) %>%
            filter(grepl("Coal",EI.Sector)) 

# extract first two digets of fips code = state)
NEI <- NEI[,FIPS.Code := as.integer(substr(fips, 1, 2))]

setkey(NEI,FIPS.Code)

# look up state from states table using new FIPS.Code state digit
NEI <- inner_join(NEI, coal.SCC, by="SCC") %>%
       inner_join(states,by="FIPS.Code") %>%
       filter(FIPS.Code<=56)

# Sum by 'year' and 'state.name'
by.year <- NEI[,.(Sum.Emissions = sum(Emissions)),by=.(year,State.Name)]

png(file = "plot4.png", 
    bg = "transparent",
    width = 1440, 
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