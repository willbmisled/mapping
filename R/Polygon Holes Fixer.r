  
#Enter loaction of the lake shapefile
  #LakeShp<-'C:/Bryan/EPA/Data/WaterbodyDatabase/Shapefiles/MRB1_WBIDLakes.shp' 
  LakeShp<-'L:/Public/Milstead_Lakes/WaterbodyDatabase/Shapefiles/MRB1_WBIDLakes.shp'

#load (install) required R packages
  if (!'sp' %in% installed.packages()) install.packages('sp');require(sp) #CRS overlay
  if (!'maptools' %in% installed.packages()) install.packages('maptools');require(maptools)  #readShapePoly
  if (!'rgeos' %in% installed.packages()) install.packages('rgeos');require(rgeos) #gBuffer
  if (!'rgdal' %in% installed.packages()) install.packages('rgdal');require(rgdal) #readGDAL  

#proj4string Projection strings to use with the R package SP
  #ESRI USA_Contiguous_Albers_Equal_Area_Conic_USGS_version
    AlbersContigUSGS<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=23 +units=m +datum=NAD83')
  #ESRI GCS_North_American_1983
    NAD83<-CRS("+proj=longlat +datum=NAD83")

#Get the lake shapefile
  MRB1Lakes <- readShapePoly(LakeShp, proj4string=NAD83)

#Reproject Lakes to the same CRS as the Population grid
#which(MRB1Lakes$WB_ID==22302965) #27357 index value for lake champlain
MRB1Lakes1<-spTransform(MRB1Lakes[-27357,],AlbersContigUSGS)   #lake champlain removed

#Associate lake holes (islands) with the correct polygon.  This is an important step.
slot(MRB1Lakes1, "polygons") <- lapply(slot(MRB1Lakes1, "polygons"), checkPolygonsHoles)

##############################

