############################################# data cleaning ##############################################
data_ahs=readRDS(file='data_ahs.RData')
#View(data_ahs%>%group_by(Year)%>%summarize(n=n()))

#30 cities with the best AHS data coverage
cities=read.csv('cityList.csv',header=T)

data=data_ahs%>%
  filter(is.na(SMSA)==F&SMSA!=-9)%>%#with valid msa identifier 
  inner_join(cities,by=c('SMSA'='msa'))%>%
  filter(ZINC/VALUE<=2#household income to house value <= 2
         ,ZINC/(FRENT*RENT)<=100#household income to annual rent <=100
         ,VALUE!=1
         ,RENT!=1
         ,EBAR!=1 #no bars on the windows;
         ,PROJ!=1 #not in projects;
         ,RCNTRL!=1 #rent not stabilized;
         ,TYPE==1 #stand-alone home, attached home, condo, or apartment;
         ,is.na(TENURE)==F&TENURE!=3 # owner or renter occupied;
         ,is.na(NUNIT2)==F&(NUNIT2==1|NUNIT2==2) # 1 is detached, 2 is attached, 3 is building with two or more apts;
         ,BUILT>0
         )%>%
  mutate(decade=ifelse(BUILT>=1970,as.integer(BUILT/5)*5,ifelse(BUILT>=1900,as.integer(BUILT/10)*10,ifelse(BUILT>10,as.integer((BUILT+1900)/5)*5,ifelse(BUILT<=3,1985-BUILT*5,2000-BUILT*10)))))
    
View(data%>%group_by(Year)%>%summarize(n=n()))



  
 