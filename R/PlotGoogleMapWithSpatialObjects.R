library(RgoogleMaps)
library(sp)
library(ggplot2)
library(ggmap)

##############browseURL('https://wilkinsondarren.wordpress.com/tag/hadley-wickam/')
#plot a google map
g<-ggmap(
  get_googlemap(
    center=c(-3.17486, 55.92284), #Long/lat of centre, or "Edinburgh"
    zoom=14, 
    maptype='satellite', #also hybrid/terrain/roadmap
    scale = 2), #resolution scaling, 1 (low) or 2 (high)
  size = c(600, 600), #size of the image to grab
  extent='device', #can also be "normal" etc
  darken = 0) #you can dim the map when plotting on top

plot(g)

ggsave ("c:/temp/map.png", dpi = 200) #this saves the output to a file


#add data to the google map
#Generate some data
long = c(-3.17904, -3.17765, -3.17486, -3.17183)
lat = c(55.92432, 55.92353, 55.92284, 55.92174)
who = c("Darren", "Rachel", "Johannes", "Romesh")
data = data.frame (long, lat, who)

#get google map
map = ggmap(
  get_googlemap(
    center=c(-3.17486, 55.92284), 
    zoom=16, 
    maptype='hybrid', 
    scale = 2), 
  
  size = c(600, 600),
  extent='normal', 
  darken = 0)
plot(map)

#add data to map
map + geom_point (
  data = data,
  aes (
    x = long, 
    y = lat, 
    fill = factor (who)
  ), 
  pch = 21, 
  colour = "white", 
  size = 6
) +
  
  scale_fill_brewer (palette = "Set1", name = "Homies") +
  
  #for more info on these type ?theme()  
  theme ( 
    legend.position = c(0.05, 0.05), # put the legend INSIDE the plot area
    legend.justification = c(0, 0),
    legend.background = element_rect(colour = F, fill = "white"),
    legend.key = element_rect (fill = F, colour = F),
    panel.grid.major = element_blank (), # remove major grid
    panel.grid.minor = element_blank (),  # remove minor grid
    axis.text = element_blank (), 
    axis.title = element_blank (),
    axis.ticks = element_blank ()
  ) 

ggsave ("c:/temp/map.png", dpi = 200)


##########################browseURL('https://github.com/hadley/ggplot2/wiki/plotting-polygon-shapefiles')
require("rgdal") 
require("maptools")
require("ggplot2")
require("plyr")

#prepare data
  utah = readOGR(dsn="C:/Bryan/PortableApps/R/scripts/maps/data", layer="eco_l3_ut")  #http://www.epa.gov/nheerl/arm/documents/design_doc/ecoregion_design.zip
  utah@data$id = rownames(utah@data)  #add ID field
  utah.points = fortify(utah, region="id") #convert to a standard data frame containing polygon verticies
  utah.df = join(utah.points, utah@data, by="id") #add attibute data
  
#Plotting
  ggplot(utah.df) + 
    aes(long,lat,group=group,fill=LEVEL3_NAM) + 
    geom_polygon() +
    geom_path(color="white") +
    coord_equal() +
    scale_fill_brewer("Utah Ecoregion")

#Force-order the plot to insure obscured polygons are moved above their obscurers.

windows(10,7.5)

utah.points = fortify(utah, region="LEVEL3")  #modified from original
names(utah.points)[which(names(utah.points)=="id")] = "LEVEL3"
utah.df = join(utah.points, utah@data, by="LEVEL3")
ggplot(utah.df) + 
  aes(long,lat,group=group,fill=LEVEL3_NAM) + 
  geom_polygon(data=subset(utah.df,LEVEL3!=19)) +  #draw all polygons except Level3==19
  geom_polygon(data=subset(utah.df,LEVEL3==19)) +  #draw polygon for Level3==19 on top of others
  geom_path(color="white") +
  coord_equal() +
  scale_fill_brewer("Utah Ecoregion")


#Plot polygon outline only
  ggplot(utah.df) + 
    aes(long,lat,group=group,fill=LEVEL3_NAM) + 
    #geom_polygon() +
    geom_path(color="white") +
    coord_equal() #+ scale_fill_brewer("Utah Ecoregion")


########################plot polygon outlines with a google map.
#reproject to match google earth
  proj4string(utah) #need to change this to wgs84
    WGS84<-CRS("+proj=longlat +datum=WGS84")#ESRI GCS_WGS_1984 
    utahWGS84<-spTransform(utah,WGS84)
#prepare polygon data
  utahWGS84@data$id = rownames(utahWGS84@data)  #add ID field
  utahWGS84.points = fortify(utahWGS84, region="id") #convert to a standard data frame containing polygon verticies
  utahWGS84.df = join(utahWGS84.points, utahWGS84@data, by="id") #add attibute data

#get map
  Center<-apply(bbox(utahWGS84),1,mean)
  map<-ggmap(get_googlemap(center=Center,
                           zoom=7, 
                           maptype='terrain',# 'satellite', #also hybrid/terrain/roadmap
                           scale = 2), #resolution scaling, 1 (low) or 2 (high)
             size = c(600, 600), #size of the image to grab
             extent='device', #can also be "normal" etc
             darken = 0) #you can dim the map when plotting on top
  plot(map)

#add data to map  ##browseURL('http://spatioanalytics.com/2014/02/20/shapefile-polygons-plotted-on-google-maps-using-ggplot-throw-some-throw-some-stats-on-that-mappart-2/')
  map + geom_polygon(aes(x=long, y=lat, group=group), 
                          fill='grey', size=1,color='blue', data=utahWGS84.df, alpha=0)


