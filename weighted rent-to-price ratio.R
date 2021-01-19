########################################################################################

# calculate average rent/price ratio in city-year level with smoothed weights based on the density of rental homes.
# see detailed description in Appendix A.1 Aggregating rent-to-price ratios with nonparametric weights.

########################################################################################

require(matrixStats)
require(zoo)

## calculate city-year-rank level weight

predicted_rent_rank=sample%>%
  group_by(SMSA,Year)%>%mutate(ranks=ntile(predicted_rent,n=100)-1)

rented_rank_binsize=predicted_rent_rank%>%
  filter(is.na(log_rent)==F)%>%
  group_by(SMSA,Year,ranks)%>%summarize(binsize=n())

weighting=predicted_rent_rank%>%
  group_by(SMSA,Year,ranks)%>%
  summarize(n=n())%>%
  select(-n)%>% # generate a city-year-rank level template based on predicted rent
  left_join(rented_rank_binsize,by=c('SMSA','Year','ranks'))%>% 
  mutate(binsize=ifelse(is.na(binsize),0,binsize))%>%
  arrange(SMSA,Year,ranks)%>%
  group_by(SMSA,Year)%>%
  mutate(binsize_ma=rollapply(binsize,width=15,FUN=mean,align='center',partial=TRUE))%>%
  # fill in smoothed density of rented houses
  group_by(SMSA,Year)%>%
  mutate(normalize=sum(binsize_ma),
         weighting=binsize_ma*100/normalize)%>% # calculate density of rented houses over predicted rent deciles
  select(SMSA,Year,ranks,weighting)

summary_weight=weighting%>%group_by(ranks)%>%summarize(weighting=mean(weighting))%>%arrange(ranks)

write.csv(summary_weight,file='average_weighting.csv',row.names=F)

## Merge back in on value (recall, we have R/P ratio for the owned homes)
rp_medians=sample%>%
  mutate(rp_ratio=predicted_rent/VALUE)%>%
  group_by(SMSA,Year)%>%
  mutate(ranks=ntile(VALUE,n=100)-1)%>%
  inner_join(weighting,by=c('SMSA','Year','ranks'))%>%
  group_by(SMSA,Year)%>%
  summarize(rp_meidan=weightedMedian(rp_ratio,weighting,na.rm=T),count=n())%>%
  arrange(SMSA,Year)

write.csv(rp_medians,file='rp_medians.csv',row.names = F)



