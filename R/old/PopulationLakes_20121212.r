v='PopulationLakes_20121211.r'

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
MRB1Lakes <- readShapePoly(
    #'C:/Bryan/EPA/Data/WaterbodyDatabase/Shapefiles/MRB1_WBIDLakes.shp', 
    'L:/Public/Milstead_Lakes/WaterbodyDatabase/Shapefiles/MRB1_WBIDLakes.shp', 
        proj4string=NAD83)

#Reproject Lakes to the same CRS as the Population grid
#which(MRB1Lakes$WB_ID==22302965) #27357 index value for lake champlain
MRB1Lakes1<-spTransform(MRB1Lakes[-27357,],AlbersContigUSGS)   #lake champlain removed

#Calculate the approximate lake radius as sqrt(Area/pi)
MRB1Lakes1$radius<-round(sqrt(MRB1Lakes1$AlbersArea/pi))
summary(MRB1Lakes1$radius)

#subset the lake shapefile
#keep<-c(4492830)  #choose lake or lakes to include
#keep<-c(4288075)  #lake on border
#keep<-c(4290651)  #Max radius lake
keep<-c(sample(MRB1Lakes1$WB_ID,1)) #a random lake
Lake<-MRB1Lakes1[match(keep,MRB1Lakes1$WB_ID),]  #subset lakes to those in 'keep'

#Get the buffers
Start<-Sys.time()
Buf300<-gDifference(gBuffer(Lake,width=300),Lake)
Buf1000<-gDifference(gBuffer(Lake,width=1000),Lake)
Buf2500<-gDifference(gBuffer(Lake,width=2500),Lake)
BufRadius<-gDifference(gBuffer(Lake,width=Lake$radius),Lake)

#Get population grid data for the Largest Lake Buffer
if(Lake$radius<=2500)B<-bbox(Buf2500) else B<-bbox(BufRadius)
  Offset<-c(round((3013041-B[2,2])/30)-2,round((B[1,1]-1089285)/30)-2)
  Extent<-c(round((B[2,2]-B[2,1])/30)+3,round((B[1,2]-B[1,1])/30)+3)

#subset the population grid data
  #Population<-readGDAL('C:/Bryan/EPA/Data/Population/blkdensr', offset=Offset, region.dim=Extent)
  Population<-readGDAL('L:/Public/Milstead_Lakes/Population/blkdensr', offset=Offset, region.dim=Extent)

#plot grid and buffers
image(Population)
  plot(Buf300,add=T)
  plot(Buf1000,add=T)
  plot(Buf2500,add=T)
  plot(BufRadius,add=T)
  title(main=paste('WBID = ',keep),sub=v)
  
####function to calculate the number of people and density in the buffer.
PopDensity<- function(Buf,BufWidthM){ 

#plot grid and buffers
  gc() #release unused memory
  a<-!is.na(overlay(Population,Buf)) #select grid cells included in the buffer
  Pop<-sum(Population$band1[a],na.rm=T) #sum population/grid cell for all cells in buffer
  BufferAreaKm2<-round(gArea(Buf)/1000000,1)   #area of buffer in km2
  PercentNA<-round(sum(is.na(Population$band1[a]))/length(Population$band1[a]),2) #percent NA cells in buffer
  PeoplePerKm2<-round(Pop/BufferAreaKm2,2)    #people per sq. km
  data.frame(WB_ID=Lake$WB_ID,BufWidthM,Pop,PeoplePerKm2,BufferAreaKm2,PercentNA)
  }
###########


#Get Pop data for buffers
  
PopDensity(Buf300,300)  
PopDensity(Buf1000,1000) 
PopDensity(Buf2500,2500) 
PopDensity(BufRadius,Lake$radius) 








