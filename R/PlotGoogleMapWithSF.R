library(sf)
library(ggplot2)
library(ggmap)

## easy peasy approach
#get the basemap
base<-get_map(location = c(lon = -71.409758, lat = 41.500898), zoom = 14, maptype = 'watercolor', source = 'stamen')
  ggmap(base)
base1<-get_map(location = c(lon = -71.409758, lat = 41.500898), zoom = 14, maptype = 'satellite', source = 'google')
  ggmap(base1)
  
#create some point locations
sites = data.frame (long = c(-71.415, -71.41, -71.39), lat = c(41.5, 41.51, 41.5) , site =factor(c("x1", "x2", "x3")))

#plot(points on map)
g<-ggmap(base)  #basemap
g + geom_point(data = sites, aes(x = long, y = lat, fill = site), pch = 21, colour = "white", size = 6)

#######working with sf objects
sites_sf<-st_as_sf(sites, coords = c("long", "lat"), crs = 3857) #convert sites df to sf object  #epsg::4326? or epsg::3857?

#plot sf object
ggplot(sites_sf) + geom_sf()

#plot sf object on base map  NOTE-this site was helpful: https://github.com/r-spatial/sf/issues/336
plot(sites_sf, bgMap = base)  #bombs: too large






#https://github.com/r-spatial/sf/issues/336
library(sf)
library(ggmap)

nc = st_read(system.file("shape/nc.shp", package="sf"))
ggplot(nc) + geom_sf()

nc_map = get_map(location = unname(st_bbox(nc)))
ggmap(nc_map)


plot(st_transform(nc, 3857)[1], col = 0, bgMap = nc_map)

