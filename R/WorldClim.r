
#http://www.worldclim.org/
#http://www.worldclim.org/formats   #has brief r instructions
#http://cran.r-project.org/web/packages/raster/vignettes/Raster.pdf


library(rgdal)
library(raster)

w = getData('worldclim', var='tmin', res=0.5, lon=5, lat=45)

plot(w)
