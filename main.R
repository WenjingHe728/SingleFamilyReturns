
#set working directory to the code folder
#setwd(....) 

#read AHS raw files, can be skipped, then .RData will be used
#source('read AHS data from to 2013.R') 
#source('read AHS data from 2015.R') 
#source('read AHS data from to 2013 metro sample.R') 
#source('read AHS data from 2015 metro sample.R') 

#can change the includeBit below to toggle on/off metro sample inclusion
include_metro_sample=data.frame(year=c(1985,1987,1989,1991,1993,1995,2007,2009,2011,2013,2015,2017,2019),
                                includeBit=0)

#get net yield for 30 cities from 1985 to 2013
include_metro_sample$includeBit=0
#include_metro_sample[include_metro_sample$year%in%c(2007,2011),'includeBit']=1
source('clean sample 30 cities.R')
#View(sample%>%group_by(Year)%>%summarize(n=n()))
source('hedonic regression.R') 
source('weighted rent-to-price ratio.R') 
source('vacancy.R') 
source('net yield.R') 


#get net yield for 15 metros from 1985 to 2019
#include_metro_sample$includeBit=1
source('clean sample 15 metros.R')
#View(sample%>%group_by(Year)%>%summarize(n=n()))
source('hedonic regression.R') 
source('weighted rent-to-price ratio.R') 
source('vacancy.R') 
source('net yield.R') 
