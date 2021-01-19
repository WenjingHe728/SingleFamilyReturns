########################################################################################

# calculate city-year level vacancy rate
# see detailed description in Appendix A.1 Vacancy data

########################################################################################

vac=data_ahs%>%
  filter(!(SMSA%in%c(-9,9999,0,NA))
         ,NUNIT2==1 # single family detached home: one-unit building, detached from any other building
         ,is.na(PROJ)|PROJ!=1 # not in project
         ,TYPE==1)# stand-alone home, attached home, condo, or apartment

vac=vac%>%
  mutate(vacant=ifelse(VACANCY%in%c(1,2,4),1,0),
         # 1: For rent only; 2: For rent or for sale; 4: Rented, but not yet occupied
         rented=ifelse(TENURE==2,1,0))%>% # Rented with a renter inside
  group_by(SMSA,Year)%>% # calculate city-year level vacancy rate for city-year with nObs>=50
  summarize(rented=sum(WEIGHT*rented),
            vacant=sum(WEIGHT*vacant),
            count=n())%>%
  mutate(vac_rate=ifelse(count>=50,vacant/(vacant+rented),NA))

# regress to impute for city-year with nObs<50
vac$SMSA2=as.factor(vac$SMSA)
vac$Year2=as.factor(vac$Year)
model=lm(vac_rate~SMSA2+Year2,data=vac,weight=count)

vac_predict=vac%>%
  filter(SMSA2%in%model$xlevels$SMSA2,
         Year2%in%model$xlevels$Year2)

vac_predict$predict_vac_rate=predict(model,vac_predict%>%select(SMSA2,Year2))

# vacancy time series summary
vac_predict_summary=vac_predict%>%
  group_by(Year)%>%
  summarize(predict_vac_rate=weighted.mean(predict_vac_rate,count))

write.csv(vac_predict_summary,'vac_ts.csv',row.names=F)

# vacancies for 30 cities
vacancies=vac%>%
  select(SMSA,Year,rented,vacant,count,vac_rate)%>%
  left_join(vac_predict%>%select(SMSA,Year,predict_vac_rate),by=c('SMSA','Year'))%>%
  inner_join(cities%>%select(msa),by=c('SMSA'='msa'))

write.csv(vacancies,'vac_data.csv',row.names=F)


