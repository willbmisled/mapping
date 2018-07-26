NS<-'red'
na<-'goldenrod'
FS<-'green'
pie(c(20,20,20),clockwise=T,col=c(FS,NS,na),labels=NA,border=F)

setwd('C:/ArcGIS/Desktop10.0/Styles/Pictures/')


bmp(file='FSFSFS.bmp');pie(c(20,20,20),clockwise=T,col=c(FS,FS,FS),labels=NA,border=F);dev.off()#FS,FS,FS
bmp(file='FSFSna.bmp');pie(c(20,20,20),clockwise=T,col=c(FS,FS,na),labels=NA,border=F);dev.off()#FS,FS,na
bmp(file='FSFSNS.bmp');pie(c(20,20,20),clockwise=T,col=c(FS,FS,NS),labels=NA,border=F);dev.off()#FS,FS,NS
bmp(file='FSnana.bmp');pie(c(20,20,20),clockwise=T,col=c(FS,na,na),labels=NA,border=F);dev.off()#FS,na,na
bmp(file='FSNSna.bmp');pie(c(20,20,20),clockwise=T,col=c(FS,NS,na),labels=NA,border=F);dev.off()#FS,NS,na
bmp(file='naFSna.bmp');pie(c(20,20,20),clockwise=T,col=c(na,FS,na),labels=NA,border=F);dev.off()#na,FS,na
bmp(file='naFSNS.bmp');pie(c(20,20,20),clockwise=T,col=c(na,FS,NS),labels=NA,border=F);dev.off()#na,FS,NS
bmp(file='nanana.bmp');pie(c(20,20,20),clockwise=T,col=c(na,na,na),labels=NA,border=F);dev.off()#na,na,na
bmp(file='nanaNS.bmp');pie(c(20,20,20),clockwise=T,col=c(na,na,NS),labels=NA,border=F);dev.off()#na,na,NS
bmp(file='NSFSFS.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,FS,FS),labels=NA,border=F);dev.off()#NS,FS,FS
bmp(file='NSFSna.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,FS,na),labels=NA,border=F);dev.off()#NS,FS,na
bmp(file='NSFSNS.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,FS,NS),labels=NA,border=F);dev.off()#NS,FS,NS
bmp(file='NSnaFS.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,na,FS),labels=NA,border=F);dev.off()#NS,na,FS
bmp(file='NSnana.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,na,na),labels=NA,border=F);dev.off()#NS,na,na
bmp(file='NSNSna.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,NS,na),labels=NA,border=F);dev.off()#NS,NS,na
bmp(file='NSNSNS.bmp');pie(c(20,20,20),clockwise=T,col=c(NS,NS,NS),labels=NA,border=F);dev.off()#NS,NS,NS

#BMP are placed in the ArcGIS folder.
#to use them open properties, symbology tab, and double click on the point symbol to open the symbol selector
#press "Edit Symbol"
#there is a drop down list at the top of the box  that says "Type:"
#choose "Picture Marker Symbol"
#it should open the directory above, if not browse to it and choose the symbol you want.

