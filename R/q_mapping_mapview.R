# Create map showing location of USGS gages and their catchments
library('sf')
library('tidyverse')
library('mapview')

# read in data using st_read  NOTE: all data created from a Q script and saved locally
streams_x <- st_read("C:/bryan/bryan_temp/spatial_data/hydro_pi.shp", stringsAsFactors = FALSE)
ponds_x <- st_read("C:/bryan/bryan_temp/spatial_data/ponds.shp", stringsAsFactors = FALSE)
huc12s_x <- st_read("C:/bryan/bryan_temp/spatial_data/HUC12_RI_09.shp", stringsAsFactors = FALSE)

#get the gage locations
load("C:/bryan/bryan_temp/spatial_data/temp.rda")

#convert gage locations to sf object with crs = st_crs(streams_x)
#note: lat and long switched; fix first
names(gages)[1:2]<-c('long','lat')
gages_sf <- st_as_sf(gages, crs = unlist(st_crs(streams_x)['proj4string']), agr = c("constant","constant"), coords = c("lat","long"))

#use mapview to view spatial data with background map
#setup the layers
s1<-mapview(streams_x, maxpoints=10**12)
h1<-mapview(huc12s_x)
p1<-mapview(ponds_x, maxpoints=10**12)
g1<-mapview(gages_sf)

#plot layers individually or in groups
h1

s1 + g1

h1 + s1 + g1

h1 + p1 + g1

#note: I can't seem to plot streams and ponds together.  I think there are too many features for mapview.  I'm not sure all of the stream segments are mapped either.
#note: once you do have a plot you can change the basemap, turn layers on and off, zoom in and out, pan, and interact with data but clicking on features.

#export the map with mapshot
#####important- I had to run this command for mapshot to work:   webshot::install_phantomjs()
out<-h1 + g1
out
mapshot(out, file="C:/bryan/bryan_temp/spatial_data/mapshotExport.jpeg")

#but I haven't figured out how to change the base map or the zoom for the export
#might be easiest to set the map up as you want in the viewer then export a screen shot with the "export" button 
#after clicking the export button a new window will pop up.  Choose the layers, the basemap, and setup the map then save it.


