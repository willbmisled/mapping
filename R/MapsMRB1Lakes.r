

require(maps)
require(sp)
require(rgdal)
library(maptools)
#proj.4 parameters- http://trac.osgeo.org/proj/wiki/GenParms
#ESRI North_America_Albers_Equal_Area_Conic
#Projection: Albers
#False_Easting: 0.000000
#False_Northing: 0.000000
#Central_Meridian: -96.000000
#Standard_Parallel_1: 20.000000
#Standard_Parallel_2: 60.000000
#Latitude_Of_Origin: 40.000000
#Linear Unit: Meter
#GCS_North_American_1983  (Geographic Coordinate System)
#Datum: D_North_American_1983

#Projections in Proj.4
Albers<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=20 +lat_2=60 +lat_0=40 +units=m +datum=NAD83')
AlbersContiguous<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +units=m +datum=NAD83')
NAD83<-CRS("+proj=longlat +datum=NAD83")
WGS84<-CRS("+proj=longlat +datum=WGS84")

RI_NAD83 <- readShapePoly('c:/temp/RI_NAD83.shp', proj4string=NAD83)
RI_Alb <- readShapePoly('c:/temp/RI_Alb.shp', proj4string=Albers)
MRB1_States_NAD83 <- readShapePoly('c:/temp/MRB1_States_NAD83.shp', proj4string=NAD83)
MRB1_States_Alb <- readShapePoly('c:/temp/MRB1_States_Alb.shp', proj4string=Albers)

require(RODBC)   #Package RODBC must be installed
con <- odbcConnectAccess("c:/bryan/EPA/Data/WaterbodyDatabase/Rwork.mdb")
Lakes <- sqlQuery(con, "
SELECT MRB1_WBIDLakes.WB_ID, MRB1_WBIDLakes.Centroid_Long, MRB1_WBIDLakes.Centroid_Lat, MRB1_WBIDLakes.AlbersX, MRB1_WBIDLakes.AlbersY
FROM MRB1_WBIDLakes;
")
close(con)
names(Lakes)


coordinates(Lakes) <- c("Centroid_Long", "Centroid_Lat")
proj4string(Lakes)<-NAD83
str(Lakes)

win.graph() #new default plot windo
par(mfrow=c(1,1))
plot(RI_NAD83,col='grey');title(main='NAD83') #plot polygon
plot(RI_Alb,col='grey');title(main='Alb',) #plot polygon
points(Lakes,col='blue',pch=19)

plot(MRB1_States_NAD83,col='grey');title(main='NAD83') #plot polygon
plot(MRB1_States_Alb,col='grey');title(main='Alb') #plot polygon
points(Lakes,col='blue',pch=19)

plot(MRB1_States_Alb,col='grey');title(main='Alb') #plot polygon
plot(RI_Alb,col='blue',add=T)

plot(MRB1_States_NAD83,col='grey');title(main='NAD83') #plot polygon
plot(RI_NAD83,col='blue',add=T)
points(Lakes,col='red',pch=19,cex=.2)

plot(RI_NAD83,col='blue',add=F);title(main='NAD83') #plot polygon
plot(MRB1_States_NAD83,col='grey',add=T)
points(Lakes,col='red',pch=19,cex=.2)




a<-map('state', region = c('rhode island'),fill=T,col='grey',plot=F) #get Rhode Island coordinates
Geo<-CRS("+proj=longlat +ellps=WGS84") #define projection for world map
RI<-map2SpatialPolygons(a,ID=1,proj4string=Geo)
Alb<-CRS("+proj=aea > +ellps=GRS80 +datum=NAD83") #define a new projections (Albers)
RI_alb<-spTransform(RI,Alb)

win.graph() #new default plot windo
par(mfrow=c(1,2))  #sets plot area as 1 rows by 2 columns
plot(RI,col='grey') #plot RI polygon
plot(RI_alb,col='grey') #plot RI polygon

llCRS<-CRS("+proj=longlat +ellps=WGS84") #define projection for world map
RI<-map2SpatialLines(a,proj4string=llCRS) #convert to spatial lines object

b<-data.frame(x=a$x,y=a$y) #extract coordinates
bList <- list(Polygons(list(Polygon(b)), "RI")) #convert coords to a Polygons object
RI<- SpatialPolygons(bList) #convert list to a SpatialPolygons object
plot(RI,col='grey') #plot RI polygon


prj_new<-CRS("+proj=aea") #define a new projections (Albers)
RI_alb<-spTransform(RI,prj_new)





Temp<-data.frame(x=MRB1$AlbersX,y=MRB1$AlbersY)
coordinates(Temp) <- c("x", "y")
points(a)
