
#set working directory to the code folder
#setwd(....) 

#read AHS raw files, can be skipped, then data_ahs_to2013.RData and data_ahs_from2015.RData will be used
#source('read AHS data from 1985 to 2013.R') 
#source('read AHS data from 2015.R') 

#get net yield for 30 cities from 1985 to 2013
source('clean sample 30 cities.R')
source('hedonic regression.R') 
source('weighted rent-to-price ratio.R') 
source('vacancy.R') 
source('net yield.R') 

#get net yield for 15 metros from 1985 to 2019
source('clean sample 15 metros.R')
source('hedonic regression.R') 
source('weighted rent-to-price ratio.R') 
source('vacancy.R') 
source('net yield.R') 
