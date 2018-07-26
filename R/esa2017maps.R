library(here)
library(tidyverse)
library(viridis)
library(sp)
library(rgdal)

#get env data & lake grouping
load(file=here('data/env.rda'))
load(here("data/grp2.rda"))

#subset env$*_cat fields
cats<-env[,c(1,grep("_cat",names(env)))]


#create data.frame of lake points (WGS84) and cat variables
lakes_alb<-data.frame(env["AlbersX"],env["AlbersY"])
p4s<-"+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs" 
ll<-"+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" 
lakes_alb_sp<-SpatialPoints(coordinates(lakes_alb),proj4string=CRS(p4s))
lakes_dd<-spTransform(lakes_alb_sp,CRS=CRS(ll))
lakes_dd<-data.frame(coordinates(lakes_dd),cats,grp2)
names(lakes_dd)[1:2]<-c("long","lat")

#state map
state<-map_data('state')

#function to map cats
mapIt<-function(Cat,Colors,Breaks,Labels,Title){
  gg<-ggplot(state,aes(x=long,y=lat))+
    geom_polygon(aes(group=group),fill=NA,colour="black")+
    geom_point(data=lakes_dd,aes(x=long,y=lat,color=factor(Cat)),size=3.0)+  #cat variable & size
    scale_color_manual(values=Colors,                                                  #colors
                       name="",
                       breaks=Breaks,                            #cat breaks
                       labels=Labels)+                                                      #cat labels
    coord_map("albers", lat2 = 45.5, lat1 = 29.5) +
    theme(panel.background = element_blank(),
          panel.grid = element_blank(),
          panel.spacing=unit(c(0,0,0,0),"in"),
          plot.margin=unit(c(0,0,0,0),"in"),
          plot.background = element_blank(),
          legend.position = c(0.5,0),
          legend.direction="horizontal", 
          axis.text=element_blank(),
          axis.ticks = element_blank(),
          axis.title=element_blank())+
    ggtitle(Title)+                                                                      #title
    theme(plot.title = element_text(lineheight=4.8, face="bold",hjust = 0.5))  
 return(gg)
}

#map cyano_abund_cat
Cat<-lakes_dd$cyano_abund_cat
Colors<-viridis_pal()(4) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Cyanobacteria Abundance'
#Label
tl<-as.data.frame(table(lakes_dd$cyano_abund_cat,useNA='ifany'))
Labels<-c(paste(tl[1,1],"; 0 cells/ml; N = ",tl[1,2],sep=""),
       paste(tl[2,1],"; < 20k cells/ml; N = ",tl[2,2],sep=""),
       paste(tl[3,1],"; < 100k cells/ml; N = ",tl[3,2],sep=""),
       paste(tl[4,1],"; >= 100k cells/ml; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_cyano_abund_cat.jpeg'))

#map Community Type
Cat<-lakes_dd$grp2
Colors<-(viridis_pal()(2)) #scales::show_col(Colors)
Breaks<-c(1,2)
Title<-'Community Type'
#Label
tl<-as.data.frame(table(lakes_dd$grp2,useNA='ifany'))
Labels<-c(paste("Community Type One; N = ",tl[1,2],sep=""),paste("Community Type Two; N = ",tl[2,2],sep=""))
          
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_commumnity_type.jpeg'))

#map taxonomist
Cat<-lakes_dd$taxonomist_cat
Colors<-(viridis_pal()(6)) #scales::show_col(Colors)
Breaks<-c('DP', 'EEW', 'JKE',  'JS', 'KMM',  'MH')
Title<-'Taxonomist'
#Label
tl<-as.data.frame(table(lakes_dd$taxonomist_cat,useNA='ifany'))
Labels<-c('DP', 'EEW', 'JKE',  'JS', 'KMM',  'MH')
  
  
  c(paste("Community Type One; N = ",tl[1,2],sep=""),paste("Community Type Two; N = ",tl[2,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_taxonomist.jpeg'))

#map taxonomist-JS
#add category for Taxonomist = JS

lakes_dd<-mutate(lakes_dd,taxonomist_js_cat=ifelse(taxonomist_cat=='JS','JS','other'))

Cat<-lakes_dd$taxonomist_js_cat
Colors<-rev((viridis_pal()(2))) #scales::show_col(Colors)
Breaks<-c('other','JS')
Title<-'Taxonomist == "JS"'
#Label
tl<-as.data.frame(table(lakes_dd$taxonomist_js_cat,useNA='ifany'))
Labels<-c('other',  'JS')


c(paste("Community Type One; N = ",tl[1,2],sep=""),paste("Community Type Two; N = ",tl[2,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_taxonomist_js.jpeg'))

#map chla_cat
Cat<-lakes_dd$chla_cat
Colors<-(viridis_pal()(3)) #scales::show_col(Colors)
Breaks<-c("low", "med","high")
Title<-'Chlorophyll a Level'
#Label
tl<-as.data.frame(table(lakes_dd$chla_cat,useNA='ifany'))
Labels<-c(paste(tl[1,1],"; < 10 ug/l; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 50 ug/l; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; >= 50 ug/l; N = ",tl[3,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_chla_cat.jpeg'))

#map cyl_tox_cat
Cat<-lakes_dd$cyl_tox_cat
Colors<-(viridis_pal()(4)) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Cylindrospermopsin Level'
#Label
tl<-as.data.frame(table(lakes_dd$cyl_tox_cat,useNA='ifany'))
Labels<-c(paste("non-detect; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 1 ug/l; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; < 2 ug/l; N = ",tl[3,2],sep=""),
          paste(tl[4,1],"; >= 2 ug/l; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_cyl_tox_cat.jpeg'))

#map cyl_tox_cat without non-detects
Colors[1]<-NA
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_cyl_tox_cat1.jpeg'))

#map mic_tox_cat
Cat<-lakes_dd$mic_tox_cat
Colors<-(viridis_pal()(4)) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Microcystin Level'
#Label
tl<-as.data.frame(table(lakes_dd$mic_tox_cat,useNA='ifany'))
Labels<-c(paste("non-detect; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 10 ug/l; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; < 20 ug/l; N = ",tl[3,2],sep=""),
          paste(tl[4,1],"; >= 20 ug/l; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_mic_tox_cat.jpeg'))

#map mic_tox_cat without non-detects
Colors[1]<-NA
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_mic_tox_cat1.jpeg'))

#map sax_tox_cat
Cat<-lakes_dd$sax_tox_cat
Colors<-(viridis_pal()(4)) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Saxitoxin Level'
#Label
tl<-as.data.frame(table(lakes_dd$sax_tox_cat,useNA='ifany'))
Labels<-c(paste("non-detect; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 10 ug/l; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; < 20 ug/l; N = ",tl[3,2],sep=""),
          paste(tl[4,1],"; >= 20 ug/l; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_sax_tox_cat.jpeg'))

#map sax_tox_cat without non-detects
Colors[1]<-NA
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_sax_tox_cat1.jpeg'))

#map cyl_prod_abund_cat
Cat<-lakes_dd$cyl_prod_abund_cat
Colors<-(viridis_pal()(4)) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Potential Cylindrospermopsin Producer Abundance'
#Label
tl<-as.data.frame(table(lakes_dd$cyl_prod_abund_cat,useNA='ifany'))
Labels<-c(paste(tl[1,1],"; 0 cells/ml; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 20k cells/ml; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; < 100k cells/ml; N = ",tl[3,2],sep=""),
          paste(tl[4,1],"; >= 100k cells/ml; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_cyl_prod_abund_cat.jpeg'))

#map cyl_prod_abund_cat without non-detects
Colors[1]<-NA
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/cyl_prod_abund_cat1.jpeg'))

#map mic_prod_abund_cat
Cat<-lakes_dd$mic_prod_abund_cat
Colors<-(viridis_pal()(4)) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Potential Microcystin Producer Abundance'
#Label
tl<-as.data.frame(table(lakes_dd$mic_prod_abund_cat,useNA='ifany'))
Labels<-c(paste(tl[1,1],"; 0 cells/ml; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 20k cells/ml; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; < 100k cells/ml; N = ",tl[3,2],sep=""),
          paste(tl[4,1],"; >= 100k cells/ml; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_mic_prod_abund_cat.jpeg'))

#map mic_prod_abund_cat without non-detects
Colors[1]<-NA
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/mic_prod_abund_cat1.jpeg'))

#map sax_prod_abund_cat
Cat<-lakes_dd$sax_prod_abund_cat
Colors<-(viridis_pal()(4)) #scales::show_col(Colors)
Breaks<-c("none", "low", "med","high")
Title<-'Potential Saxitoxin Producer Abundance'
#Label
tl<-as.data.frame(table(lakes_dd$sax_prod_abund_cat,useNA='ifany'))
Labels<-c(paste(tl[1,1],"; 0 cells/ml; N = ",tl[1,2],sep=""),
          paste(tl[2,1],"; < 20k cells/ml; N = ",tl[2,2],sep=""),
          paste(tl[3,1],"; < 100k cells/ml; N = ",tl[3,2],sep=""),
          paste(tl[4,1],"; >= 100k cells/ml; N = ",tl[4,2],sep=""))

mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_sax_prod_abund_cat.jpeg'))

#map sax_prod_abund_cat without non-detects
Colors[1]<-NA
mapIt(Cat,Colors,Breaks,Labels,Title)

ggsave(here('output/map_sax_prod_abund_cat1.jpeg'))



