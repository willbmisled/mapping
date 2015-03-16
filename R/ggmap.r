
#ggmap vignette
#http://journal.r-project.org/archive/2013-1/kahle-wickham.pdf


require(ggmap)
require(ggplot2)

murder <- subset(crime, offense == "murder")
qmplot(lon, lat, data = murder, colour =I('red'), size = I(3), darken = .3) #with ggpmap Stamen Maps background map
qplot(lon, lat, data = murder, colour =I('red'), size = I(3), darken = .3) #with ggplot2 no background map





geocode("the white house")

qmap(location="the white house", zoom = 14)   #character string location
qmap(location=c(-77.0365,38.89768), zoom = 14)   #lon lat location

baylor <- "baylor university"
qmap(baylor, zoom = 14)   #google maps data
qmap(baylor, zoom = 14, source = "osm") #open streets map



qmap(baylor, zoom = 3, source = "osm") #zoom=3 continenal
qmap(baylor, zoom = 20, source = "osm") #zoom=3 block level

set.seed(500)
df <- round(data.frame(
x = jitter(rep(-95.36, 50), amount = .3),
y = jitter(rep( 29.76, 50), amount = .3)
), digits = 2)
map <- get_googlemap('houston', markers = df, path = df, scale = 2)
ggmap(map, extent = 'device')


qmap(baylor, zoom = 14, source = "stamen", maptype = "terrain")
qmap(baylor, zoom = 14, source = "stamen", maptype = "watercolor")
qmap(baylor, zoom = 14, source = "stamen", maptype = "toner")

qmap(baylor, zoom = 14, source = "google", maptype = "terrain")
qmap(baylor, zoom = 14, source = "google", maptype = "satellite")
qmap(baylor, zoom = 14, source = "google", maptype = "roadmap")
qmap(baylor, zoom = 14, source = "google", maptype = "hybrid")
