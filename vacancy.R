#region-year level vacancy rate (Appendix A.1 Vacancy data)

vac=data_ahs%>%
  filter(!(region%in%c(-9,9999,0,NA))
         ,NUNIT2==1 #single family detached home: one-unit building, detached from any other building
         ,is.na(PROJ)|PROJ!=1 #not in project
         ,TYPE==1)%>% #stand-alone home, attached home, condo, or apartment
  mutate(vacant=ifelse(VACANCY%in%c(1,2,4),1,0), 
         # 1: For rent only; 2: For rent or for sale; 4: Rented, but not yet occupied
         rented=ifelse(is.na(TENURE)==F&TENURE==2,1,0)) #2: Rented
  
#calculate region-year level vacancy rate for region-year with nObs>=50
vac=vac%>%
  group_by(region,Year)%>% 
  summarize(rented=sum(WEIGHT*rented),
            vacant=sum(WEIGHT*vacant),
            count=n())%>%
  mutate(vac_rate=ifelse(count>=50,vacant/(vacant+rented),NA))


#regress to impute for region-year with nObs<50
model=lm(vac_rate~factor(region)+factor(Year),data=vac,weight=count)
vac$predict_vac_rate=predict(model,vac)

#save vacancy time series data
write.csv(vac%>%
            group_by(Year)%>%
            summarize(predict_vac_rate=weighted.mean(predict_vac_rate,count)),
          paste0('vac_ts_',file_suffix,'.csv'),row.names=F)

#save vacancy panel data
write.csv(vac,paste0('vac_data_',file_suffix,'.csv'),row.names=F)


