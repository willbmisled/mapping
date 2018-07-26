# Retrieve USGS discharge data
if(!require("dataRetrieval")){install.packages("dataRetrieval")}
library(dataRetrieval)
if(!require("dplyr")){install.packages("dplyr")}
library(dplyr)
if(!require("lubridate")){install.packages("lubridate")}
library(lubridate)
# List of gages with long-term data
site_no <- c("01108000","01109000","01109060","01109070","01110000",
               "01111500","01112500","01114500","01116000","01116500")
# see what's available for each gage
dailyDataAvailable <- whatNWISdata(siteNumbers = site_no, service = "dv")
dailyDataAvailable <- renameNWISColumns(dailyDataAvailable)
dailyDataAvail <- dailyDataAvailable %>% arrange(site_no)
rm(dailyDataAvailable)
# add some additional information
basin <- c(rep("Taunton", times=4), rep("Blackstone", times=3), "Woonasquatucket",
           rep("Pawtuxet", times=2))
drainage_area <- c(261, 43.3, 84.3, 10.6, 25.6, 91.2, 416, 38.3, 62.8, 200) # sq miles
gages <- data.frame(site_no, basin, drainage_area, stringsAsFactors = FALSE)
gage_info_wide <- left_join(dailyDataAvail, gages, by = "site_no")
# remove unnecessary columns
gage_info <- select(gage_info_wide, c(site_no, station_nm, dec_lat_va, dec_long_va,
                                      alt_va, begin_date, end_date, count_nu, basin,
                                     drainage_area))
names(gage_info) <- c("site_no", "name", "lat", "long", "alt", "begin_date", "end_date",
                      "count","basin", "drainage_area")
# write table for report to DEM
table1 <- gage_info %>% select(site_no, name, basin, lat, long, alt, 
                               drainage_area, begin_date, end_date)
write.csv(table1, file = "Table1.csv")
# retrieve mean daily data from USGS website
p_code <- "00060"   # Parameter code for Discharge (cfs)
len <- length(site_no)
for (i in 1:len){
  site <- site_no[i]
  stat_code <- "00003" # Mean (this is all that is available)
  gage_data_mean <- readNWISdv(siteNumber = site, parameterCd = p_code, 
                               startDate = "", endDate = "", statCd = stat_code)
  if(i == 1){
    flow_mean <- gage_data_mean} else {
      flow_mean <- rbind(flow_mean, gage_data_mean)}
}
# create more streamlined data frame, add month and year columns, and rename columns
flows <- flow_mean %>% select(site_no, Date, X_00060_00003) %>%
  mutate(month = month(Date), year = year(Date))
names(flows) <- c("site_no", "date", "dailyQ", "month", "year")
# Add estimates for Taunton for missing dates (detailed in Table 3)
# using Three Mile River (see taunton_3mile_compare.R) for linear
# model and supporting analyes; run that file to come up with 
# taunton_estimates (df, dim = 6238 X 3)
#
taunton_est <- taunton_estimates
taunton_est$dailyQ <- round(taunton_est$dailyQ)
taunton_est$site_no <- "01108000"
taunton_est <- taunton_est %>% select(site_no, date, dailyQ) %>%
          mutate(month = month(date), year = year(date))
taunton_est$status <- "Estimated"
flows$status <- "Actual"
# Add taunton estimates to flows dataframe, with "status" column added to 
# identify which are estimates vs. actual
flows_original <- flows
flows <- rbind(flows_original, taunton_est)
# Add params to help with plotting
flows_wide <- left_join(flows, gage_info, by = "site_no")
# Clean up
rm(basin, drainage_area, gage_data_mean, site_no, stat_code, len, i, gages, p_code,
   site, flow_mean)
