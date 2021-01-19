

########################################################################################

# This script reads data_ahs.RData and cleans sample
# See detailed description in Appendix A.1 Data selection

########################################################################################

require(tidyverse)

data_ahs=readRDS(file='data_ahs.RData')
data_ahs=data_ahs%>%filter(Year<=2013) # 977561
#test=data_ahs%>%group_by(Year)%>%summarize(n=n())
#data_ahs=data_ahs%>%filter(Year==2007)


cities=read.csv('cityList.csv',header=T)#30 cities with the best AHS data coverage

naSet=c(NA,-6,-9) # -6: not applicable, -9: not reported

sample=data_ahs%>%
  inner_join(read.csv('cityList.csv',header=T),by=c('SMSA'='msa'))%>% 
  mutate(ZINC=ifelse(ZINC%in%naSet,NA,ZINC),
         VALUE=ifelse(VALUE%in%naSet,NA,VALUE),
         FRENT=ifelse(FRENT%in%naSet,NA,FRENT),
         RENT=ifelse(RENT%in%naSet,NA,RENT),
         EBAR=ifelse(EBAR%in%naSet,NA,EBAR),
         PROJ=ifelse(PROJ%in%naSet,NA,PROJ),
         RCNTRL=ifelse(RCNTRL%in%naSet,NA,RCNTRL),
         TYPE=ifelse(TYPE%in%naSet,NA,TYPE),
         TENURE=ifelse(TENURE%in%naSet,NA,TENURE),
         NUNIT2=ifelse(NUNIT2%in%naSet,NA,NUNIT2),
         # set to NA so that regression later will not use these meaningless numbers
         decade=ifelse(BUILT>=1970,as.integer(BUILT/5)*5,
                       ifelse(BUILT>=1900,as.integer(BUILT/10)*10,
                              ifelse(BUILT>10,as.integer((BUILT+1900)/5)*5,
                                     ifelse(BUILT<=3,1985-BUILT*5,2000-BUILT*10)))),
         log_rent=log(FRENT*RENT),
         bathrooms=BATHS+0.5*HALFB,
         central_air=ifelse(AIRSYS==1,1,0)
         )%>%
  filter(is.na(ZINC)|is.na(VALUE)|VALUE==0|ZINC/VALUE<=2
         #household income to house value <=2
         #start to have data discrepancy between sas and csv for 2007, sas showing ZINC/VALUE>2 while csv showing ZINC as NA
         
         ,is.na(ZINC)|is.na(FRENT)|is.na(RENT)|FRENT==0|RENT==0|ZINC/(FRENT*RENT)<=100
         #household income to annual rent <=100
         
         ,is.na(VALUE)|VALUE!=1
         ,is.na(RENT)|RENT!=1
         
         ,is.na(EBAR)|EBAR!=1
         #no bars on the windows;
         #start to have data discrepancy between sas and csv for many years, sas showing EBAR='' while csv showing EBAR=1
         
         ,is.na(PROJ)|PROJ!=1 #not in projects;
         ,is.na(RCNTRL)|RCNTRL!=1 #rent not stabilized;
         ,is.na(TENURE)|TENURE!=3 # owner or renter occupied;
         ,TYPE==1 #stand-alone home, attached home, condo, or apartment;
         ,NUNIT2%in%c(1,2))

# todo: discrepancy between sas and csv data; sas code bug for loading file order; match with paper numbers

#View(sample%>%group_by(Year)%>%summarize(n=n()))


