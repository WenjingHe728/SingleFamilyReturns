
########################################################################################

# this script reads AHS data into data_ahs

########################################################################################


# download AHS flat csv files from https://www.census.gov/programs-surveys/ahs/data.html
# code description is at https://www.census.gov/data-tools/demo/codebook/ahs/ahsdict.html

filenames=c('tahs85n.csv',
            'tahs87n.csv',
            'tahs89n.csv',
            'tahs91n.csv',
            'tahs93n.csv',
            'tahs95n.csv',
            'tAHS1997N.csv',
            'tAHS1999N.csv',
            'tAHS2001N.csv',
            'tAHS2003N.csv',
            'tAHS2005N.csv',
            'tAHS2007N.csv',
            'tAHS2009N.csv',
            'ahs2011n.csv',
            'ahs2013n.csv',
            'ahs2015n.csv',
            'ahs2017n.csv',
            'ahs2019n.csv')

require(tidyverse)

columns=c('MOVED','HHMOVE', 'MOVE', 'MOVE1', 'CONTROL', 'VALUE', 'FRENT', 'RENT', 'BATHS', 'HALFB', 'BUILT', 'BEDRMS', 'UNITSF', 'SMSA', 'TYPE', 'TENURE', 'AIRSYS', 'CONDO', 'NUNIT2', 'LOT', 'ROOMS', 'EBAR', 'PROJ', 'RCNTRL', 'EFRIDGE', 'ZINC', 'VACANCY', 'WEIGHT')

data_ahs=read.csv(paste0(getwd(),'/data/',filenames[1]),stringsAsFactors = F,header=T)%>%
  select(any_of(columns))%>%
  mutate(Year=1985)

for(i in 2:length(filenames))
{
  print(i)

  if(i!=15)
  {
    data=read.csv(paste0(getwd(),'/data/',filenames[i]),stringsAsFactors = F,header=T)%>%
      select(any_of(columns))%>%
      mutate(Year=1985+(i-1)*2)
  }
  else # the downloaded flat file for 2013 is not well formated so we have to manually get its header row
  {
    data=read.csv(paste0(getwd(),'/data/',filenames[i]),stringsAsFactors = F,nrow=2,header=F)
    cols=c()
    for(u in 1:2)
    {
      for(v in 1:length(colnames(data)))
      {
        if(is.na(data[u,v])==F&data[u,v]!='')
          cols=c(cols,data[u,v])
      }
    }
    
    data=read.csv(paste0(getwd(),'/data/',filenames[i]),stringsAsFactors = F,skip=2,header=F)
    colnames(data)=cols
    
    data=data%>%
      select(any_of(columns))%>%
      mutate(Year=1985+(i-1)*2)
  }

  cols=c('TENURE','AIRSYS','CONDO','NUNIT2','EBAR','PROJ','RCNTRL','SMSA','VACANCY','MOVE1')
  for(c in cols)
  {
    if(c%in%colnames(data))
    {
      data[[c]]=as.numeric(gsub("'",'',as.character(data[[c]])))
    }
  }
  # start from 1997, some variables change from integer to character
  # start from 2011, SMSA changes from integer to character, e.g. from 80 to '0080', 160 to '0160'
  data_ahs=bind_rows(data_ahs,data)
}

data_ahs=data_ahs%>%
  mutate(arrive=ifelse(is.na(MOVED)==F,MOVED,
                       ifelse(is.na(HHMOVE)==F,HHMOVE,
                              ifelse(is.na(MOVE1)==F,MOVE1,NA))))

# only 1 record per house
# test=data_ahs%>%group_by(CONTROL,SMSA,Year)%>%summarize(n=n())

# save data for quicker loading later.
saveRDS(data_ahs,file='data_ahs.RData')

rm(list=ls())
            