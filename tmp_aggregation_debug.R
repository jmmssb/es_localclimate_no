j=2


df_sut<-as.data.frame(matrix(ncol=14,nrow=nrow(cityb_buf)))
colnames(df_sut)<-c("LAU",estv,"w_avg_cool")


i=8


# the LAU name
df_sut$LAU[i]<-as.data.frame(cityb_buf[i,])$LAU_NAME
# compute cooling averages
# using terra zonal
z <- terra::zonal(mask(crop(cooling_stack[[j]], cityb_buf[i,]),cityb_buf[i,]), # values
                  mask(crop(lcm2, cityb_buf[i,]),cityb_buf[i,]),# categories
                  fun="mean",
                  na.rm=T)

r <- mask(
  crop(cooling_stack[[j]], cityb_buf[i, ]),
  cityb_buf[i, ]
)
lcm_city <- crop(lcm2, r)

r <- mask(r, lcm_city)

global(r, median, na.rm = TRUE)
global(r, mean, na.rm = TRUE)
plot(r)

# right so here I get a value of -2.109 as a mean, 
# while I got -2.16 as a weighted mean in the table. (which is what we see as INCA result, too)
# how is that possible? Need to do more digging, to find out how our code differs from INCA here.




# set column names
colnames(z) <- c("es_id","cooling")
# add ecosystem names
z$es_name <- lcm_idf$es_type[
  match(z$es_id, lcm_idf$es_id)]
# here is the weighted cooling across all ecosystems
dfp<-freq(mask(crop(lcm2, cityb_buf[i,]),cityb_buf[i,]))
dfp['es_weight']<-dfp$count / freq(mask(crop(lcm2, cityb_buf[i,]),cityb_buf[i,])) %>% select(count) %>% sum()
z <- z %>% left_join(dfp,by=join_by("es_id" == "value"))
z['weighted_average_cooling']<-z$cooling*z$es_weight
sum(z$weighted_average_cooling)
# now it is 2.11. Yet another number. For christ's sake.

rm(dfp)
# paste result into our table, loop again, just to ensure we keep empty values where ecosystems do not exist
for(k in 1:length(estv)){
  df_sut[i,k+1]<- {
    x <- z %>% filter(es_name==estv[k]) %>% pull(cooling)
    if(length(x) == 0) NA else x
  }
  rm(x)
}
# finally the weighted average for the LAU as a whole
df_sut$w_avg_cool[i]<-sum(z$weighted_average_cooling)
rm(z)



# now loop across LAU
for(i in 1:nrow(cityb_buf)){
  # the LAU name
  df_sut$LAU[i]<-as.data.frame(cityb_buf[i,])$LAU_NAME
  # compute cooling averages
  # using terra zonal
  z <- terra::zonal(mask(crop(cooling_stack[[j]], cityb_buf[i,]),cityb_buf[i,]), # values
                    mask(crop(lcm2, cityb_buf[i,]),cityb_buf[i,]),# categories
                    fun="mean",
                    na.rm=T)
  # set column names
  colnames(z) <- c("es_id","cooling")
  # add ecosystem names
  z$es_name <- lcm_idf$es_type[
    match(z$es_id, lcm_idf$es_id)]
  # here is the weighted cooling across all ecosystems
  dfp<-freq(mask(crop(lcm2, cityb_buf[i,]),cityb_buf[i,]))
  dfp['es_weight']<-dfp$count / freq(mask(crop(lcm2, cityb_buf[i,]),cityb_buf[i,])) %>% select(count) %>% sum()
  z <- z %>% left_join(dfp,by=join_by("es_id" == "value"))
  z['weighted_average_cooling']<-z$cooling*z$es_weight
  rm(dfp)
  # paste result into our table, loop again, just to ensure we keep empty values where ecosystems do not exist
  for(k in 1:length(estv)){
    df_sut[i,k+1]<- {
      x <- z %>% filter(es_name==estv[k]) %>% pull(cooling)
      if(length(x) == 0) NA else x
    }
    rm(x)
  }
  # finally the weighted average for the LAU as a whole
  df_sut$w_avg_cool[i]<-sum(z$weighted_average_cooling)
  rm(z)
}