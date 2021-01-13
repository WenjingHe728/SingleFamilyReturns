require(tidyverse)

#30 cities with the best AHS data coverage
cities=read.csv('cityList.csv',header=T)

## debug
test=read.csv(paste0(getwd(),'/data/tahs85n.csv'),stringsAsFactors = F,header=T)

test_clean=test%>%
  filter(is.na(SMSA)==F&SMSA!=-9)%>%#with valid msa identifier 
  #inner_join(cities,by=c('SMSA'='msa'))%>%
  filter(ZINC/VALUE<=2#household income to house value <= 2
         ,ZINC/(FRENT*RENT)<=100#household income to annual rent <=100
         ,VALUE!=1
         ,RENT!=1
         ,EBAR!=1 #no bars on the windows;
         ,PROJ!=1 #not in projects;
         ,RCNTRL!=1 #rent not stabilized;
         ,TYPE==1 #stand-alone home, attached home, condo, or apartment;
         ,is.na(TENURE)==F&TENURE!=3&TENURE!=-9 # owner or renter occupied;
         ,#is.na(NUNIT2)==F&(NUNIT2==1|NUNIT2==2) # 1 is detached, 2 is attached, 3 is building with two or more apts;
         #,BUILT>0
  )
