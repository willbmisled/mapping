v='PopulationLakes_20121212a.r'

#Enter Location of Pop Grid data 
  #BlockData<-'C:/Bryan/EPA/Data/Population/blkdensr'
  BlockData<-'L:/Public/Milstead_Lakes/Population/blkdensr'
  
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
##############################

####function to calculate the number of people and density in the buffer.
CalcDensity<- function(Buf,Population){ 
  gc() #release unused memory
  a<-!is.na(overlay(Population,Buf)) #select grid cells included in the buffer
  Pop<-round(sum(Population$band1[a],na.rm=T)) #sum population/grid cell for all cells in buffer
  BufferAreaKm2<-round(gArea(Buf)/1000000,3)   #area of buffer in km2
  PercentNA<-round(sum(is.na(Population$band1[a]))/length(Population$band1[a]),2) #percent NA cells in buffer
  PeoplePerKm2<-round(Pop/BufferAreaKm2,2)    #people per sq. km
  data.frame(Pop,PeoplePerKm2,BufferAreaKm2,PercentNA)
  }
####function to calculate the number of people and density in the buffer.
PopDensity<- function(WB_ID,PlotYN){       #WB_ID ID of lake, PlotYN enter 'Y' to generate figure or 'N' for text only
  Start<-Sys.time()  #Record Start Time
  gc() #release unused memory
  Lake<-MRB1Lakes1[match(WB_ID,MRB1Lakes1$WB_ID),]  #select lake
  radius<-round(sqrt(Lake$AlbersArea/pi)) #Calculate the approximate lake radius as sqrt(Area/pi)
  #Get the buffers
    Buf300<-gDifference(gBuffer(Lake,width=300),Lake)
    Buf1000<-gDifference(gBuffer(Lake,width=1000),Lake)
    Buf2500<-gDifference(gBuffer(Lake,width=2500),Lake)
    BufRadius<-gDifference(gBuffer(Lake,width=radius),Lake)
  #Select offset and extent for maximum grid
    if(radius<=2500)B<-bbox(Buf2500) else B<-bbox(BufRadius)
      Offset<-c(round((3013041-B[2,2])/30)-2,round((B[1,1]-1089285)/30)-2)
      Extent<-c(round((B[2,2]-B[2,1])/30)+3,round((B[1,2]-B[1,1])/30)+3)
  #Get population grid data for the Largest Lake Buffer 
      #subset the population grid data
        #Population<-readGDAL(BlockData, offset=Offset, region.dim=Extent)
        Population<-readGDAL(BlockData, offset=Offset, region.dim=Extent)
  #plot grid and buffers    ###optional PlotYN='Y' to plot; PlotYN='N' to return text only.
    if(PlotYN=='Y'){
      image(Population)
      plot(Buf300,add=T)
      plot(Buf1000,add=T)
      plot(Buf2500,add=T)
      plot(BufRadius,add=T)
      title(main=paste('WB_ID = ',WB_ID),sub=v)
    }
 #calculate population and density for each buffer
    a<-data.frame(matrix(nrow=4,ncol=6)) 
    a[1,]<-c(WB_ID,300,CalcDensity(Buf300,Population)) 
    a[2,]<-c(WB_ID,1000,CalcDensity(Buf1000,Population)) 
    a[3,]<-c(WB_ID,2500,CalcDensity(Buf2500,Population)) 
    a[4,]<-c(WB_ID,radius,CalcDensity(BufRadius,Population))  
    names(a)<-c('WB_ID','BufWidthM','Pop','PopDensityKm2','BufferAreaKm2','PercentNA')
    
print(paste('Time Elapsed = ',round(Sys.time()-Start),' seconds')) #how long did the process take?
print('') #extra line

return(a)
}    
############################ 

#Ignore the warnings about holes.  This should not affect the analysis.   
    
#examples  
PopDensity(sample(MRB1Lakes1$WB_ID,1),'Y')  #random lake without plot of grid and buffers   
#PopDensity(sample(MRB1Lakes1$WB_ID,1),'N')  #random lake with results only       
#PopDensity(4290651,'Y')  #big lake     
#PopDensity(4288075,'Y')  #lake on the grid border
#PopDensity(1720193,'Y')  #lake cannot be buffered with R64 but works in R32.  Why?
#PopDensity(9326606,'Y')  #lake cannot be buffered with R64 but works in R32.  Why?
#PopDensity(6114592,'Y')  #this one looks like a cross section through the small intestines.











