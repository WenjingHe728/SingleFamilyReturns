
########################################################################################

# run hedonic regression to predict rent for each owned house
# see detailed description in Appendix A.1 Imputing rents with a hedonic model

########################################################################################


# regression 

data=sample
data$Year=as.factor(data$Year)
data$SMSA=as.factor(data$SMSA)
data$CONDO=as.factor(data$CONDO)
data$decade=as.factor(data$decade)
data$NUNIT2=as.factor(data$NUNIT2)

model=lm(log_rent~ROOMS+BEDRMS+bathrooms+central_air+Year+SMSA+CONDO+decade+NUNIT2,data=data)

sample$predicted_rent=exp(predict(model,data))

# count summary 

sample=sample%>%
  mutate(renter_data=ifelse(is.na(log_rent),0,1))
         
summary_count=sample%>%group_by(SMSA,Year)%>%summarize(total=n(),renters=sum(renter_data))

write.csv(summary_count,'counts.csv',row.names=F)
