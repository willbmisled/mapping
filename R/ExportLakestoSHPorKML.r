setwd('c:\\temp')  #this is where the KML and shp files will be written
Name<-'Output'
keep<-c(495,519)   #list of lakes lakes to keep
#keep<-c(8134468)   #list of lakes lakes to keep


###########
require(sp)  #load sp package
library(rgdal) #load rgdal package
# Read data-****Make Sure the Path Is Correct****
require(RODBC)   #Package RODBC must be installed
con <- odbcConnectAccess("M:/Net MyDocuments/EPA/Data/WaterbodyDatabase/Rwork.mdb")
a <- sqlQuery(con, "
SELECT MRB1_WBIDLakes.WB_ID, MRB1_WBIDLakes.Centroid_Long, MRB1_WBIDLakes.Centroid_Lat
FROM MRB1_WBIDLakes
")
close(con)
str(a)
Lakes<-a[match(keep,a$WB_ID),]  #subset lakes to those in 'keep'

#convert lakes to a spatial points dataframe
coordinates(Lakes) <- c("Centroid_Long", "Centroid_Lat")
proj4string(Lakes)<-CRS("+proj=longlat +datum=WGS84")
writeOGR(Lakes,getwd(),Name,"ESRI Shapefile")   #create shapefile
writeOGR(Lakes["WB_ID"], paste(Name,'.kml',sep=''), Lakes$WB_ID, "KML")#create kml file



#open file in google earth
shell.exec(paste(getwd(),'/',Name,'.kml',sep=''))


#http://www.inside-r.org/packages/cran/rgdal/docs/writeOGR

library("sp")
library("rgdal")
data(meuse)
coordinates(meuse) <- c("x", "y")
proj4string(meuse) <- CRS("+init=epsg:28992")
meuse_ll <- spTransform(meuse, CRS("+proj=longlat +datum=WGS84"))
writeOGR(meuse_ll["zinc"], "meuse.kml", layer="zinc", driver="KML") 


writeOGR(meuse_ll["zinc"], "temp.kml", layer="zinc", driver="KML",overwrite_layer=T) 

writeOGR(obj=meuse_ll["zinc"],dsn="temp.kml",layer="",driver="KML",overwrite_layer=T) 

shell.exec('temp.kml')








