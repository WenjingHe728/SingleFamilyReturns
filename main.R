
#setwd(....) # please set the working directory to the code folder

#source('read AHS data.R') # this can be skipped if you do not want to download AHS data yourself. If skipped, the code will use data_ahs.RData in the code folder 

source('clean data.R') # clean sample data

source('hedonic regression.R') # use hedonic regression to predict rent for each owned house

source('weighted rent-to-price ratio.R') # calculate city-year level weighted average rent-to-price ratio

source('vacancy.R') # calculate city-year level vacancy rate

source('net yield.R') # calculate city-year level net yield
