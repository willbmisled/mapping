v='PopulationLakes20120710.r'

require(sp) #CRS overlay
require(maptools)  #readShapePoly
require(rgeos) #gBuffer
require(rgdal) #readGDAL  


#proj4string Projection strings to use with the R package SP
#ESRI USA_Contiguous_Albers_Equal_Area_Conic_USGS_version
AlbersContigUSGS<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=23 +units=m +datum=NAD83')

#ESRI GCS_North_American_1983
NAD83<-CRS("+proj=longlat +datum=NAD83")

#get the entire lake shapefile
MRB1Lakes <- readShapePoly('C:/Bryan/EPA/Data/WaterbodyDatabase/Shapefiles/MRB1_WBIDLakes.shp', proj4string=NAD83)

#subset the lake shapefile
keep<-c(6729133)  #choose lake or lakes to include
Lake<-MRB1Lakes[match(keep,MRB1Lakes$WB_ID),]  #subset lakes to those in 'keep'

#Reproject to the same CRS as the Population grid
Lake<-spTransform(Lake,AlbersContigUSGS)

#Get the buffers
Start<-Sys.time()
Buf200<-gDifference(gBuffer(Lake,width=200),Lake)
Buf500<-gDifference(gBuffer(Lake,width=500),Lake)
Buf1000<-gDifference(gBuffer(Lake,width=1000),Lake)
Buf2000<-gDifference(gBuffer(Lake,width=2000),Lake)


#Get population grid data for the Largest Lake Buffer
B<-bbox(Buf2000)
  Offset<-c(round((3013041-B[2,2])/30)-2,round((B[1,1]-1089285)/30)-2)
  Extent<-c(round((B[2,2]-B[2,1])/30)+3,round((B[1,2]-B[1,1])/30)+3)
Population<-readGDAL('C:/Bryan/EPA/Data/Population/blkdensr', offset=Offset, region.dim=Extent)
  image(Population)
  plot(Buf200,add=T)
  plot(Buf500,add=T)
  plot(Buf1000,add=T)
  plot(Buf2000,add=T)
  
####calculate the number of people and density in the buffer.
a<-!is.na(overlay(Population,Buf200)) #return 1 for grid cells in buffer and NA for not in buffer 
a1<-c(Lake$WB_ID,200,sum(Population$band1[a]),gArea(Buf200)/1000000)
a<-!is.na(overlay(Population,Buf500)) #return 1 for grid cells in buffer and NA for not in buffer 
a2<-c(Lake$WB_ID,500,sum(Population$band1[a]),gArea(Buf500)/1000000)
a<-!is.na(overlay(Population,Buf1000)) #return 1 for grid cells in buffer and NA for not in buffer 
a3<-c(Lake$WB_ID,1000,sum(Population$band1[a]),gArea(Buf1000)/1000000)
a<-!is.na(overlay(Population,Buf2000)) #return 1 for grid cells in buffer and NA for not in buffer 
a4<-c(Lake$WB_ID,2000,sum(Population$band1[a]),gArea(Buf2000)/1000000)
keep<-data.frame(rbind(a1,a2,a3,a4))
names(keep)<-c('WB_ID','BufferM2','Pop','BufferAreaKm2')
keep$PeoplePerKm2<-round(keep$Pop/keep$BufferAreaKm2,1)
keep
Sys.time()-Start


#############


