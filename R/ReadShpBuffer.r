require(sp) #CRS overlay
require(maptools)  #readShapePoly
require(rgeos) #gBuffer
require(rgdal) #readGDAL

Start<-Sys.time()
#proj4string Projection strings to use with the R package SP
#ESRI North_America_Albers_Equal_Area_Conic
Albers<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=20 +lat_2=60 +lat_0=40 +units=m +datum=NAD83')
Lake <- readShapePoly('C:/Bryan/EPA/Data/TempData/tempLake.shp', proj4string=Albers)
LakeBuf<-gBuffer(Lake,width=1000)
LakeBufDif<-gDifference(LakeBuf,Lake)



#Get dasymetric grid data for the Lake Buffer
B<-bbox(LakeBufDif)
  Offset<-c(round((3013041-B[2,2])/30)-2,round((B[1,1]-1089285)/30)-2)
  Extent<-c(round((B[2,2]-B[2,1])/30)+3,round((B[1,2]-B[1,1])/30)+3)
Dasy<-readGDAL('C:/Bryan/EPA/Data/Dasymetric/blkdensr', offset=Offset, region.dim=Extent)
  image(Dasy)
  plot(LakeBufDif,add=T)
  
####calculate the number of people and density in the buffer.
a<-!is.na(overlay(Dasy,LakeBufDif)) #return 1 for grid cells in buffer and NA for not in buffer 
                                    #"!is.na" used to create index
table(a)
sum(Dasy$band1[a])  #number of people within the buffer   200m=23.741 people 1000m=61.2206
sum(Dasy$band1[a])/(gArea(LakeBufDif)/1000000) #density people/km2  within the buffer
Sys.time()-Start



##########keep -information on the Dasymetric grid and how to subset it.
#origin=TopLeft Corner  coordinates  x=1089285 y=3013041
#bottom right:                       x=2263815 y=1576761
#offset = c(Number of Grid Rows down from Origin, Number of Grid Columns Over from Origin)
#blkdensr rows=47876 column=39151
Gr<-readGDAL('C:/Bryan/EPA/Data/Dasymetric/blkdensr', offset=c(0,0), region.dim=c(40, 40))
  G<-bbox(Gr)
Buf<-readGDAL('C:/Bryan/EPA/Data/Dasymetric/blkdensr', offset=c(5,12), region.dim=c(10, 10))
  B<-bbox(Buf)
Offset<-c(ceiling((G[2,2]-B[2,2])/30),ceiling((B[1,1]-G[1,1])/30))
Offset
plot(Gr,col='green')
plot(Buf,col='red',add=T)
#############
