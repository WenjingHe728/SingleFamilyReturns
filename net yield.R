
#region-year level net yields (Appendix A.1)

require(zoo)

ins_rate=0.00375; #insurance on price
repairs = 0.006; #on price
capex = 0; #on price #capex = 0.0115
mgmt = 0.059; #on rent
credit = 0.0073; #credit loss on rent
#assume capex and renovations are valued at 100% and any that are not will go into the repairs;

#load calculated median weighted rent-to-price ratio
rp=read.csv(paste0('rp_medians_',file_suffix,'.csv'),header=T,stringsAsFactors = F)%>%
  mutate(rp=rp_median)%>%
  select(region,Year,rp)

#load calculated vacancy data
vac=read.csv(paste0('vac_data_',file_suffix,'.csv'),header=T,stringsAsFactors = F)%>%
  mutate(vac_rate=ifelse(is.na(vac_rate),predicted_vac_rate,vac_rate))%>%
  select(region,Year,vac_rate)

#load your own tax data
regions=read.csv(paste0(file_suffix,'.csv'),header=T,stringsAsFactors=F)
colnames(regions)[1]='region'
tax=regions%>%
  inner_join(read.csv('taxes.csv',header=T,stringsAsFactors = F),by='state')%>%
               select(Year,region,tax_rate)

#create panel
panel=expand_grid(Year=min(rp$Year):(max(rp$Year)+1),region=unique(rp$region))%>%
  inner_join(regions%>%select(region,name,state,cbsa),by='region')%>%
  left_join(rp,by=c('Year','region'))%>%
  left_join(tax,by=c('Year','region'))%>%
  left_join(vac,by=c('Year','region'))%>%
  arrange(region,Year)%>%
  group_by(region)%>%
  mutate(interp_rp=na.approx(rp,x=Year,rule=2), #interp for missing years
         interp_tax=na.approx(tax_rate,x=Year,rule=2),
         interp_vac=na.approx(vac_rate,x=Year,rule=2),
         net_yield=interp_rp*(1-interp_vac)*(1-mgmt-credit)-interp_tax/1000-ins_rate-repairs-capex
         ) 

#the tax file loaded only have data to 2012
#extrapolate tax rate beyond 2012 based on the growth from 2005 to 2012 and the tax_growth_multiplier
extrapolate_tax_after2012=function(panel,tax_growth_multiplier)
{
  taxCol=paste0('extrap_tax_',tax_growth_multiplier)
  panel[[taxCol]]=panel$interp_tax
  
  for(r in unique(panel$region))
  {
    tax_2005=(panel%>%filter(region==r,Year==2005))$tax_rate
    tax_2012=(panel%>%filter(region==r,Year==2012))$tax_rate
    growth_rate=((tax_2012/tax_2005)^(1/7)-1)*tax_growth_multiplier
    
    for(yr in 2013:2020)
    {
      panel[(panel$Year==yr&panel$region==r),taxCol]=tax_2012*(1+growth_rate)^(yr-2012)
    }
  }
  
  netYieldCol=paste0('net_yield_',tax_growth_multiplier)
  panel[[netYieldCol]]=
    panel$interp_rp*(1-panel$interp_vac)*(1-mgmt-credit)-panel[[taxCol]]/1000-ins_rate-repairs-capex
  # why divide tax by 1000
  return (panel)
}

panel=extrapolate_tax_after2012(panel,1) #if tax grows after 2012 with the same rate from 2005 to 2012
panel=extrapolate_tax_after2012(panel,0.5)#if tax grows after 2012 with half the rate from 2005 to 2012

#save final net yield result to csv
write.csv(panel,
          file=paste0('net_yield_',file_suffix,'.csv'),row.names = F)




