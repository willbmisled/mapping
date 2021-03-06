v='NLCD2006ImpervLakes_20130128.r'

#Enter Location of NLCD Grid data 
  Imperv<-'L:/Public/Milstead_Lakes/NLCD2006/nlcd2006_impervious_5-4-11.img'
#Enter loaction of the lake shapefile
  MRB1Lakes<-'L:/Public/Milstead_Lakes/WaterbodyDatabase/Shapefiles/MRB1_WBIDLakes.shp'

#load (install) required R packages
  if (!'sp' %in% installed.packages()) install.packages('sp');require(sp) #CRS overlay
  if (!'maptools' %in% installed.packages()) install.packages('maptools');require(maptools)  #readShapePoly
  if (!'rgeos' %in% installed.packages()) install.packages('rgeos');require(rgeos) #gBuffer
  if (!'rgdal' %in% installed.packages()) install.packages('rgdal');require(rgdal) #readGDAL  
  if (!'raster' %in% installed.packages()) install.packages('raster');require(raster) #readGDAL  
  
#Projection info   
#ESRI USA_Contiguous_Albers_Equal_Area_Conic_USGS_version
AlbersContigUSGS<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=23 +units=m +datum=NAD83')  
#ESRI GCS_North_American_1983
    NAD83<-CRS("+proj=longlat +datum=NAD83")

#get the NLCD grid data
Imperv<-raster(Imperv)
  #image(Imperv)
  #extent(Imperv)
  
#Get the lake shapefile
  MRB1Lakes <- readShapePoly(MRB1Lakes, proj4string=NAD83)

#Reproject Lakes to the same CRS as the Population grid
#which(MRB1Lakes$WB_ID==22302965) #27357 index value for lake champlain
MRB1Lakes<-spTransform(MRB1Lakes[-27357,],AlbersContigUSGS)   #lake champlain removed

#Associate lake holes (islands) with the correct polygon.  This is an important step.
slot(MRB1Lakes, "polygons") <- lapply(slot(MRB1Lakes, "polygons"), checkPolygonsHoles)
################################


####################works
Lake<-MRB1Lakes[match(6114592,MRB1Lakes$WB_ID),]  #select lake
#Lake<-MRB1Lakes[match(802751,MRB1Lakes$WB_ID),]  #select lake  (NA's)
  radius<-round(sqrt(Lake$AlbersArea/pi)) #Calculate the approximate lake radius as sqrt(Area/pi)
  #Get the buffers
    Buf300<-gDifference(gBuffer(Lake,width=300),Lake)
    Buf1000<-gDifference(gBuffer(Lake,width=1000),Lake)
    Buf2500<-gDifference(gBuffer(Lake,width=2500),Lake)
    BufRadius<-gDifference(gBuffer(Lake,width=radius),Lake)
  #Select offset and extent for maximum grid
    if(radius<=2500)B<-bbox(Buf2500) else B<-bbox(BufRadius)
    Extent<-c(B[1,1]-90,B[1,2]+90,B[2,1]-90,B[2,2]+90)
  #Get Impervious data for the Largest Lake Buffer + 3 30x30 pixels 
    Imp<-crop(Imperv,Extent)
  #plot grid and buffers    ###optional PlotYN='Y' to plot; PlotYN='N' to return text only.
      image(Imp)
      plot(Buf300,add=T)                  
      plot(Buf1000,add=T)
      plot(Buf2500,add=T)
      plot(BufRadius,add=T)
  


Mask<-mask(Imp, Buf2500)
a<-table(getValues(Mask),useNA='ifany')  #the NA are pixels outside of bbox of buffer.  Values of "127" are the real NA
a<-na.exclude(data.frame(Percent=as.numeric(names(a)),a)[,-2]) #replace percents stored as factors with values
a$ImpPix<-a$Percent*a$Freq/100 #processing step-convert frequency distribution to number of impervious pixels
MissingPix<-ifelse(max(a$Percent)==127,a[a$Percent==127,'Freq'],0)  #number of missing pixels
TotalPix<-sum(a$Freq)  #total number of pixels in buffer
PercentNA<-round(MissingPix/TotalPix,2)  #percent NA cells in buffer
a<-subset(a,a$Percent<=100)
BufAreaKM<-round(sum(a$Freq)*30*30/1000000,3)  #this doesn't include Pixels with missing data
ImpervAreaKM<-round(sum(a$ImpPix)*30*30/1000000,3)
PercentImperv<-round(sum(ImpervAreaKM)/sum(BufAreaKM),3)  
data.frame(PercentImperv,ImpervAreaKM,BufAreaKM,PercentNA)

############
load("L:/Public/Milstead_Lakes/RData/PopulationLakes_20130128.rda")
a<-LakePop[LakePop$PercentNA>0,]
unique(a$WB_ID)

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
  Lake<-MRB1Lakes[match(WB_ID,MRB1Lakes$WB_ID),]  #select lake
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
#get a list of WB_ID's with SPARROW data
#require(RODBC)   #Package RODBC must be installed
#con <- odbcConnectAccess("L:/Public/Milstead_Lakes/WaterbodyDatabase/MRB1.mdb")
#Lakes <- sqlQuery(con, "
#SELECT tblWBID_SparrowLoadsDSS.WB_ID FROM tblWBID_SparrowLoadsDSS;
#")
#close(con)
#str(Lakes)
  
#examples  
#PopDensity(sample(MRB1Lakes$WB_ID,1),'Y')  #random lake without plot of grid and buffers   
#PopDensity(sample(MRB1Lakes$WB_ID,1),'N')  #random lake with results only       
#PopDensity(4290651,'Y')  #big lake     
#PopDensity(4288075,'Y')  #lake on the grid border
#PopDensity(1720193,'Y')  #lake cannot be buffered with R64 but works in R32.  Why?
#PopDensity(9326606,'Y')  #lake cannot be buffered with R64 but works in R32.  Why?
#PopDensity(6114592,'Y')  #this one looks like a cross section through the small intestines.
#PopDensity(Lakes[749,],'Y')
i<-23;PopDensity(MRB1Lakes$WB_ID[i],'Y')

##loop to run a whole bunch of lakes
#start loop
B<-1  #row number to start processing lakes; this will be 1 to start.
N<-nrow(MRB1Lakes)    #last row to process; 
S<-100                 #save the work every "S" lakes
Counter<-0             #counter; should be zero to start
LakePop<-data.frame(matrix(NA,nrow=N*4,ncol=6))  #build data.frame to store the results
names(LakePop)<-c("WB_ID","BufWidthM","Pop","PopDensityKm2","BufferAreaKm2","PercentNA")  
File<-paste('L:/Public/Milstead_Lakes/RData/',v,'da',sep='')  #file to store data:  v is the version (see top of file)
#Start Loop 
for(i in c(B:N)){
LakePop[(4*i-3):(i*4),]<-PopDensity(MRB1Lakes$WB_ID[i],'N')
Counter<-Counter+1
if (Counter==S) save(LakePop,file=File)
if(Counter==S) Counter<-0
}
#End Loop


#save the data
save(LakePop,file=File)  #save the last records.
#load("L:/Public/Milstead_Lakes/RData/PopulationLakes_20130128.rda")




