

#clean sample data (Appendix A.1 Data selection)

require(tidyverse)

naSet=c(NA,-6,-9) # -6: not applicable, -9: not reported


data_ahs=bind_rows(readRDS(file='./input data/data_ahs_to2013.RData'),
                   readRDS(file='./input data/data_ahs_to2013_metro.RData')%>%
                     inner_join(include_metro_sample%>%filter(includeBit==1)%>%select(year),
                                by=c('Year'='year')))

#get data from the 30 cities with most coverage in AHS data
data_ahs=data_ahs%>%
  inner_join(read.csv('./input data/30cities.csv',header=T)%>%select(SMSA),by='SMSA')%>%
  mutate(ZINC=ifelse(ZINC%in%naSet,NA,ZINC),
         VALUE=ifelse(VALUE%in%naSet,NA,VALUE),
         FRENT=ifelse(FRENT%in%naSet,NA,FRENT),
         RENT=ifelse(RENT%in%naSet,NA,RENT),
         EBAR=ifelse(EBAR%in%naSet,NA,EBAR),
         PROJ=ifelse(PROJ%in%naSet,NA,PROJ),
         RCNTRL=ifelse(RCNTRL%in%naSet,NA,RCNTRL),
         TYPE=ifelse(TYPE%in%naSet,NA,TYPE),
         TENURE=ifelse(TENURE%in%naSet,NA,TENURE),
         NUNIT2=ifelse(NUNIT2%in%naSet,NA,NUNIT2))%>%
  rename('region'='SMSA')
#set invalid values to NA so that regression later will not use these meaningless numbers
#rename to region so the code later can be used for both SMSA (30 cities sample) and CBSA (15 metros sample)

sample=data_ahs%>%
  filter(is.na(ZINC)|is.na(VALUE)|VALUE==0|ZINC/VALUE<=2
         #household income to house value <=2
         ,is.na(ZINC)|is.na(FRENT)|is.na(RENT)|FRENT==0|RENT==0|ZINC/(FRENT*RENT)<=100
         #household income to annual rent <=100
         ,is.na(VALUE)|VALUE!=1
         ,is.na(RENT)|RENT!=1
         ,is.na(FRENT*RENT)|FRENT*RENT!=0
         ,is.na(EBAR)|EBAR!=1#no bars on the windows;
         ,is.na(PROJ)|PROJ!=1 #not in projects;
         ,is.na(RCNTRL)|RCNTRL!=1 #rent not stabilized;
         ,is.na(TENURE)|TENURE!=3 #owner or renter occupied;
         ,TYPE==1 #stand-alone home, attached home, condo, or apartment;
         ,NUNIT2%in%c(1,2)
         ,is.na(UNITSF)|UNITSF>0)%>%
  mutate(decade=ifelse(BUILT>=1970,as.integer(BUILT/5)*5,
                       ifelse(BUILT>=1900,as.integer(BUILT/10)*10,
                              ifelse(BUILT>10,as.integer((BUILT+1900)/5)*5,
                                     ifelse(BUILT<=3,1985-BUILT*5,2000-BUILT*10)))),
         log_rent=log(FRENT*RENT),
         bathrooms=BATHS+0.5*HALFB,
         central_air=ifelse(AIRSYS==1,1,0),
         log_sf=log(UNITSF),
         renter_data=ifelse(is.na(log_rent),0,1),
         age=Year-decade)

file_suffix='30cities'
#will save results to csv using this file_suffix

#View(sample%>%group_by(Year)%>%summarize(n=n()))

