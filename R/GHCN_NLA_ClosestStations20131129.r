v<-'GHCN_NLA_ClosestStations20131129.r'
###################Get the NOAA station locations
#Info = ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/readme.txt


#Get station locations
#FORMAT OF "ghcnd-stations.txt"
#
#------------------------------
#Variable   Columns   Type
#------------------------------
#ID            1-11   Character
#LATITUDE     13-20   Real
#LONGITUDE    22-30   Real
#ELEVATION    32-37   Real
#STATE        39-40   Character
#NAME         42-71   Character
#GSNFLAG      73-75   Character
#HCNFLAG      77-79   Character
#WMOID        81-85   Character
#------------------------------

#stations data file is space delimited but there are spaces in the name column so... have to define columns.
  #spaces are set to colClasses=NULL to remove.
Stations<-read.fwf(file='ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt',as.is=T,comment.char='~',#n=10,
            width=c(11,1,8,1,9,1,6,1,2,1,30,1,3,1,3,1,5),
            colClasses=c("character",rep(c("NULL","numeric"),3),rep(c("NULL","character"),5)))
names(Stations)<-c('ID','LATITUDE','LONGITUDE','ELEVATION','STATE','NAME','GSNFLAG','HCNFLAG','WMOID')
head(Stations)

###################end Get the NOAA station locations


###################Get the lake centroid locations
#load (install) required R packages
  if (!'sp' %in% installed.packages()) install.packages('sp',repos='http://cran.cnr.Berkeley.edu');require(sp) #CRS overlay
  if (!'maptools' %in% installed.packages()) install.packages('maptools',repos='http://cran.cnr.Berkeley.edu');require(maptools)  #readShapePoly
#  if (!'rgeos' %in% installed.packages()) install.packages('rgeos',repos='http://cran.cnr.Berkeley.edu');require(rgeos) #gBuffer
#  if (!'rgdal' %in% installed.packages()) install.packages('rgdal',repos='http://cran.cnr.Berkeley.edu');require(rgdal) #readGDAL

#ESRI GCS_North_American_1983
  NAD83<-CRS("+proj=longlat +datum=NAD83")

#Get the lake shapefile
  LakeShp<-readShapePoly('C:/Bryan/EPA/Data/NLA_2007/GIS/gis_final/National_LakePoly.shp',proj4string=NAD83)

#Create a Spatial Points Data Frame of the lake centroids
  Coord<-data.frame(LakeShp$SITEID,coordinates(LakeShp)) #centroids
  names(Coord)<-c('NLA_ID','Longitude','Latitude')

###################end Get the lake centroid locations

###################Find the three closest weather stations to each lake
#Create Function to calculate the great circle distance between lake and weather stations
GreatCircle<-function(b){
  r <- 6371 # radius of the Earth (km)
  #convert to radians
  lon1 <-b[,2]*pi/180
  lat1 <-b[,3]*pi/180
  lon2 <-b[,6]*pi/180
  lat2 <-b[,5]*pi/180
  distKm <- acos(sin(lat1)*sin(lat2)+cos(lat1)*cos(lat2)*cos(lon2-lon1))*r
  return(distKm)
}


Distances<-c()
for(i in c(1:nrow(Coord))){
a<-data.frame(Coord[i,],Stations)
a$distKm<-GreatCircle(a)
a<-a[order(a$distKm),]
a<-a[1:3,]
a<-cbind(a,Rank=c(1:3))
Distances<-rbind(Distances,a)
}

summary(Distances)
table(is.na(Distances$distKm))

#Data Definitions for data.frame=Distances N=1159 (note: only 1151 lakes were sampled)
     #NLA_ID  National Lake Assessment ID
     #Longitude (decimal degrees): Longitude of Lake Centroid
     #Latitude (decimal degrees): Latitud of Lake Centroid
     #ID  NOAA DAILY GLOBAL HISTORICAL CLIMATOLOGY NETWORK station ID   
     #LATITUDE (decimal degrees): Longitude of Station
     #LONGITUDE (decimal degrees): Latitude of Station
     #ELEVATION (Meters): the elevation of the station (in meters, missing = -999.9).
     #STATE the U.S. postal code for the state (for U.S. stations only)   
     #NAME name of the station. 
     #GSNFLAG 2 choices: Blank = non-GSN station or WMO Station number not available; GSN=GSN station   
     #HCNFLAG 2 choices: Blank = non-HCN station; HCN=HCN station
     #WMOID the World Meteorological Organization (WMO) number for the station.  
     #distKm (km) great circle distance from the lake to the station 
     #Rank values c(1,2,3): 1=closest station; 2=next closest; 3=3rd closest    

###################end Find the three closest weather stations to each lake

#Get Tmax and Tmin data (see CHCN20131023.r)
load(file="L:/Public/Milstead_Lakes/RData/GHCN20131022alt.rda")

#save(Stations,Distances,file="L:/Public/Milstead_Lakes/RData/GHCN_NLA_ClosestStations20131129.rda")
load(file="L:/Public/Milstead_Lakes/RData/GHCN_NLA_ClosestStations20131129.rda")

Closest<-subset(Distances, Distances$Rank==1)

i=1
Max<-Tmax[Tmax$ID==Closest[i,'ID'],]
Min<-Tmin[Tmax$ID==Closest[i,'ID'],]

x<-data.frame(ID=unique(Closest$ID),Station=1)
y<-data.frame(ID=unique(Tmax$ID),Tdata=1)
nrow(x)
z<-merge(x,y,by='ID',all.x=F)
nrow(z)

#check to see if the daily files are available
require(RCurl)
url <- 'ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/all/'
filenames<-getURL(url, ftp.use.epsv = FALSE, dirlistonly = TRUE)
filesAll<-strsplit(filenames, "\r*\n")[[1]]


Sta<-data.frame(ID=paste(unique(Distances$ID),'.dly',sep=''),Lake=1)
nrow(Sta)  #3023 observations
All<-data.frame(ID=filesAll,All=1)
Test<-merge(Sta,All,by="ID",all.x=F)
nrow(Test) #3023 observations-a file for each station in the list. 
match(Sta[22,1],filesAll)


##Download Daily files-1 station at a time
keep<-c()
for(i in c(1:nrow(Distances))){
File<-Distances$ID[i]
URL<-'ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/all/'
Get<-paste(URL,File,'.dly',sep='')
 
Test<-read.fwf(file=Get,as.is=T,comment.char='~',
            width=c(11,4,2,4,rep(c(5,1,1,1),31)),
            colClasses=c('character','numeric','numeric','character',
            rep(c('numeric','character','character','character'),31)),na.strings = "-9999")
names(Test)<-c('ID','YEAR','MONTH','ELEMENT','VALUE1','MFLAG1','QFLAG1','SFLAG1',
                   'VALUE2','MFLAG2','QFLAG2','SFLAG2','VALUE3','MFLAG3','QFLAG3','SFLAG3',
                   'VALUE4','MFLAG4','QFLAG4','SFLAG4','VALUE5','MFLAG5','QFLAG5','SFLAG5',
                   'VALUE6','MFLAG6','QFLAG6','SFLAG6','VALUE7','MFLAG7','QFLAG7','SFLAG7',
                   'VALUE8','MFLAG8','QFLAG8','SFLAG8','VALUE9','MFLAG9','QFLAG9','SFLAG9',
                   'VALUE10','MFLAG10','QFLAG10','SFLAG10','VALUE11','MFLAG11','QFLAG11','SFLAG11',
                   'VALUE12','MFLAG12','QFLAG12','SFLAG12','VALUE13','MFLAG13','QFLAG13','SFLAG13',
                   'VALUE14','MFLAG14','QFLAG14','SFLAG14','VALUE15','MFLAG15','QFLAG15','SFLAG15',
                   'VALUE16','MFLAG16','QFLAG16','SFLAG16','VALUE17','MFLAG17','QFLAG17','SFLAG17',
                   'VALUE18','MFLAG18','QFLAG18','SFLAG18','VALUE19','MFLAG19','QFLAG19','SFLAG19',
                   'VALUE20','MFLAG20','QFLAG20','SFLAG20','VALUE21','MFLAG21','QFLAG21','SFLAG21',
                   'VALUE22','MFLAG22','QFLAG22','SFLAG22','VALUE23','MFLAG23','QFLAG23','SFLAG23',
                   'VALUE24','MFLAG24','QFLAG24','SFLAG24','VALUE25','MFLAG25','QFLAG25','SFLAG25',
                   'VALUE26','MFLAG26','QFLAG26','SFLAG26','VALUE27','MFLAG27','QFLAG27','SFLAG27',
                   'VALUE28','MFLAG28','QFLAG28','SFLAG28','VALUE29','MFLAG29','QFLAG29','SFLAG29',
                   'VALUE30','MFLAG30','QFLAG30','SFLAG30','VALUE31','MFLAG31','QFLAG31','SFLAG31')
head(Test)
Test<-Test[Test$YEAR==2007,]

Out<-data.frame(Lake=Distances$NLA_ID[i],
Station=Distances$ID[i],
Tmax=sum(!is.na(Test[Test$ELEMENT=='TMAX',seq(5,126,by=4)])),
Tmin=sum(!is.na(Test[Test$ELEMENT=='TMIN',seq(5,126,by=4)])),
Tsun=sum(!is.na(Test[Test$ELEMENT=='TSUN',seq(5,126,by=4)])),
Prcp=sum(!is.na(Test[Test$ELEMENT=='PRCP',seq(5,126,by=4)])))
keep<-rbind(keep,Out)
}

####prepare data to send to Len Coop for Degree Day Calculations
####Get dates: StartDate=1/1/2007 EndDate=SampleDate
require(RODBC)   #Package RODBC must be installed
con <- odbcConnectAccess("c:/bryan/EPA/Data/WaterbodyDatabase/WaterbodyDatabase.mdb")
A <- sqlQuery(con, "
SELECT NLA2007Sites_DesignInfo.SITE_ID, NLA2007Sites_DesignInfo.DATE_COL
FROM NLA2007Sites_DesignInfo
WHERE (((NLA2007Sites_DesignInfo.SITE_ID)<>'NLA06608-NELP-4896') AND ((NLA2007Sites_DesignInfo.VISIT_NO)=1) 
AND ((NLA2007Sites_DesignInfo.LAKE_SAMP)='Target_Sampled'))
",stringsAsFactors=F)
close(con)
str(A)
A$StartDate<-as.POSIXct(strptime('2007-01-01','%Y-%m-%d'))
names(A)[1:2]<-c('NLA_ID','EndDate')
#rename two NLA_ID's so they match the lakes data
library(plyr)
A$NLA_ID[A$NLA_ID=="NLA06608-WI:LOWES"]<-"NLA06608-WI:Lowes"
A$NLA_ID[A$NLA_ID=="NLA06608-WI:SY"]<-"NLA06608-WI:Sy"


####merge lakes locations with dates
DDlakes<-merge(Distances[Distances$Rank==1,1:3],A,by='NLA_ID',all=F)

#select a random sample of 200 lakes and reorder the columns
DDlakes<-DDlakes[sample(1:nrow(DDlakes), 200, replace = FALSE, prob = NULL),c(2,3,1,5,4)]
head(DDlakes)
nrow(DDlakes)







DDlakes<-subset(Distances[,1:3], Distances$Rank==1)

SELECT NLA2007Sites_DesignInfo.SITE_ID, NLA2007Sites_DesignInfo.DATE_COL
FROM NLA2007Sites_DesignInfo
WHERE (((NLA2007Sites_DesignInfo.VISIT_NO)=1) AND ((NLA2007Sites_DesignInfo.LAKE_SAMP)="Target_Sampled"));











