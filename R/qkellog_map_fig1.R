# Create map showing location of USGS gages and their catchments
if(!require("tidyr")){install.packages("tidyr")}
library(tidyr)
if(!require("sp")){install.packages("sp")}
library(sp)
if(!require("rgdal")){install.packages("rgdal")}
library(rgdal)
if(!require("maptools")){install.packages("maptools")}
library(maptools)
if(!require("tmap")){install.packages("tmap")}
library(tmap)
if(!require("ggmap")){install.packages("ggmap")}
library(ggmap)
if(!require("ggrepel")){install.packages("ggrepel")}
library(ggrepel)
library(ggplot2)
library(tidyverse)
# Create a data folder if it doesn't exist, then get some data
if(!dir.exists("spatial_data")){dir.create("spatial_data")}
# RI and MA HUC10s
unzip(zipfile = "spatial_data/hydrologic_units_WBDHU10_ri_3489359_01.zip", exdir = "spatial_data")
unzip(zipfile = "spatial_data/hydrologic_units_WBDHU10_ma_3489378_01.zip",
      exdir = "spatial_data")
# read in data using {rgdal}
nrcs_ri <- readOGR(dsn = "spatial_data", layer = "hydrologic_units_wbdhu10_a_ri")
nrcs_ma <- readOGR(dsn = "spatial_data", layer = "hydrologic_units_wbdhu10_a_ma")
# Get Google Map as base map
base_map <- get_googlemap(center = c(lon = -71.3, lat = 41.95), zoom = 9,
                          size = c(600, 450))
# transform to be consistent with base map
nrcs_ri_t <- spTransform(nrcs_ri, CRS("+init=epsg:4326"))
nrcs_ma_t <- spTransform(nrcs_ma, CRS("+init=epsg:4326"))
# pull out only those basins of interest
basin_names <- c("Blackstone", "Pawtuxet", "Taunton", "Woonasquatucket",
                 "Threemile")
bptw_ri_list <- sapply(basin_names, function(x) grep(x, nrcs_ri_t$Name)) 
bptw_ma_list <- sapply(basin_names, function(x) grep(x, nrcs_ma_t$Name)) 
# extract row numbers from lists
bptw_ri <- c(bptw_ri_list$Blackstone, bptw_ri_list$Pawtuxet,
             bptw_ri_list$Taunton, bptw_ri_list$Woonasquatucket,
             bptw_ri_list$Threemile)
bptw_ma <- c(bptw_ma_list$Blackstone, bptw_ma_list$Pawtuxet, 
             bptw_ma_list$Taunton, bptw_ma_list$Woonasquatucket,
             bptw_ma_list$Threemile)
# Create shape files with only these basins
nrcs_ri_basins <- nrcs_ri_t[bptw_ri,]
nrcs_ma_basins <- nrcs_ma_t[bptw_ma,]
# Add attribute that identifies large basin system
nrcs_ri_basins@data$Basin <- NA
nrcs_ma_basins@data$Basin <- NA
# find indices for each polygon associated with each basin in new shapefiles
bptw_ri_list <- sapply(basin_names, function(x) grep(x, nrcs_ri_basins$Name))
bptw_ma_list <- sapply(basin_names, function(x) grep(x, nrcs_ma_basins$Name))
nrcs_ri_basins@data$Basin[bptw_ri_list$Blackstone] <- "Blackstone"
nrcs_ri_basins@data$Basin[bptw_ri_list$Pawtuxet] <- "Pawtuxet"
nrcs_ri_basins@data$Basin[bptw_ri_list$Taunton] <- "Taunton"
nrcs_ri_basins@data$Basin[bptw_ri_list$Woonasquatucket] <- "Woonasquatucket"
nrcs_ma_basins@data$Basin[bptw_ma_list$Blackstone] <- "Blackstone"
nrcs_ma_basins@data$Basin[bptw_ma_list$Threemile] <- "Taunton"
nrcs_ma_basins@data$Basin[bptw_ma_list$Taunton] <- "Taunton"
# get USGS gage point data and transform  
gage_data <- gage_info %>% select(long, lat, site_no, name)
# convert to something ggplot can understand
nrcs_ri_b <- fortify(nrcs_ri_basins)
nrcs_ma_b <- fortify(nrcs_ma_basins)
# reconnect data by allocating id variable in original data
nrcs_ri_basins@data$id <- row.names(nrcs_ri_basins)
nrcs_ma_basins@data$id <- row.names(nrcs_ma_basins)
# join attribute data
nrcs_ri_b <- left_join(nrcs_ri_b, nrcs_ri_basins@data)
nrcs_ma_b <- left_join(nrcs_ma_b, nrcs_ma_basins@data)
#
ggmap(base_map) + 
          geom_polygon(data = nrcs_ri_b, aes(x = long, y = lat, group = group,
                                                    fill = Basin)) +
          geom_polygon(data = nrcs_ma_b, aes(x = long, y = lat, group = group,
                                          fill = Basin)) +
          geom_point(aes(x = long, y = lat), data = gage_data,
                             color = 'black', pch = 17) + 
          theme(legend.text = element_text(size = 8), legend.key.size = unit(0.3, "cm"),
                axis.text = element_text(size = 5), axis.title = element_text(size = 7)) +
          labs(x = "longitude", y = "latitude") +
          geom_text_repel(data = gage_data, 
                    aes(long, lat, label = gage_data$site_no), size = 2,
                    fontface = "bold")
ggsave(filename = "map1.png", width = 6, height = 5, units = "in")
