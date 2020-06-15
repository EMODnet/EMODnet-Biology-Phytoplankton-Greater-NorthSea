

roi <- read_delim("data/regions.csv", delim = ";")

dir.create("rawData")

beginDate<- "1995-01-01"
endDate <- "2020-05-31"

for(ii in 1:length(roi$mrgid)){
mrgid <- roi$mrgid[ii]
print(paste("downloadingdata for", roi$marregion[ii]))
downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27phytoplankton%27%5C%2C%27Phytoplankton%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv")
filename = paste0("region", roi$mrgid[ii], ".csv")
data <- read_csv(downloadURL) 
write_delim(data, file.path("rawData", filename), delim = ";")
}

read_delim(file.path("rawData", filelist[[1]]), delim = " ") %>% str()
filelist <- list.files("rawData")
allData <- lapply(filelist, function(x) 
  read_delim(file.path("rawData", x), 
             delim = ";", 
             col_types = "cccTnnlccc")) %>%
  set_names(sub(".csv", "", filelist)) %>%
  bind_rows(.id = "mrgid") %>%
  mutate(mrgid = sub("region", "", mrgid))

write_delim(allData, "data/allData.csv")


