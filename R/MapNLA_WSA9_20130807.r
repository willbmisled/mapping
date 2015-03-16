v<-'MapNLA_WSA9_20130807.r' #name of the rscript

library(maptools)
library(maps)
library(rgdal)
library(sp)
############projections
#ESRI GCS_North_American_1983
NAD83<-CRS("+proj=longlat +datum=NAD83") 

#ESRI GCS_North_American_1927
NAD27<-CRS("+proj=longlat +datum=NAD27") 

#ESRI GCS_WGS_1984 
WGS84<-CRS("+proj=longlat +datum=WGS84")

#ESRI North_America_Albers_Equal_Area_Conic
Albers<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=20 +lat_2=60 +lat_0=40 +units=m +datum=NAD83')

#ESRI USA Contiguous Albers Equal Area Conic (used by NLA as AlbersX and AlbersY)
AlbersContiguous<-CRS('+proj=aea +x_0=0 +y_0=0 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +units=m +datum=NAD83')


####simple map of the lower 48 in WGS84
  state<-data(stateMapEnv)
  us.states<-map("state", fill=TRUE, plot=F, resolution=0) 
  IDs <- sapply(strsplit(us.states$names, ":"), function(x) x[1])
  us.map.0<-map2SpatialPolygons(us.states, IDs=IDs,proj4string=NAD27)
  StatesWGS<-spTransform(us.map.0,WGS84)
  StatesAlb<-spTransform(us.map.0,AlbersContiguous)
 
#####Detailed map of the lower48 in WGS84
  #setwd('L:/Public/Milstead_Lakes/GIS/StateBoundaries/')
#  states<- readOGR('.','States')
#  L48WGS<-states[-c(7,23,25),]    #select Lower48 and write to new spatial object   
#  L48Alb<-spTransform(L48WGS,AlbersContiguous) #reproject to AlbersContiguous 
    #writeOGR(L48,'c:/temp','L48', driver="ESRI Shapefile")
    
#####Get the WSA9 shapefile
  setwd('L:/Public/Milstead_Lakes/GIS/Ecoregions/WSA9_FromDavePeck_20130805')
    WSA9WGS<- readOGR('.','WSA_eco9_WGS1984_L48')
    WSA9Alb<-spTransform(WSA9WGS,AlbersContiguous) #reproject to AlbersContiguous 

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

#Get the NLA2012 locations
  con <- odbcConnectAccess("L:/Public/Milstead_Lakes/NLA_2012/NLA2012.mdb")
  NLA2012<- sqlQuery(con, "
  SELECT Nla_siteinfo_all_20130709.SITE_ID, Nla_siteinfo_all_20130709.VISIT_NO, Nla_siteinfo_all_20130709.STATUS12, Nla_siteinfo_all_20130709.LAT_DD_N83, Nla_siteinfo_all_20130709.LON_DD_N83, Nla_siteinfo_all_20130709.X_ALBERS, Nla_siteinfo_all_20130709.Y_ALBERS, NLA2012_TN_TP_CHLA.NTL, NLA2012_TN_TP_CHLA.PTL, NLA2012_TN_TP_CHLA.CHLA
  FROM Nla_siteinfo_all_20130709 INNER JOIN NLA2012_TN_TP_CHLA ON (Nla_siteinfo_all_20130709.VISIT_NO = NLA2012_TN_TP_CHLA.VISIT_NO) AND (Nla_siteinfo_all_20130709.SITE_ID = NLA2012_TN_TP_CHLA.SITE_ID)
  WHERE (((Nla_siteinfo_all_20130709.VISIT_NO)=1) AND ((Nla_siteinfo_all_20130709.STATUS12)='Target_Sampled'));
  ")
  close(con)
  str(NLA2012)

#create shape files of NLA locations
#2007
  xcoord<-coordinates(data.frame(NLA2007$ALBERS_X, NLA2007$ALBERS_Y))
  Alb2007<-SpatialPointsDataFrame(xcoord, NLA2007, proj4string=AlbersContiguous)
    #writeOGR(WGS2007,'c:/temp','WGS2007a', driver="ESRI Shapefile")
#2012
  xcoord<-coordinates(data.frame(NLA2012$X_ALBERS, NLA2012$Y_ALBERS))
  Alb2012<-SpatialPointsDataFrame(xcoord, NLA2012, proj4string=AlbersContiguous)
  
############ Create Map
#For the WSA9 polygon we could use the palette of the fall 2009 fashion colors
Fall2009<-c(NA,'#8773B8','#E2B36D','#7E736F','#DD8270','#C9B99F',     #first color '#CA3352'
            '#E58D9D','#D6CE3D','#004D67','#ECE1CD')  #http://www.thewebsqueeze.com/web-design-articles/color-trends-for-fall-2009.html
#Colors<-terrain.colors(10)  #or we could use a standard color palette
WSAcolors<-Fall2009  #select the colors for the WSA9 ecoregions
PtColors<-c('red','blue')  #2007 and 2012 point colors
PtSymbol<-c(15,16)  #2007 and 2012 point symbol
PtSize<-c(.5,.5)  #size of the point symbols
WSA<-as.character(slot(WSA9Alb,'data')[2:10,1])  #names of WSA9 and plot order for the legend

plot(WSA9Alb,col=WSAcolors,border=NA,axes=F,xlim=c(-2800000,2000000))   #plot ecoregions
  plot(StatesAlb,add=T)                                                 #add state boundaries
  points(Alb2007,pch=PtSymbol[1],col=PtColors[1],cex=PtSize[1])         #add 2007 NLA sites
  points(Alb2012,pch=PtSymbol[2],col=PtColors[2],cex=PtSize[2])          #add 2012 NLA sites
#Add legends 
legend('topleft',WSA,pch=15,col=WSAcolors[-1],bty='n',title='Ecoregion')  #ecoregion
legend('bottomleft',legend=c(2007,2012),pch=PtSymbol,col=PtColors,bty='n',title='Year') #NLA locations by year
  mtext(v,1,adj=1,cex=.7)  #just something I throw in so I can find the code later
 


  

