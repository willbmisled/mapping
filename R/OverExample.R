
#based on Vignette "Over"
  browseURL('http://cran.r-project.org/web/packages/sp/vignettes/over.pdf')

library(sp)
x = c(0.5, 0.5, 1.2, 1.5)
y = c(1.5, 0.5, 0.5, 0.5)
xy = cbind(x,y)
dimnames(xy)[[1]] = c("a", "b", "c", "d")
pts = SpatialPoints(xy)
xpol = c(0,1,1,0,0)
ypol = c(0,0,1,1,0)
pol = SpatialPolygons(list(
  Polygons(list(Polygon(cbind(xpol-1.05,ypol))), ID="x1"),
  Polygons(list(Polygon(cbind(xpol,ypol))), ID="x2"),
  Polygons(list(Polygon(cbind(xpol,ypol-1.05))), ID="x3"),
  Polygons(list(Polygon(cbind(xpol+1.05,ypol))), ID="x4"),
  Polygons(list(Polygon(cbind(xpol+.4, ypol+.1))), ID="x5")))


#plot points and polygons
windows(11,8.5)
#set the axis limits
Xlim<-c(min(bbox(pol)[1,],bbox(pts)[1,]),max(bbox(pol)[1,],bbox(pts)[1,]))
Ylim<-c(min(bbox(pol)[2,],bbox(pts)[2,]),max(bbox(pol)[2,],bbox(pts)[2,]))
#plot the polygons
plot(pol,xlim=Xlim,ylim=Ylim)
text(coordinates(pol), labels=rownames(coordinates(pol)), cex=2)
#add the points
plot(pts,pch=NA,add=T)
text(pts@coords, labels=rownames(pts@coords), cex=2,col='red')


#use Over to identify the polygons pol in which points pts lie 
over(pts, pol)
#use returnList=TRURE to show all polygons with points.  The method above only returns one pt per polygon.
over(pol, pol, returnList = TRUE)

#use this to convert the list to a dataframe
a<-over(pts, pol, returnList = TRUE)
Max<-length(unlist(a))+length(a)
out<-data.frame(First=rep(NA,Max),Second=rep(NA,Max))
w<-0
for(i in c(1:length(a))){ 
  if(length(a[[i]])==0){
    w<-w+1
    out[w,]<-(c(i,NA))
  } else { 
    for(j in c(1:length(a[[i]]))){ 
      w<-w+1
      out[w,]<-(c(i,a[[i]][j]))
    }}}
out<-subset(out,!is.na(out[,1]))
out

  
#using Over to extract attributes
  zdf<-data.frame(z1 = 1:4, z2=4:1, f = c("a", "a", "b", "b"),
         row.names = c("a", "b", "c", "d"))
  zdf

  ptsdf = SpatialPointsDataFrame(pts, zdf)
  
  zpl = data.frame(z = c(10, 15, 25, 3, 0), zz=1:5,
                    f = c("z", "q", "r", "z", "q"), row.names = c("x1", "x2", "x3", "x4", "x5"))
  zpl
  poldf = SpatialPolygonsDataFrame(pol, zpl)
  over(pts, poldf)
  bbox(pts)
  bbox(poldf)
  plot(pts,xlim=c(-1.1,2.1),ylim=c(-1.1,1.6))
  plot(poldf,add=T)
  
  
  

  sids<- readShapePoly(system.file("shapes/sids.shp", package="maptools")[1], 
                       proj4string=CRS("+proj=longlat +datum=NAD27"))
  over(sids,sids,returnList=TRUE)
  
  
