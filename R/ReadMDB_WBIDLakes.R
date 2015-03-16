
library(rgdal)
  MDB<-"c:/bryan/EPA/Data/WaterbodyDatabase/WaterbodyDatabase.mdb" #data source
  features <- ogrListLayers(dsn=MDB) #MRB1_WBIDLakes
  Lakes<-readOGR(dsn=MDB,'MRB1_WBIDLakes')

