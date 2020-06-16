require(sf)
require(tidyverse)

layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&outputFormat=application/json"
regions <- sf::st_read(layerurl)

roi <- read_delim("data/derived_data/regions.csv", delim = ";")
# check
regions %>% filter(mrgid %in% roi$mrgid) %>%
  ggplot() +
  geom_sf(fill = "blue", color = "white") +
  geom_sf_text(aes(label = mrgid), size = 2.5, color = "white")

downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"

# example for phytoplankton
# http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3Aaphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27phytoplankton%27%5C%2C%27Phytoplankton%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv
# http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3Aaphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27phytoplankton%27%5C%2C%27Phytoplankton%27%5C%2C%27Algae%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv
# 
beginDate<- "1995-01-01"
endDate <- "2020-05-31"
attributeID1 <- "phytoplankton"
attributeID2 <- "Phytoplankton"
attributeID3 <- "algae"

for(ii in 1:length(roi$mrgid)){
mrgid <- roi$mrgid[ii]
print(paste("downloadingdata for", roi$marregion[ii]))
# downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv")
downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%5C%2C%27", attributeID3, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv")
filename = paste0("region", roi$mrgid[ii], ".csv")
data <- read_csv(downloadURL) 
write_delim(data, file.path(downloadDir, "byTrait", filename), delim = ";")
}

filelist <- list.files("data/raw_data")
allData <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data", x), 
             delim = ";", 
             col_types = "cccTnnlccc")) %>%
  set_names(sub(".csv", "", filelist)) %>%
  bind_rows(.id = "mrgid") %>%
  mutate(mrgid = sub("region", "", mrgid))

write_delim(allData, file.path(dataDir, "allData.csv"), delim = ";")

datasetidsoi <- allData %>% distinct(datasetid) %>% 
  mutate(datasetid = sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', "", datasetid, fixed = T))

allData %>% distinct(scientificnameaccepted) %>% dim() # 617 species
allData %>% distinct(decimallatitude, decimallongitude) %>% dim() # 26667 localities

#==== retrieve data by dataset ==============

example <- "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B26567%5D%29%29+AND+%28%28observationdate+BETWEEN+%272015-01-01%27+AND+%272019-12-31%27+%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv"


downloadURL <- httr::modify_url("https://geo.vliz.be/geoserver/Dataportal/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal:eurobis-obisenv_basic&viewParams=where:(up.geoobjectsids=ARRAY[25232] AND datasetid=5758)&maxFeatures=50&outputformat=csv")
data <- readr::read_csv(downloadURL)
# does not return any data... something is wrong

beginDate<- "1995-01-01"
endDate <- "2020-05-31"

for(ii in 1:length(roi$mrgid)){
  for(jj in 1:length(datasetidsoi$datasetid)){
    datasetid <- datasetidsoi$datasetid[jj]
    mrgid <- roi$mrgid[ii]
    print(paste("downloadingdata for", roi$marregion[ii], "and", datasetidsoi$datasetid[jj]))
    downloadURL <- httr::modify_url(paste0("https://geo.vliz.be/geoserver/Dataportal/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal:eurobis-obisenv_basic&viewParams=where:(up.geoobjectsids=ARRAY[", mrgid, "] AND datasetid=", datasetid, ")&maxFeatures=50&outputformat=csv"))
    data <- read_csv(downloadURL) 
    filename = paste0("region", roi$mrgid[ii], "datasetid", datasetid,  ".csv")
    if(nrow(data) != 0){
      write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ";")
    }
  }
}

