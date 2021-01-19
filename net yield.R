########################################################################################

# calculates city-year level net yields
# see detailed description in Appendix A.1

########################################################################################

ins_rate=0.00375; #insurance on price
repairs = 0.006; #on price
mgmt = 0.059; #on rent
credit = 0.0073; #credit loss on rent
# Assume capex and renovations are valued at 100% and any that are not will go into the repairs;

rp_medians$month=6
vacancies$month=6

#hpa data
hpi=read.csv('HPI_master.csv',header=T,stringsAsFactors = F)%>%
  filter(level=='MSA',
         hpi_type=='traditional',
         hpi_flavor=='all-transactions',
         period==2)%>%
  select(place_id,place_name,yr,index_nsa)%>%
  filter(place_id%in%cities$cbsa)%>%
  mutate(yr_next=yr+1)# Q2 data

hpa=hpi%>%
  inner_join(hpi%>%select(place_id,yr,index_nsa),by=c('place_id',c('yr_next'='yr')))%>%
  mutate(hpa=index_nsa.y/index_nsa.x-1)

#tax data

