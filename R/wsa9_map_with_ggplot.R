library(tidyverse)
library(readxl)
library(rgdal)
#get the wsa9 ecoregion definitions
a<-read_xls("L:/Public/Milstead_Lakes/GIS/Ecoregions/AggregatedOmernikEcoregions20130806.xls","EcoregionRelations_Edited")
a<-select(a,LEVEL3=CEC_L3,WSA_9,WSA_9_NM)

#get the ecoregions
# The input file geodatabase
fgdb <- "L:/Public/Milstead_Lakes/GIS/Ecoregions/jane_ecoregions/levelIII_noslivers.gdb"

# List all feature classes in a file geodatabase
subset(ogrDrivers(), grepl("GDB", name))
fc_list <- ogrListLayers(fgdb)
print(fc_list)

# Read the feature class
wsa9<- readOGR(dsn=fgdb,layer="LevelIII_no_slivers")

# Determine the FC extent, projection, and attribute information
summary(wsa9)

wsa9@data$id<-rownames(wsa9@data)
wsa9.points<-fortify(wsa9, region="id")
wsa9.df<-left_join(wsa9.points, wsa9@data)
wsa<-left_join(wsa9.df,a)%>%filter(!is.na(WSA_9))


#plot wgs84
wgs<-ggplot(wsa) + 
  aes(long,lat,group=group,fill=WSA_9) + 
  geom_polygon() +
  geom_path(color=NA) +
  coord_equal() +
  scale_fill_brewer("WSA_9")

#plot albers
alb<-wgs+coord_map("albers", lat2 = 45.5, lat1 = 29.5)



