# now averag ecooling by nuts2
j=1

n2shp<-terra::vect(file.path(dfp,"Norway_files","NUTS2021_NO_LVL2_wosvalbard","NUTS2021_NO_LVL2_wos.shp"))
n2shp <- project(n2shp,crs(lcm))

unique(n2shp$NUTS_ID)

plot(n2shp[3,])

names(n2shp)

unique(n2shp$NUTS_ID)

# so first for each nuts 2
# test for the first shape


df_sut<-as.data.frame(matrix(ncol=14,nrow=nrow(n2shp)))
colnames(df_sut)<-c("Region",estv,"w_avg_cool")
# now loop across NUTS2
# oslo is i=4
i=6

# the LAU name
df_sut$Region[i]<-as.data.frame(n2shp[i,])$NUTS_ID
# compute cooling averages
# using terra zonal
z <- terra::zonal(mask(crop(cooling_stack[[j]], n2shp[i,]),n2shp[i,]), # values
                  mask(crop(lcm2, n2shp[i,]),n2shp[i,]),# categories
                  fun="mean",
                  na.rm=T)
# set column names
colnames(z) <- c("es_id","cooling")
# add ecosystem names
z$es_name <- lcm_idf$es_type[
  match(z$es_id, lcm_idf$es_id)]
# here is the weighted cooling across all ecosystems
## MM hier weiter. Wichtig dass die extents für die gesamten NUTS2 areas natürlich ganz andere sind. Also müssen wir hier zunächst richtig ausschneiden.
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