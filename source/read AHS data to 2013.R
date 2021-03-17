
########################################################################################

# This script reads AHS data and save data_ahs_to2013.RData.
# See detailed description in Appendix A.1 Data files.
# To run this script, you need to download AHS flat csv files. You may need to modify the code to accommodate any new AHS format.
# Or, you can skip this script and data_ahs_to2013.RData in the code folder will be used.

########################################################################################
require(tidyverse)

# change file location accordingly
filenames=c('D:/Data/AHS/CVS/tahs85n.csv',
            'D:/Data/AHS/CVS/tahs87n.csv',
            'D:/Data/AHS/CVS/tahs89n.csv',
            'D:/Data/AHS/CVS/tahs91n.csv',
            'D:/Data/AHS/CVS/tahs93n.csv',
            'D:/Data/AHS/CVS/tahs95n.csv',
            'D:/Data/AHS/CVS/tAHS1997N.csv',
            'D:/Data/AHS/CVS/tAHS1999N.csv',
            'D:/Data/AHS/CVS/tAHS2001N.csv',
            'D:/Data/AHS/CVS/tAHS2003N.csv',
            'D:/Data/AHS/CVS/tAHS2005N.csv',
            'D:/Data/AHS/CVS/tAHS2007N.csv',
            'D:/Data/AHS/CVS/tAHS2009N.csv',
            'D:/Data/AHS/CVS/ahs2011n.csv',
            'D:/Data/AHS/CVS/ahs2013n.csv')

columns=c('MOVED','HHMOVE', 'MOVE', 'MOVE1', 'CONTROL', 'VALUE', 'FRENT', 'RENT', 'BATHS', 'HALFB', 'BUILT', 'BEDRMS', 'UNITSF', 'SMSA', 'TYPE', 'TENURE', 'AIRSYS', 'CONDO', 'NUNIT2', 'LOT', 'ROOMS', 'EBAR', 'PROJ', 'RCNTRL', 'EFRIDGE', 'ZINC', 'VACANCY', 'WEIGHT','moved','hhmove', 'move', 'move1', 'control', 'value', 'frent', 'rent', 'baths', 'halfb', 'built', 'bedrms', 'unitsf', 'smsa', 'type', 'tenure', 'airsys', 'condo', 'nunit2', 'lot', 'rooms', 'ebar', 'proj', 'rcntrl', 'efridge', 'zinc', 'vacancy', 'weight')

data_ahs=read.csv(filenames[1],stringsAsFactors = F,header=T)%>%
  select(any_of(columns))%>%
  mutate(Year=1985)

for(i in 2:length(filenames))
{
  print(filenames[i])

  if(i!=15)
  {
    data=read.csv(filenames[i],stringsAsFactors = F,header=T)%>%
      select(any_of(columns))
    
    colnames(data)=toupper(colnames(data)) # some column names are lowercase for 2007 file. 
    
    data=data%>%
      mutate(Year=1985+(i-1)*2)
  }
  else 
    # the downloaded flat file for 2013 is not well formated so we have to manually get its header row
  {
    data=read.csv(filenames[i],stringsAsFactors = F,nrow=2,header=F)
    cols=c()
    for(u in 1:2)
    {
      for(v in 1:length(colnames(data)))
      {
        if(is.na(data[u,v])==F&data[u,v]!='')
          cols=c(cols,data[u,v])
      }
    }
    data=read.csv(filenames[i],stringsAsFactors = F,skip=2,header=F)
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

saveRDS(data_ahs,file='./input data/data_ahs_to2013.RData')

rm(list=ls())


            