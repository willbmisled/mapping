v='PRISMtemp20130916.r'

#load (install) required R packages
  if (!'sp' %in% installed.packages()) install.packages('sp',repos='http://cran.cnr.Berkeley.edu');require(sp) #CRS overlay
  if (!'maptools' %in% installed.packages()) install.packages('maptools',repos='http://cran.cnr.Berkeley.edu');require(maptools)  #readShapePoly
  if (!'rgeos' %in% installed.packages()) install.packages('rgeos',repos='http://cran.cnr.Berkeley.edu');require(rgeos) #gBuffer
  if (!'rgdal' %in% installed.packages()) install.packages('rgdal',repos='http://cran.cnr.Berkeley.edu');require(rgdal) #readGDAL  

#ESRI GCS_WGS_1972 
  WGS72<-CRS("+proj=longlat +ellps=WGS72")

#ESRI GCS_North_American_1983
  NAD83<-CRS("+proj=longlat +datum=NAD83")

#Get the lake shapefile
  LakeShp<-readShapePoly('C:/Bryan/EPA/Data/NLA_2007/GIS/gis_final/National_LakePoly.shp',proj4string=NAD83)
  
#Create a Spatial Points Data Frame of the lake centroids
  Coord<-coordinates(LakeShp) #centroids
  Data<-data.frame(NLA_ID=LakeShp$SITEID) #NLA_IDs as attributes
  row.names(Coord)<-row.names(Data) #harmonize the row names
  LakePts<-SpatialPointsDataFrame(Coord, Data, proj4string=NAD83) #create the object
  LakePts<-spTransform(LakePts,WGS72) #reproject to the PRISM CRS

#Get the PRISM Tmin and Tmax datasets for NLA lake centroids; all months in 2007
GetT<-function(Data){    #data can be 'min' or 'max'
setwd('C:/Bryan/EPA/Data/GIS/PRISM/')  #working directory
Mo<-c('01','02','03','04','05','06','07','08','09','10','11','12')  #list of months
Out<-data.frame(NLA_ID=LakePts$NLA_ID) #output data.frame
for(i in c(1:12)){     #scroll through the months
  Month<-Mo[i]  
  File<-paste('us_t',Data,'_2007.',Month,'.asc',sep='') #build file name for the grid
  a<-readGDAL(File)   #read ASCII grid data of temperatures
  proj4string(a)<-WGS72   #attach CRS info
  Out[,i+1]<-over(LakePts,a)/100    #get the temps 
  names(Out)[i+1]<-paste('T',Data,Month,sep='')  #rename the column
}
return(Out)    #return the data
}

Tmin<-GetT('min')
Tmax<-GetT('max')
Tmean<-(Tmax[,2:13]+Tmin[,2:13])/2
  names(Tmean)<-c('Tmean01','Tmean02','Tmean03','Tmean04','Tmean05','Tmean06',
                  'Tmean07','Tmean08','Tmean09','Tmean10','Tmean11','Tmean12') 
  Tmean<-data.frame(NLA_ID=Tmin[,1],Tmean)
  



#Get the dates
Dates<- read.csv('L:/Public/Milstead_Lakes/ChlaPaper/NLA_Chla_Data_20130925.csv')[,1:5]
#################################Data Definitions NLA2007 N = 1151 (watch for NA)
  #SITE_ID  : NLA lake identifier
  #Date     : (POSIXct) Date sample collected
  #Year     : Year of sample 
  #Month    : Month of sample 
  #Day      : Day of sample 

###################  
Days<-c(31,28,31,30,31,30,31,31,30,31,30,31) #days in the month
Base<-10 #base temp to substract from meanTemp to calculate GDD
meanGDU<-Tmean[,2:13]-Base   #calculate the meanGDU by month
  test<-function(x) ifelse(x<0,0,x)   #function to convert GDU less than zero to zero
  meanGDU<-apply(meanGDU,2,test)      #apply function to convert GDU less than zero to zero
  head(meanGDU)
  sumGDU<-meanGDU                     #sumGDU = meanGDU*number of days in the month
    for(i in c(1:12)) sumGDU[,i]<-meanGDU[,i]*Days[i] 
    head(sumGDU)
