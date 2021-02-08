
########################################################################################

# This script reads AHS data (metro sample) from 2015 to 2019 and save data_ahs_from2015_metro.RData.
# See detailed description in Appendix A.1 Data files.
# AHS changed formatting and sampling from 2015. 
# To run this script, you need to download AHS flat csv files. You may need to modify the code to accommodate any new AHS format.
# Or, you can skip this script and data_ahs_from2015.RData in the code folder will be used.

########################################################################################

require(tidyverse)

# change file location accordingly
filenames=c('D:/Data/AHS/CVS/metro/ahs2015m.csv',
            'D:/Data/AHS/CVS/metro/ahs2017m.csv',
            'D:/Data/AHS/CVS/metro/ahs2019m.csv')


columns=c('CONTROL','MARKETVAL', 'RENT', 'BATHROOMS', 'YRBUILT', 'BEDROOMS', 'UNITSIZE', 'BLD', 'TENURE', 'ACPRIMARY', 'CONDO', 'LOTSIZE', 'TOTROOMS', 'WINBARS', 'RENTCNTRL', 'FINCP', 'VACANCY', 'WEIGHT', 'HHMOVE', 'OMB13CBSA')


data_ahs=read.csv(filenames[1],stringsAsFactors = F,header=T)%>%
  select(any_of(columns))%>%
  mutate(Year=2015)

for(i in 2:length(filenames))
{
  print(filenames[i])

  data=read.csv(filenames[i],stringsAsFactors = F,header=T)%>%
    select(any_of(columns))%>%
    mutate(Year=2015+(i-1)*2)
  
  cols=c('BATHROOMS','UNITSIZE','BLD','TENURE','ACPRIMARY','CONDO',
         'LOTSIZE','WINBARS','RENTCNTRL','VACANCY','OMB13CBSA')
  for(c in cols)
  {
    if(c%in%colnames(data))
    {
      if(i==2)
      {data_ahs[[c]]=as.numeric(gsub("'",'',as.character(data_ahs[[c]])))}
      
      data[[c]]=as.numeric(gsub("'",'',as.character(data[[c]])))
    }
  }
  data_ahs=bind_rows(data_ahs,data)
}

#https://www.census.gov/data-tools/demo/codebook/ahs/ahsdict.html
data_ahs=data_ahs%>%
  mutate(VALUE=MARKETVAL,
         FRENT=12,# the new format has RENT as monthly rent and no FRENT field
         BATHS=ifelse(BATHROOMS>=7,0,1+0.5*(BATHROOMS-1)),
         HALFB=0, # the new format has no HALFB field
         BUILT=YRBUILT,
         BEDRMS=BEDROOMS,
         UNITSF=ifelse(UNITSIZE==1,250,
                         ifelse(UNITSIZE==2,(500+749)/2,
                                ifelse(UNITSIZE==3,(750+999)/2,
                                       ifelse(UNITSIZE==4,(1000+1499)/2,
                                              ifelse(UNITSIZE==5,(1500+1999)/2,
                                                     ifelse(UNITSIZE==6,(2000+2499)/2,
                                                            ifelse(UNITSIZE==7,(2500+2999)/2,
                                                                   ifelse(UNITSIZE==8,(3000+3999)/2,
                                                                          ifelse(UNITSIZE==9,4000,NA))))))))),
         TYPE=ifelse(BLD%in%c(2,3),1,0), #map to TYPE
         NUNIT2=ifelse(BLD==2,1,ifelse(BLD==3,2,NA)), #map to NUNIT2
         AIRSYS=ifelse(is.na(ACPRIMARY)==F&ACPRIMARY<12,1,0),
         ROOMS=TOTROOMS,
         EBAR=WINBARS,
         RCNTRL=RENTCNTRL,
         ZINC=FINCP,
         MOVED=NA,
         SMSA=NA,
         LOT=NA,
         PROJ=NA,
         MOVE1=NA,
         EFRIDGE=NA
         )%>%
  select(MOVED,CONTROL,VALUE,FRENT,RENT,BATHS,HALFB,BUILT,BEDRMS,UNITSF,TYPE,TENURE,AIRSYS,CONDO,NUNIT2,
         LOT,ROOMS,EBAR,PROJ,RCNTRL,ZINC,VACANCY,WEIGHT,Year,MOVE1,HHMOVE,EFRIDGE,OMB13CBSA)

# save data for quicker loading later.
saveRDS(data_ahs,file='data_ahs_from2015_metro.RData')

rm(list=ls())


            