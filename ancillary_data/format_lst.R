gc()

fp<-file.path(here::here(),"ancillary_data")
dfp<-file.path("C:","Users","muk",
               paste0("OneDrive - Statistisk sentralbyr","\U00E5"),
               "data","INCA")

lstr_6<-terra::rast(file.path(dfp,"version_2026_7",
                              "inca_input_local_climate_regulation",
                              "Land_Surface_Temperature","2024",
                              "06_LST_2024_eu_masked.tif"))
lstr_7<-terra::rast(file.path(dfp,"version_2026_7",
                              "inca_input_local_climate_regulation",
                              "Land_Surface_Temperature","2024",
                              "07_LST_2024_eu_masked.tif"))
lstr_8<-terra::rast(file.path(dfp,"version_2026_7",
                              "inca_input_local_climate_regulation",
                              "Land_Surface_Temperature","2024",
                              "08_LST_2024_eu_masked.tif"))
lstr_9<-terra::rast(file.path(dfp,"version_2026_7",
                              "inca_input_local_climate_regulation",
                              "Land_Surface_Temperature","2024",
                              "09_LST_2024_eu_masked.tif"))
# rough crop ext
norcrop <- ext(
  3.5e6, 5.5e6, # xmin, xmax
  3.5e6, 5.5e6 # ymin, ymax
)
lstr_6_no <- crop(lstr_6,norcrop)
lstr_7_no <- crop(lstr_7,norcrop)
lstr_8_no <- crop(lstr_8,norcrop)
lstr_9_no <- crop(lstr_9,norcrop)

# reproject
gc()
lstr_6_no <- terra::project(lstr_6_no,"EPSG:25833")
gc()
lstr_7_no <- terra::project(lstr_7_no,"EPSG:25833")
gc()
lstr_8_no <- terra::project(lstr_8_no,"EPSG:25833")
gc()
lstr_9_no <- terra::project(lstr_9_no,"EPSG:25833")

# save
writeRaster(lstr_6_no,file.path(fp,"lstr_6_no.tif"),overwrite =T)
writeRaster(lstr_7_no,file.path(fp,"lstr_7_no.tif"),overwrite =T)
writeRaster(lstr_8_no,file.path(fp,"lstr_8_no.tif"),overwrite =T)
writeRaster(lstr_9_no,file.path(fp,"lstr_9_no.tif"),overwrite =T)

# clean up
rm(fp,lstr_6,lstr_7,lstr_8,lstr_9,norcrop)
