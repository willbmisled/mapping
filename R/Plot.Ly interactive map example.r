#http://spatioanalytics.com/2014/07/18/creating-an-interactive-map-of-craft-breweries-in-va-using-the-plotly-r-package/


library("devtools")
devtools::install_github("R-api","plotly")
library(plotly)
library(maps)
library(ggmap)

#login to plotly with  username (willbmisled and API key (to obtain your API key,
    #log in to plot.ly via your web browser, click Profile > Edit Profile and you
    #will see your API key)click Profile > Edit Profile and you will see your API key)
  p <- plotly(username="willbmisled", key="znio0qhw0k")

#these are the cites from wikipedia.  The blog calls a dataset that is not provided.
  data = data.frame(City=c('Virginia Beach, VA','Norfolk, VA','Chesapeake, VA','Richmond, VA','Newport News, VA',
    'Alexandria, VA','Hampton, VA','Roanoke, VA','Portsmouth, VA','Suffolk, VA','Lynchburg, VA',
    'Harrisonburg, VA','Charlottesville, VA','Danville, VA','Manassas, VA','Petersburg, VA',
    'Fredericksburg, VA','Winchester, VA','Salem, VA','Staunton, VA','Fairfax, VA','Hopewell, VA',
    'Waynesboro, VA','Bristol, VA','Colonial Heights, VA','Radford, VA','Manassas Park, VA',
    'Williamsburg, VA','Martinsville, VA','Falls Church, VA','Poquoson, VA','Franklin, VA',
    'Lexington, VA','Galax, VA','Buena Vista, VA','Covington, VA','Emporia, VA','Norton, VA'))

#randomly add number between 1&10 to simulate number of breweries per city
  data$No<-sample(1:10,38,replace=TRUE)

#geocode cities
  loc <- geocode(as.character(data$City))
  data$lon<-loc$lon
  data$lat<-loc$lat
  
#We call the state outlines using the map() function, take its xy coordinates,
    #and assign this as the first trace for plotting the map.
  trace1 <- list(x=map("state")$x,
               y=map("state")$y)
               
#add lat lon of geocded cities; bubble size = data$No
  trace2 <- list(x= data$lon,
               y=data$lat,
               text=data$City,
               type="scatter",
               mode="markers",
               marker=list(
                 "size"=sqrt(data$No/max(data$No))*20,
                 "opacity"=0.5))

#send plots to plot.ly for interactive graphic
  response <- p$plotly(trace1,trace2)
  url <- response$url
  filename <- response$filename
  browseURL(response$url)
