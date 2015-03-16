require(maps)
require(sp)
require(maptools)
require(rgdal)

#get map of USA states
data(stateMapEnv) #from package 'maps' based on Census linework
St<-map('state', fill=TRUE)
#get state names Note: the maps datafile splits some states into subunits these need to be converted to statenames.
States<-data.frame(mapStateName=St$names) #get the state names: some of these are compound
#eliminate compound names
for(i in c(1:nrow(States))) States[i,'stateName']<-unlist(strsplit(States[i,1],":"))[1]
#convert to SP object
statesUS<-map2SpatialPolygons(St,IDs=1:nrow(States))
plot(statesUS)
#convert to spatial polygons data.frame WGS84
statesWGS84<-SpatialPolygonsDataFrame(statesUS,data=States)
proj4string(statesWGS84)<-CRS("+proj=longlat +datum=WGS84") 
plot(statesWGS84)
#reproject to NAD83
statesNAD83<-spTransform(statesWGS84,CRS("+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,06"))
plot(statesNAD83)

#us states from Jane Copeland


US50wgs84<- readShapePoly('L:/Public/Milstead_Lakes/GIS/StateBoundaries/States.shp', 
                       proj4string=CRS("+proj=longlat +datum=WGS84"))   #read a large shapefile with the state boundaries
plot(US50)

US50nad83<-spTransform(US50wgs84,CRS("+proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,06"))
plot(US50nad83)



