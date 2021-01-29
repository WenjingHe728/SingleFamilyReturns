#calculate region-year level rent/price ratio, weighted by the price distribution of rental homes.(Appendix A.1 Aggregating rent-to-price ratios with nonparametric weights.)

########################################################################################

require(matrixStats)
require(zoo)

#deciles for predicted log rent
pr=sample%>%
  group_by(region,Year)%>%
  mutate(decile=ntile(predicted_log_rent,n=10)-1)

#rent to own ratio for each region-year-decile
rent_own_ratio=pr%>%
  filter(TENURE%in%c(1,2))%>% # 1: owned, 2: rented
  group_by(region,Year,TENURE,decile)%>%
  summarize(weight=sum(WEIGHT))%>%
  pivot_wider(names_from=TENURE,values_from=weight)%>%
  rename('own_weight'=`1`,'rent_weight'=`2`)%>%
  mutate(rent_own_ratio=ifelse(is.na(rent_weight/own_weight),0,rent_weight/own_weight))

pr=pr%>%
  left_join(rent_own_ratio,by=c('region','Year','decile'))%>%
  mutate(rp_owned=ifelse(renter_data==0,
                         exp(predicted_log_rent)*exp(0.2349619/2.0)/VALUE,NA),
         #Goldberger correction
         weight_nonparam=rent_own_ratio*WEIGHT)
#giving to rented unit too but fine because they will be dropped

#weighted median rent-to-price ratio for each region-year
rp_weighted_median=function(rp_owned_col, weight_nonparam_col)
{
  data=data.frame(rp_owned=rp_owned_col,
                  weight_nonparam=weight_nonparam_col)%>%
    filter(is.na(rp_owned)==F)%>% # drop rented units
    select(weight_nonparam,rp_owned)
  
  cutoff=sum(data$weight_nonparam)/2.0
  
  data=data%>%
    arrange(-rp_owned)%>%
    mutate(cum_sum=cumsum(weight_nonparam))
  
  data=data%>%
    filter(cum_sum>=cutoff)
  
  return(data$rp_owned[1])
}

#save region-year-decile rent_own_ratio
write.csv(rent_own_ratio%>%select(region,Year,decile,rent_own_ratio),
          file=paste0('rent_own_ratio_',file_suffix,'.csv'),row.names = F)

#save house level rp_owned and weight_nonparam
write.csv(pr%>%select(region,Year,weight_nonparam,rp_owned),
          file=paste0('rp_owned_',file_suffix,'.csv'),row.names = F)

#save region-year weighted median rent-to-price ratio to csv file
write.csv(pr%>%
            group_by(region,Year)%>%
            summarize(rp_median=rp_weighted_median(rp_owned,weight_nonparam)),
          file=paste0('rp_medians_',file_suffix,'.csv'),row.names = F)


