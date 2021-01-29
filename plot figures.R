#Figure 1.
pr=read.csv(paste0('rp_owned_',file_suffix,'.csv'),header=T,stringsAsFactors = F)
data=pr%>%
  filter(is.na(rp_owned)==F&rp_owned>0)%>%
  mutate(pr_ratio=1/rp_owned)%>%
  group_by(Year, region)%>%
  mutate(ntile = ntile(pr_ratio,100))%>%
  filter(pr_ratio>0&pr_ratio<50,
         rp_owned>0&rp_owned<0.2,
         ntile>5&ntile<95)

ggplot(data,aes(x=rp_owned, colour=as.factor(Year), 
                weight=weight_nonparam/sum(weight_nonparam)))+geom_density(adjust=5)+labs(title="R/P distribution of owned homes with nonparametric re-weighting", x="Rent to price ratio", y="Frequency")

ggplot(data,aes(x=pr_ratio, colour=as.factor(Year), 
                weight=weight_nonparam/sum(weight_nonparam)))+geom_density(adjust=5)+labs(title="P/R distribution of owned homes with nonparametric re-weighting", x="Price to rent ratio", y="Frequency")

#Figure 2. 
rent_own_ratio=read.csv(paste0('rent_own_ratio_',file_suffix,'.csv'),
                        header=T,stringsAsFactors = F)

nonparambins=rent_own_ratio%>%
  group_by(decile)%>%
  summarize(rent_own_ratio=mean(rent_own_ratio))

nonparambins_mean=mean(nonparambins$rent_own_ratio)

nonparambins=nonparambins%>%
  mutate(rent_own_ratio=rent_own_ratio/nonparambins_mean)

ggplot(nonparambins,aes(x=decile,y=rent_own_ratio))+geom_bar(stat='identity')+scale_x_continuous(breaks=0:9,labels=0:9)+xlab('Decile by projected rent')+ylab('Density of renters in predicted rent space')+ylim(0,4)

#Figure 3
net_yield=read.csv(paste0('net_yield_',file_suffix,'.csv'),header=T,stringsAsFactors = F)

regions=read.csv(paste0(file_suffix,'.csv'),header=T,stringsAsFactors = F)
#your own HPI data
hpi=read.csv('HPI_master.csv',header=T,stringsAsFactors = F)%>%
  filter(level=='MSA',
         hpi_type=='traditional',
         hpi_flavor=='all-transactions',
         period==2)%>%
  select(place_id,place_name,yr,index_nsa)%>%
  filter(place_id%in%regions$cbsa)%>%
  mutate(yr_next=yr+1)# Q2 data

hpa=hpi%>%
  inner_join(hpi%>%select(place_id,yr,index_nsa),by=c('place_id',c('yr_next'='yr')))%>%
  mutate(hpa=index_nsa.y/index_nsa.x-1)

hpa$place_id=as.numeric(hpa$place_id)

net_yield_ts=net_yield%>%
  group_by(Year)%>%
  summarize(gross_yield=mean(interp_rp),
            net_yield=mean(net_yield), #no extrapolation
            net_yield_1=mean(net_yield_1), #extrapolate tax using growth rate from 2005 to 2012
            net_yield_0.5=mean(net_yield_0.5)#extrapolate tax using half of the growth rate from 2005 to 2012
            )%>%
  inner_join(hpa%>%group_by(yr)%>%summarize(hpa=mean(hpa)),by=c('Year'='yr'))

ggplot(data=net_yield_ts,aes(x=Year))+geom_line(aes(y=net_yield,color='net yield (no tax extrap)'))+geom_line(aes(y=gross_yield,color='gross yield'))+geom_line(aes(y=hpa,color='hpa'))+labs(color='')+geom_line(aes(y=net_yield_1,color='net yield (extrapolate tax using same growth rate)'))+geom_line(aes(y=net_yield_0.5,color='net yield (extrapolate tax using half growth rate)'))

#Figure 4
net_yield_region=net_yield%>%
  group_by(name,cbsa,region)%>%
  summarize(net_yield=mean(net_yield))%>%
  inner_join(hpa%>%group_by(place_id)%>%summarize(hpa=mean(hpa)),by=c('cbsa'='place_id'))

ggplot(data=net_yield_region,aes(x=hpa,y=net_yield))+geom_point()+geom_text(aes(label=name))

