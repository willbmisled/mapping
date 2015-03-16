v<-'LawnsRasterAlbers20130407.r'

#ESRI USA_Contiguous_Albers_Equal_Area_Conic_USGS_version

###########
#load (install) required R packages
  if (!'sp' %in% installed.packages()) install.packages('sp');require(sp) #CRS overlay
  if (!'maptools' %in% installed.packages()) install.packages('maptools');require(maptools)  #readShapePoly
  if (!'rgeos' %in% installed.packages()) install.packages('rgeos');require(rgeos) #gBuffer
  if (!'rgdal' %in% installed.packages()) install.packages('rgdal');require(rgdal) #readGDAL
  if (!'raster' %in% installed.packages()) install.packages('raster');require(raster) #readGDAL

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
  #UL corner of pixel: -2050500.000W, 752500.000 


###projections needed
#CRS for the raw lawns ENVI grid
    #From:  http://lists.osgeo.org/pipermail/gdal-dev/2005-June/005940.html
LawnPrj<-CRS('+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs')
#ESRI GCS_WGS_1984
WGS84<-CRS("+proj=longlat +datum=WGS84")
#ESRI USA_Contiguous_Albers_Equal_Area_Conic_USGS_version
AlbersContigUSGS<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=23 +units=m +datum=NAD83')
#ESRI GCS_North_American_1983
    NAD83<-CRS("+proj=longlat +datum=NAD83")

#Get the Lawns data (raster in ENVI format)
#Lawns<-raster('C:/Bryan/EPA/Data/LawnCoverCristinaMilesi20130212/lawnfractions_revised0100.bsq')   #get raster
Lawns<-raster('L:/Public/Milstead_Lakes/LawnCoverCristinaMilesi20130212/lawnfractions_revised0100.bsq')   #get raster
projection(Lawns)<-LawnPrj   #define projection
#plot(Lawns)

#Reproject to Albers
    #Note this doesn't work on the SOF machine because it is too large (64bit with 6 gb RAM).
    #Jeff was able to reproject on his machine (64bit with 12 gb RAM)
  LawnsAlbers <- projectExtent(Lawns, AlbersContigUSGS)  #create an empty grid based on lawns
  res(LawnsAlbers) <- 1000 #need to reset the resolution.
  LawnsAlbers <- projectRaster(Lawns, LawnsAlbers) #reproject
  save(LawnsAlbers,file='L:/Public/Milstead_Lakes/LawnCoverCristinaMilesi20130212/LawnsRasterAlbers20130407.rda')
  load('L:/Public/Milstead_Lakes/LawnCoverCristinaMilesi20130212/LawnsRasterAlbers20130407.rda')  #filename = LawnsAlbers
  plot(LawnsAlbers)