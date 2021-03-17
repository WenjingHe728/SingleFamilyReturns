
#clean sample data (Appendix A.1 Data selection)

require(tidyverse)
require(readxl)

data_ahs_from2015=bind_rows(readRDS(file='./input data/data_ahs_from2015.RData'),
                   readRDS(file='./input data/data_ahs_from2015_metro.RData')%>%
                     inner_join(include_metro_sample%>%filter(includeBit==1)%>%select(year),
                                by=c('Year'='year')))

# AHS changed sampling in 2015. Before, it has data for each city. After, it has data for 15 biggest metro.
# find msa for the 15 metro areas sampled after 2015, then merge with data before 2015 based on msa

#https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html
cbsa_fips=read_excel('./input data/cbsa fips mapping.xls',sheet = 'List 1',skip = 2)%>%
  mutate(fips=as.numeric(paste0(`FIPS State Code`,`FIPS County Code`)),
         OMB13CBSA=as.numeric(`CBSA Code`))%>%
  select(OMB13CBSA,fips)%>%
  distinct()

#https://www.nber.org/research/data/ssa-federal-information-processing-series-fips-core-based-statistical-area-cbsa-and-metropolitan-and
fips_msa=read.csv('./input data/fips msa mapping.csv',header=T,stringsAsFactors = F)%>%
  select(fipscounty,msa)%>%
  distinct()

#msa for 15 metros sampled after 2015
keep_cbsa_msa=data_ahs_from2015%>%
  select(OMB13CBSA)%>%
  distinct()%>%
  left_join(cbsa_fips, by='OMB13CBSA')%>%
  left_join(fips_msa,by=c('fips'='fipscounty'))%>%
  filter(is.na(msa)==F)%>%
  select(OMB13CBSA,msa)%>%
  distinct()

#View(keep_cbsa_msa%>%select(OMB13CBSA)%>%distinct()) # find msa for 15 metro areas

#only keep data for these msa
data_ahs_from2015=data_ahs_from2015%>%
  inner_join(keep_cbsa_msa,by='OMB13CBSA')%>%
  select(-msa)

data_ahs_to2013=bind_rows(readRDS(file='./input data/data_ahs_to2013.RData'),
                            readRDS(file='./input data/data_ahs_to2013_metro.RData')%>%
                              inner_join(include_metro_sample%>%filter(includeBit==1)%>%select(year),
                                         by=c('Year'='year')))

data_ahs_to2013=data_ahs_to2013%>%
  inner_join(keep_cbsa_msa,by=c('SMSA'='msa'))%>%
  select(-SMSA)

naSet=c(NA,-6,-9) # -6: not applicable, -9: not reported

#merge data before and after 2015
data_ahs=bind_rows(data_ahs_to2013,data_ahs_from2015)%>%
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
  rename('region'='OMB13CBSA')
#set to NA so that regression later will not use these meaningless numbers
#rename to region so the code later can be used for both SMSA (30 cities sample) and CBSA (15 metros sample)

#View(unique(data_ahs$OMB13CBSA))

sample=data_ahs%>%
  filter(is.na(ZINC)|is.na(VALUE)|VALUE==0|ZINC/VALUE<=2#household income to house value <=2
         ,is.na(ZINC)|is.na(FRENT)|is.na(RENT)|FRENT==0|RENT==0|ZINC/(FRENT*RENT)<=100
         #household income to annual rent <=100
         ,is.na(VALUE)|VALUE!=1
         ,is.na(RENT)|RENT!=1
         ,is.na(FRENT*RENT)|FRENT*RENT!=0
         ,is.na(EBAR)|EBAR!=1#no bars on the windows;
         ,is.na(PROJ)|PROJ!=1 #not in projects;
         ,is.na(RCNTRL)|RCNTRL!=1 #rent not stabilized;
         ,is.na(TENURE)|TENURE!=3 # owner or renter occupied;
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

file_suffix='15metros'
#will save results to csv using this file_suffix

#View(sample%>%group_by(Year)%>%summarize(n=n()))

