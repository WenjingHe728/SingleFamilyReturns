require(tidyverse)

#30 cities with the best AHS data coverage
cities=read.csv('cityList.csv',header=T)

## debug
test=read.csv(paste0(getwd(),'/data/tahs85n.csv'),stringsAsFactors = F,header=T)

test_clean=test%>%
  filter(is.na(SMSA)==F)%>%#with valid msa identifier 
  inner_join(cities,by=c('SMSA'='msa'))%>%
  filter(ZINC/VALUE<=2#household income to house value <= 2
         ,ZINC/(FRENT*RENT)<=100#household income to annual rent <=100
         #,VALUE!=1
         #,RENT!=1
         ,EBAR!=1 #no bars on the windows;
         ,PROJ!=1 #not in projects;
         ,RCNTRL!=1 #rent not stabilized;
         ,TYPE==1 #stand-alone home, attached home, condo, or apartment;
         ,is.na(TENURE)==F&TENURE!=3 # owner or renter occupied;
         ,is.na(NUNIT2)==F&(NUNIT2==1|NUNIT2==2) # 1 is detached, 2 is attached, 3 is building with two or more apts;
         #,BUILT>0
  )


require('haven')
data=read_sas(paste0(getwd(),'/data/ahs85n.sas7bdat'))
data=data%>%select(SMSA,ZINC,VALUE,FRENT,RENT,EBAR,PROJ,RCNTRL,TYPE,TENURE,NUNIT2,BUILT)
test_clean=data%>%
  filter(is.na(SMSA)==F)%>%#with valid msa identifier 
  inner_join(cities,by=c('SMSA'='msa'))%>%
  filter(is.na(ZINC)==F&is.na(VALUE)==F&(ZINC/VALUE<=2)#household income to house value <= 2
         ,is.na(FRENT)|is.na(RENT)|ZINC/(FRENT*RENT)<=100#household income to annual rent <=100
         ,VALUE!=1
         ,is.na(RENT)|RENT!=1
         ,EBAR!=1 #no bars on the windows;
         ,is.na(PROJ)|PROJ!=1 #not in projects;
         ,is.na(RCNTRL)|RCNTRL!=1 #rent not stabilized;
         ,TYPE==1 #stand-alone home, attached home, condo, or apartment;
         ,is.na(TENURE)==F&TENURE!=3 # owner or renter occupied;
         ,is.na(NUNIT2)==F&(NUNIT2==1|NUNIT2==2) # 1 is detached, 2 is attached, 3 is building with two or more apts;
         ,BUILT>0
  )


test=sample%>%group_by(Year)%>%summarize(n=n())

r=sample%>%filter(Year==2007)
path='C:/Users/hewen/AppData/Local/Temp/SAS Temporary Files/_TD3360_DESKTOP-MI2U7FM_/Prc2/'
sas=read_sas(paste0(path,'ds.sas7bdat'))
sas$CONTROL=paste0("'",sas$CONTROL,"'")
sas$missing=1
missing=r%>%left_join(sas%>%select(CONTROL,missing),by='CONTROL')%>%filter(is.na(missing))
View(missing%>%select(CONTROL,EBAR))
View(missing%>%select(CONTROL,VALUE,ZINC))
View(data_ahs%>%filter(CONTROL=="'381493370241'",Year==1985)%>%select(CONTROL,EBAR))

