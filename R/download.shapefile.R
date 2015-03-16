download.shapefile<-function(shape_url,dsn,outfile=dsn)
{
   #written by: jw hollister
   #Oct 10, 2012
   
   #set-up/clean-up variables
   if(length(grep("/$",shape_url))==0)
   {
      shape_url<-paste(shape_url,"/",sep="")
   }
   #creates vector of all possible shapefile extensions
   shapefile_ext<-c(".shp",".shx",".dbf",".prj",".sbn",".sbx",".shp.xml",".fbn",
                    ".fbx",".ain",".aih",".ixs",".mxs",".atx",".cpg")

   #Check which shapefile files exist
   if(require(RCurl))
   {
      xurl<-getURL(shape_url)
      xlogic<-NULL
      for(i in paste(dsn,shapefile_ext,sep=""))
      {
         xlogic<-c(xlogic,grepl(i,xurl))
      }
      #Set-up list of shapefiles to download
      shapefiles<-paste(shape_url,dsn,shapefile_ext,sep="")[xlogic]
      #Set-up output file names
      outfiles<-paste(outfile,shapefile_ext,sep="")[xlogic]
   }

   #Download all shapefiles
   for(i in 1:length(shapefiles))
   {
      download.file(shapefiles[i],outfiles[i],method="auto",mode="wb")
   }
}


