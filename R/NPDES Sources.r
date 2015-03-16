

setwd('C:/Bryan/EPA/Data/DMRPollutantLoadingToolData/')
############## get data
library(RODBC)
#odbcConnectExcel2007() for xls 2007
con<-odbcConnectExcel('DMRPollutantLoadsEPA_Region1_20120131.xls',readOnly = TRUE)
#sqlTables(con)
N<-sqlFetch(con,'Nitrogen',rownames=F,colnames=F)
P<-sqlFetch(con,'Phosphorus',rownames=F,colnames=F)

names(N)<-c("NPDES_ID","Name","City","State","Latitude","Longitude","SIC_Code","HUC12","AvgConcMgL"
,"MaxConcMgL","PoundsYr","TWPE_EqYr)","FlowMGD","DataSource","HasLimits?","Outliers?")
names(P)<-names(N)

#create shape files
library(rgdal)
library(maptools)

#Projections in Proj.4
NAD83<-CRS("+proj=longlat +datum=NAD83")

#delete rows with missing Long Lat data;
N<-N[!is.na(N$Longitude) & !is.na(N$Latitude),]
P<-P[!is.na(P$Longitude) & !is.na(P$Latitude),]

#write N shapefile
xcoord<-coordinates(data.frame(N$Longitude, N$Latitude))
Gshp<-SpatialPointsDataFrame(xcoord, N, proj4string=NAD83)
writeOGR(Gshp,getwd(),'DMR_N', driver="ESRI Shapefile")


#write P shapefile
xcoord<-coordinates(data.frame(P$Longitude, P$Latitude))
Gshp<-SpatialPointsDataFrame(xcoord, P, proj4string=NAD83)
writeOGR(Gshp,getwd(),'DMR_P', driver="ESRI Shapefile")








