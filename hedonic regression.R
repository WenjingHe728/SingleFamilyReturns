
#predict rent for each owned house (Appendix A.1 Imputing rents with a hedonic model)

model=lm(log_rent~factor(region)+factor(Year)+factor(CONDO)+factor(NUNIT2)
         +age+log_sf+ROOMS+BEDRMS+bathrooms+central_air,
         data=sample,weights=(sample$WEIGHT)) 

sample$predicted_log_rent=predict(model,sample)

write.csv(sample%>%
            group_by(region,Year)%>%
            summarize(total=n(),renters=sum(renter_data)),
          paste0('counts_',file_suffix,'.csv'),row.names=F)
