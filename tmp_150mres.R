## alternative for first regression. We exclude water. And change to 150m resolution


gc()
# rough crop
norcrop <- ext(
  3.5e6, 5.5e6, # xmin, xmax
  3.5e6, 5.5e6 # ymin, ymax
)

# read EVAP raster file --------------------------------------------------------
evapr<-terra::rast(file.path(dfp,"version_2026_7",
                             "inca_input_local_climate_regulation",
                             "Vegetation_Evapotranspiration","2024",
                             "interc_transp_2024_Jun-Jul-Aug-Sept.tif"))
# rough crop
evapr_no <- crop(evapr,norcrop)
# reproject
evapr_no <- terra::project(evapr_no,"EPSG:25833")
# mask to city lau
evapr_no <- mask(crop(evapr_no,cityb_buf),cityb_buf)
# When plotting the resulting map we see that it is a bit patchy, too. Possibly
# revisit later.
# tidy up
rm(tcdr,evapr)

# read TCD raster file ---------------------------------------------------------
tcdr<-terra::rast(file.path(dfp,"version_2026_7",
                            "inca_input_local_climate_regulation",
                            "Tree_Cover_Density","2023",
                            "TCD_100m_2023_compressed.tif"))
# rough crop
tcdr_no <- crop(tcdr,norcrop)
# reproject
tcdr_no <- terra::project(tcdr_no,"EPSG:25833")
# resample (because the data has a different resolution)
tcdr_no <- terra::resample(tcdr_no,evapr_no)
# mask to city lau
tcdr_no <- mask(crop(tcdr_no,cityb_buf),cityb_buf)
# MM I have checked the resulting data and it looks fine. No gaps.



#### lst onbly for july --------------------------------------------------------
# only for july
lstr_test<-lstr_stack[["07_LST_2024_eu_masked"]]

lstr_test<- terra::resample(lstr_test,evapr_no,method = "bilinear")


# check that everything is aligned
ext(lstr_test)
ext(tcdr_no)
ext(evapr_no)



lcm <- resample(
  lcm,
  lstr_test,
  method = "near"
)
# need to recode lcm raster
rcl <- as.matrix(cats(lcm)[[1]][, c("Value", "es_id")])
lcm2 <- classify(lcm, rcl)
plot(lcm2)

lstr_test_filt <- lstr_test

lstr_test_filt[lcm2 %in% c(8,9,10,12)]<-NA

plot(lstr_test)
plot(lstr_test_filt)
# worked



# test loop across cities
## then loop across months and cities
# months to consider
mdr<-c(6,7,8,9)

# our dataframe for results
reg1df<-as.data.frame(matrix(nrow=1,ncol=12))
colnames(reg1df)<-c("month","city","est_intercept","adj_r2","n_used","n_rm","n_total","n_p_used","n_rm_p_due_lst_only","n_rm_p_due_tcd_only","n_rm_p_due_evap_only","n_rm_p_due_several")
rl<-list()
for(j in 2:2){
  rl[[j]]<-reg1df
  for(i in 1:nrow(cityb_buf)){
    rl[[j]][i,1]<-mdr[j]
    rl[[j]][i,2]<-as.data.frame(cityb_buf[i,])$LAU_NAME
    rl[[j]][i,3:12]<-first_regression_function(cityshp = cityb_buf[i,],
                                               lst_rfile = lstr_test_filt,
                                               tcd_rfile = tcdr_no,
                                               evap_rfile = evapr_no)
  }
}
firstdft<-do.call("rbind",rl)
# add city codes
firstdft <- firstdft %>% 
  mutate(city_code = cityb_buf$LAU_ID[match(city,cityb_buf$LAU_NAME)]) %>%
  relocate(city_code,.after=city)



# test total pixel number
for(i in 1:8){
  print(ncell(mask(crop(lcm2, cityb_buf[i, ]), cityb_buf[i, ])))
}






