library(maptools)
States<- readShapePoly('L:/Public/Milstead_Lakes/GIS/StateBoundaries/States.shp', 
      proj4string=CRS("+proj=longlat +datum=WGS84"))   #read a large shapefile with the state boundaries
L48<-States[-c(7,23,25),]  #select Lower48 and write to new spatial object
RI<-States[States$STATE_ABBR=='RI',]  #select RI and write to new spatial object

Xlim<-c(-125,-65)  #states includes AK, HI and the territories.  use Xlim and Ylim to define the area of interest
Ylim<-c(20,50)
plot(States,col='grey',axes=T,xlim=Xlim,ylim=Ylim)  #set axes to F for the map without the spatial information
par(new=T)   #add a plot to the current one.
plot(RI,col='red',xlim=Xlim,ylim=Ylim)  #add the RI polygon in Red.

