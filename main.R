
####Please set working directory to this code folder
setwd('D:/Dropbox/Wenjing Andrea/Single family returns') 

####toggle on/off the inclusion of metro samples
include_metro_sample=data.frame(
  year=c(2007,2009,2011,2013,2015,2017,2019),
  includeBit=0)


####I use the following to read AHS files, you can skip this and .RData will be used.
#source('./source/read AHS data from to 2013.R') 
#source('./source/read AHS data from 2015.R') 
#source('./source/read AHS data from to 2013 metro sample.R') 
#source('./source/read AHS data from 2015 metro sample.R') 


#####Get net yield for 30 cities from 1985 to 2013
source('./source/clean sample 30 cities.R')
#View(sample%>%group_by(Year)%>%summarize(n=n()))
source('./source/hedonic regression.R')  
source('./source/weighted rent-to-price ratio.R') 
source('./source/vacancy.R') 
source('./source/net yield.R') 


#####Get net yield for 15 metros from 1985 to 2019
source('./source/clean sample 15 metros.R')
#View(sample%>%group_by(Year)%>%summarize(n=n()))
source('./source/hedonic regression.R') 
source('./source/weighted rent-to-price ratio.R') 
source('./source/vacancy.R') 
source('./source/net yield.R') 
