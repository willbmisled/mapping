
#http://stackoverflow.com/questions/15569849/calculating-great-circle-distance-in-r-programming-with-high-data-resolution

r <- 6371 # radius of the Earth (km)
data <- read.csv("FDM_test_Flight.csv")

# Convert to radians and make two vectors of point A and point B
x <- length(data$LON)
lon <- data$LON[1:(x-1)] * pi/180
lat <- data$LAT[1:(x-1)] * pi/180
lon2 <- data$LON[2:x] * pi/180
lat2 <- data$LAT[2:x] * pi/180

#Calculate distances
dist <- sum(acos(sin( lat ) * sin( lat2 ) + cos( lat ) * cos( lat2 ) * cos( lon2 -lon ) ) * r )
    #NOTE: the 'sum' operator does not appear to be necessary

########my edits

#Create Function
GreatCircle<-function(Lon1,Lat1,Lon2,Lat2){
  r <- 6371 # radius of the Earth (km)
  #convert to radians
  lon1 <-Lon1*pi/180
  lat1 <-Lat1*pi/180
  lon2 <-Lon2*pi/180
  lat2 <-Lat2*pi/180
  distKm <- acos(sin(lat1)*sin(lat2)+cos(lat1)*cos(lat2)*cos(lon2-lon1))*r
  return(distKm)
}


