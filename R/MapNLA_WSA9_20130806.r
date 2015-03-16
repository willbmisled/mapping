v<-'MapNLA_WSA9_20130806'


library(maptools)
library(maps)
library(rgdal)
library(sp)
############projections
#ESRI GCS_North_American_1983
NAD83<-CRS("+proj=longlat +datum=NAD83") 

#ESRI GCS_WGS_1984 
WGS84<-CRS("+proj=longlat +datum=WGS84")

#ESRI North_America_Albers_Equal_Area_Conic
Albers<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=20 +lat_2=60 +lat_0=40 +units=m +datum=NAD83')

#ESRI USA Contiguous Albers Equal Area Conic (used by MRB1 WBIDLakes as AlbersX and AlbersY)
AlbersContiguous<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +units=m +datum=NAD83')

 
####simple map of the lower 48 in WGS84
 States <- map("state", interior = TRUE, plot = FALSE)
 WGS84<-CRS("+proj=longlat +datum=WGS84")
 States <- map2SpatialLines(States, proj4string = WGS84)
 plot(States)
 
 
#####Detailed map of the lower48 in WGS84
states<- readShapePoly('L:/Public/Milstead_Lakes/GIS/StateBoundaries/States.shp',proj4string=WGS84) #large file  
L48<-states[-c(7,23,25),]  #select Lower48 and write to new spatial object     
 
#Get the NLA2007 locations
require(RODBC)   
con <- odbcConnectAccess("L:/Public/Milstead_Lakes/WaterbodyDatabase/WaterbodyDatabase.mdb")
NLA2007<- sqlQuery(con, "
SELECT NLA2007Sites_DesignInfo.SITE_ID, NLA2007Sites_DesignInfo.VISIT_NO, NLA2007Sites_DesignInfo.LAKE_SAMP, NLA2007Sites_DesignInfo.LON_DD, NLA2007Sites_DesignInfo.LAT_DD, NLA2007Sites_DesignInfo.ALBERS_X, NLA2007Sites_DesignInfo.ALBERS_Y
FROM NLA2007Sites_DesignInfo
WHERE (((NLA2007Sites_DesignInfo.VISIT_NO)=1) AND ((NLA2007Sites_DesignInfo.LAKE_SAMP)='Target_Sampled'));
")
close(con)
str(NLA2007)

#create shape files

xcoord<-coordinates(data.frame(NLA2007$ALBERS_X, NLA2007$ALBERS_Y))
Gshp<-SpatialPointsDataFrame(xcoord, NLA2007, proj4string=AlbersContiguous)
WGS2007<-spTransform(Gshp,WGS84)

xcoord<-coordinates(data.frame(NLA2007$LON_DD, NLA2007$LAT_DD))
Gshp<-SpatialPointsDataFrame(xcoord, NLA2007, proj4string=NAD83)
WGS2007<-spTransform(Gshp,WGS84)

 plot(States)
 par(new=T)
   plot(WGS2007,pch=16)
 
 
 plot(WGS2007,pch=16)
 
 plot(L48)
 par(new=T)
 plot(Gshp,pch=16)
#Get the NLA2012 locations
require(RODBC)   
con <- odbcConnectAccess("L:/Public/Milstead_Lakes/NLA_2012/NLA2012.mdb")
NLA2012<- sqlQuery(con, "
SELECT Nla_siteinfo_all_20130709.SITE_ID, Nla_siteinfo_all_20130709.VISIT_NO, Nla_siteinfo_all_20130709.STATUS12, Nla_siteinfo_all_20130709.LAT_DD_N83, Nla_siteinfo_all_20130709.LON_DD_N83, Nla_siteinfo_all_20130709.X_ALBERS, Nla_siteinfo_all_20130709.Y_ALBERS, NLA2012_TN_TP_CHLA.NTL, NLA2012_TN_TP_CHLA.PTL, NLA2012_TN_TP_CHLA.CHLA
FROM Nla_siteinfo_all_20130709 INNER JOIN NLA2012_TN_TP_CHLA ON (Nla_siteinfo_all_20130709.VISIT_NO = NLA2012_TN_TP_CHLA.VISIT_NO) AND (Nla_siteinfo_all_20130709.SITE_ID = NLA2012_TN_TP_CHLA.SITE_ID)
WHERE (((Nla_siteinfo_all_20130709.VISIT_NO)=1) AND ((Nla_siteinfo_all_20130709.STATUS12)='Target_Sampled'));
")
close(con)
str(NLA2012)


