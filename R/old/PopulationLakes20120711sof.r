v='PopulationLakes20120711.r'

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
MRB1Lakes <- readShapePoly('C:/Bryan/MRB1_WBIDLakes.shp', proj4string=NAD83)


#Reproject Lakes to the same CRS as the Population grid
#which(MRB1Lakes$WB_ID==22302965) #27357 index value for lake champlain
MRB1Lakes1<-spTransform(MRB1Lakes[-27357,],AlbersContigUSGS)   #lake champlain removed

#Calculate the approximate lake radius as sqrt(Area/pi)
MRB1Lakes1$radius<-round(sqrt(MRB1Lakes1$AlbersArea/pi))
summary(MRB1Lakes1$radius)

#subset the lake shapefile
#keep<-c(6729133)  #choose lake or lakes to include
#
keep<-c(4290651)  #Max radius lake
Lake<-MRB1Lakes1[match(keep,MRB1Lakes1$WB_ID),]  #subset lakes to those in 'keep'

#Get the buffers
Start<-Sys.time()
Buf200<-gDifference(gBuffer(Lake,width=200),Lake)
Buf500<-gDifference(gBuffer(Lake,width=500),Lake)
Buf1000<-gDifference(gBuffer(Lake,width=1000),Lake)
Buf2000<-gDifference(gBuffer(Lake,width=2000),Lake)
BufRadius<-gDifference(gBuffer(Lake,width=Lake$radius),Lake)



#Get population grid data for the Largest Lake Buffer
if(Lake$radius<=2000)B<-bbox(Buf2000) else B<-bbox(BufRadius)
  Offset<-c(round((3013041-B[2,2])/30)-2,round((B[1,1]-1089285)/30)-2)
  Extent<-c(round((B[2,2]-B[2,1])/30)+3,round((B[1,2]-B[1,1])/30)+3)
Population<-readGDAL('C:/Bryan/Dasymetric/blkdensr', offset=Offset, region.dim=Extent)
  image(Population)
  plot(Buf200,add=T)
  plot(Buf500,add=T)
  plot(Buf1000,add=T)
  plot(Buf2000,add=T)
  plot(BufRadius,add=T)

  
####calculate the number of people and density in the buffer.
a<-c();a1<-c();a2<-c();a3<-c();a4<-c();a5<-c()
gc() #release unused memory
a<-!is.na(overlay(Population,Buf200)) #return 1 for grid cells in buffer and NA for not in buffer 
a1<-c(Lake$WB_ID,200,sum(Population$band1[a]),gArea(Buf200)/1000000)
a<-!is.na(overlay(Population,Buf500)) 
a2<-c(Lake$WB_ID,500,sum(Population$band1[a]),gArea(Buf500)/1000000)
a<-!is.na(overlay(Population,Buf1000)) 
a3<-c(Lake$WB_ID,1000,sum(Population$band1[a]),gArea(Buf1000)/1000000)
a<-!is.na(overlay(Population,Buf2000)) 
a4<-c(Lake$WB_ID,2000,sum(Population$band1[a]),gArea(Buf2000)/1000000)
a<-!is.na(overlay(Population,BufRadius)) 
a5<-c(Lake$WB_ID,Lake$radius,sum(Population$band1[a]),gArea(BufRadius)/1000000)
keep<-data.frame(rbind(a1,a2,a3,a4,a5))
names(keep)<-c('WB_ID','BufferM2','Pop','BufferAreaKm2')
keep$PeoplePerKm2<-round(keep$Pop/keep$BufferAreaKm2,1)
keep
Sys.time()-Start


#############


