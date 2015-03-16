require(sp)

#proj4string Projection strings to use with the R package SP

epsg4326<-CRS("+init=epsg:4326") 

#ESRI GCS_North_American_1983
NAD83<-CRS("+proj=longlat +datum=NAD83") 

#ESRI GCS_North_American_1927
NAD27<-CRS("+proj=longlat +datum=NAD27") 

#ESRI GCS_WGS_1984 
WGS84<-CRS("+proj=longlat +datum=WGS84")

#ESRI GCS_WGS_1972 
WGS72<-CRS("+proj=longlat +ellps=WGS72")

#ESRI North_America_Albers_Equal_Area_Conic
Albers<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=20 +lat_2=60 +lat_0=40 +units=m +datum=NAD83')

#ESRI USA Contiguous Albers Equal Area Conic (used by MRB1 WBIDLakes as AlbersX and AlbersY)
AlbersContiguous<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +units=m +datum=NAD83')

#ESRI NAD_1983_UTM_Zone_19N is EPSG:26919
NAD83_19N<-CRS('+proj=utm +zone=19 +datum=NAD83 +units=m +no_defs')


#Paramater definitions for the proj. 4 Projection Strings:
          #http://trac.osgeo.org/proj/wiki/GenParms
          
#Example: translation of the proj4string for the Albers Equal Area Conic project from ESRI ArcMAP

#Translation of the ESRI Albers projection string

#ESRI North_America_Albers_Equal_Area_Conic
  ##+proj=aea            #Projection: Albers    
  ##+x_0=0               #False_Easting: 0.000000
  ##+x_0=0               #False_Northing: 0.000000
  ##+lon_0=-96           #Central_Meridian: -96.000000
  ##+lat_1=20            #Standard_Parallel_1: 20.000000
  ##+lat_2=60            #Standard_Parallel_2: 60.000000
  ##+lat_0=40            #Latitude_Of_Origin: 40.000000
  ##+units=m             #Linear Unit: Meter
                         #GCS_North_American_1983  (Geographic Coordinate System)
  ##+datum=NAD83         #Datum: D_North_American_1983

library(maps)
library(maptools)
#get a map of new england
a<-map('state',c('rhode island','connecticut','massachusetts','new hampshire','vermont','maine'),plot=F)

#or get a map of the U.S.
#a<-map('state',plot=F)

win.graph(10,7.5) #new graphics window in landscape
par(mfrow=c(1,2))  #sets plot area as 2 row by 2 columns

#draw in WGS84 geographic decimal degrees)
Map_WGS84<-map2SpatialLines(a,proj4string=WGS84)
plot(Map_WGS84,axes=F);title('WGS84')

#draw in Albers Equal Area Projection
Map_Albers<-map2SpatialLines(a,proj4string=Albers)
plot(Map_Albers,axes=F);title('Albers')
###########
require(sp)
require(maptools)
require(rgdal)
MRB1_States_NAD83 <- readShapePoly('c:/temp/MRB1_States_NAD83.shp', proj4string=NAD83)

MRB1_States_4326<-spTransform(MRB1_States_NAD83,epsg4326)

#lawns from Cristina Milesi
  #The data are expressed in % lawn area per square km pixel.
  #The data are in:
  #
  #Lambert Azimuthal Equal Area
  #Latitude 45 0 0.00
  #Longitude -100 0 0.00
  #False easting 0.00
  #False northing 0.00
  #Sphere: 6370997.00
  #
  #
  #Pixel: 1000 Meters
  #Datum: Unknown
  #UL corner of pixel: -2050500.000W, 752500.000?
  
#From:  http://lists.osgeo.org/pipermail/gdal-dev/2005-June/005940.html

LawnPrj<-CRS('+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs')


#simple map of the lower 48
library(maptools)
library(maps)
 States <- map("state", interior = TRUE, plot = FALSE)
 WGS84<-CRS("+proj=longlat +datum=WGS84")
 States <- map2SpatialLines(States, proj4string = WGS84)
 plot(States)


#find EPSG codes
library(rgdal)
EPSG <- make_EPSG()

# As an example, search for Hawaii state projections
EPSG[grep("hawaii", EPSG$note, ignore.case=TRUE), 1:2]

# Get PROJ.4 information for a particular EPSG code
subset(EPSG, code==26919)





