
v<-'Nsources20110104.r'

Nsource<-factor(ifelse(Party1$Nag>Party1$Nurban & Party1$Nag>Party1$Nair,'green',
            ifelse(Party1$Nurban>Party1$Nair,'goldenrod','cornflowerblue')))
            
str(big)

ifelse(Party1$Nurban>Party1$Nair,'Nurban','Nair')


table(big,useNA='ifany')
table(Nsource,useNA='ifany')

par(mfrow=c(1,1))
par(mai=c(1,1.5,.5,1.5))
plot(Party1$AlbersX,Party1$AlbersY,col=as.character(Nsource),pch=19,cex=.4,axes=F,
     main='NE Lakes: Primary Nr Source',xlab='',ylab='',sub=v,cex.sub=.7)
legend('topleft',c('Air','Urban','Agriculture'),col=c('cornflowerblue','goldenrod','green'),pch=19,cex=1.5,bty='n')
