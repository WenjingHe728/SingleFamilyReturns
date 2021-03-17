
########################################################################################

# This script reads AHS data (metro sample) from 1985 to 2013 and save data_ahs_to2013_metro.RData.
# See detailed description in Appendix A.1 Data files.
# To run this script, you need to download AHS flat csv files. You may need to modify the code to accommodate any new AHS format.
# Or, you can skip this script and data_ahs_metro.RData in the code folder will be used.

########################################################################################
require(tidyverse)

# change file location accordingly
files=data.frame(year=c(1985,1987,1989,1991,1993,1995,2007,2009,2011,2013),
                 filename=c('D:/Data/AHS/CVS/metro/ahs85msa.csv',
            'D:/Data/AHS/CVS/metro/ahs87msa.csv',
            'D:/Data/AHS/CVS/metro/ahs89msa.csv',
            'D:/Data/AHS/CVS/metro/ahs91msa.csv',
            'D:/Data/AHS/CVS/metro/ahs93msa.csv',
            'D:/Data/AHS/CVS/metro/ahs95msa.csv',
            'D:/Data/AHS/CVS/metro/tAHS2007m.csv',
            'D:/Data/AHS/CVS/metro/tAHS2009M.csv',
            'D:/Data/AHS/CVS/metro/ahs2011m.csv',
            'D:/Data/AHS/CVS/metro/ahs2013m.csv'))

columns=c('MOVED','HHMOVE', 'MOVE', 'MOVE1', 'CONTROL', 'VALUE', 'FRENT', 'RENT', 'BATHS', 'HALFB', 'BUILT', 'BEDRMS', 'UNITSF', 'SMSA', 'TYPE', 'TENURE', 'AIRSYS', 'CONDO', 'NUNIT2', 'LOT', 'ROOMS', 'EBAR', 'PROJ', 'RCNTRL', 'EFRIDGE', 'ZINC', 'VACANCY', 'WEIGHT','moved','hhmove', 'move', 'move1', 'control', 'value', 'frent', 'rent', 'baths', 'halfb', 'built', 'bedrms', 'unitsf', 'smsa', 'type', 'tenure', 'airsys', 'condo', 'nunit2', 'lot', 'rooms', 'ebar', 'proj', 'rcntrl', 'efridge', 'zinc', 'vacancy', 'weight')

data_ahs=read.csv(paste0(files$filename[1]),stringsAsFactors = F,header=T)%>%
  select(any_of(columns))%>%
  mutate(Year=files$year[1])

for(i in 2:nrow(files))
{
  print(paste0(files$filename[i]))

  data=read.csv(paste0(files$filename[i]),stringsAsFactors = F,header=T)%>%
      select(any_of(columns))
    
  colnames(data)=toupper(colnames(data)) # some column names are lowercase for 2007 file. 
  
  data=data%>%
    mutate(Year=files$year[i])
  
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

saveRDS(data_ahs,file='./input data/data_ahs_to2013_metro.RData')

rm(list=ls())


