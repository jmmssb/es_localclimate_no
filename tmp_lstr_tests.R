

crs(lstr_6)
ext(lstr_6)

# rough crop
lstr_6_no <- crop(lstr_6,ext(
  3.5e6, 5.5e6, # xmin, xmax
  3.5e6, 5.5e6 # ymin, ymax
))
plot(lstr_6_no)

# reproject
lstr_6_no <- terra::project(lstr_6_no,"EPSG:25833")


plot(lstr_6_no)

lstr_6_no <- mask(crop(lstr_6_no,cityb_buf),cityb_buf)

i=1
plot(mask(crop(lstr_6_no, cityb_buf[i,]),cityb_buf[i,]),main=cityb_buf$LAU_NAME[i])
# Let's try convert this into something meaningful. In accordance with the datadescription
# and covert to degrees celsius so we can make intuitive sense of it
lstr_6_no <- (lstr_6_no * 0.00341802) + 149.0 - 273.15
# resulting values make no sense whatsoever. But in terms of the regressions, the unit shouldn't matter.
# as long as we have meaningful data for the second stage.

# ok let's have a look at one example 
plot(cityb_buf[1])

# let's add lcm to this and some steets. Just for orientation. To see whether the LAUs make sense and 
# to understand the lstr raster data better. (the gaps in particular)

i=8
plot(mask(crop(lcm, cityb_buf[i,]),cityb_buf[i,]),main=cityb_buf$LAU_NAME[i])
plot(mask(crop(lstr_6_no, cityb_buf[i,]),cityb_buf[i,]),add=T,alpha=0.9)

# there are gaps in the lstr data. Visible for LAU Stavanger, Sandnes, 
# Trondheim, Bergen. At least in case of the LSTR 6 data. 

#Let's have a look at lstr7
i=8
plot(mask(crop(lcm, cityb_buf[i,]),cityb_buf[i,]),main=cityb_buf$LAU_NAME[i])
plot(mask(crop(lstr_7_no, cityb_buf[i,]),cityb_buf[i,]),add=T,alpha=0.9)
# there are also gaps in lstr7. So then we probably should import all four
# available months anyway, just to ensure we get full coverage.








