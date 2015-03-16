v<-'GHCN20131023.r'

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

#create shape files
library(rgdal)
library(maptools)

xcoord<-coordinates(data.frame(Stations$LONGITUDE, Stations$LATITUDE))
StationsSP<-SpatialPointsDataFrame(xcoord, Stations, proj4string=CRS("+proj=latlong +datum=WGS84"))
plot(StationsSP)
writeOGR(StationsSP,'C:/Bryan/EPA/Data/DegreeDays','GhcdnStations', driver="ESRI Shapefile")


###########
#ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/by_year/readme.txt
#ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/by_year/ghcn-daily-by_year-format.rtf
#The following information serves as a definition of each field in one line of data covering one station-day. Each field described below is separated by a comma ( , ) and follows the order
#presented in this document.
#
#ID = 11 character station identification code
#YEAR/MONTH/DAY = 8 character date in YYYYMMDD format (e.g. 19860529 = May 29, 1986)
#ELEMENT = 4 character indicator of element type 
#DATA VALUE = 5 character data value for ELEMENT 
#M-FLAG = 1 character Measurement Flag 
#Q-FLAG = 1 character Quality Flag 
#S-FLAG = 1 character Source Flag 
#OBS-TIME = 4-character time of observation in hour-minute format (i.e. 0700 =7:00 am)
#
#See section III of the GHCN-Daily readme.txt file for an explanation of ELEMENT codes and their units as well as the M-FLAG, Q-FLAGS and S-FLAGS.
#
#The OBS-TIME field is populated with the observation times contained in NOAA/NCDC's Multinetwork Metadata System (MMS).  
#

#NOTE: I had to do the on a 64bit machine and then reduce the size of the output to save it.
#Year<-2007   #choose the year for the data  
#    File <- paste(Year,'.csv.gz',sep='')   #name of the file to download
#    tmpdir <- tempdir() #create a temp directory to store the data
#    URL <- paste('ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/by_year/',File,sep='') #location of the file
#    Output<-paste(tmpdir,'/',File,sep='')  #location of output file
#    download.file(URL,Output) #download the file
#a <- read.csv(Output,col.names=c('ID','YrMoDay','Element','Value','Time','Mflag','Qflag','Sflag'),header=F)
#
#ID<-a[,1]
#YrMoDay<-a[,2]
#Element<-a[,3]
#Value<-a[,4]
#Daily2007<-a
#Tmax<-a[a$Element=='TMAX',]
#Tmin<-a[a$Element=='TMIN',]
#
#save(ID,YrMoDay,Element,Value,Daily2007,Tmax,Tmin,file="L:/Public/Milstead_Lakes/RData/GHCN20131022.rda")
#save(Tmax,Tmin,file="L:/Public/Milstead_Lakes/RData/GHCN20131022alt.rda")

save(Stations, StationsSP,Tmax,Tmin,file="L:/Public/Milstead_Lakes/RData/GHCN20131023.rda")

load(file="L:/Public/Milstead_Lakes/RData/GHCN20131022.rda")
load("L:/Public/Milstead_Lakes/RData/GHCN20131022alt.rda")


nrow(Tmax) #4,667,367
nrow(Tmin) #4,619,929

a<-merge(Tmin,Tmax,by=c('ID','YrMoDay'),all=T)  #4,730,788 obs
 