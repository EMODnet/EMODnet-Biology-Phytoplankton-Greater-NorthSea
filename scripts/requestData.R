#=======================================================================================
#
# Willem Stolte
# EMODnet Biologie
# 
# Last changes:
# 
# 2000-06-22
# geographical area adapted to EEA greater North Sea and Celtic Seas
# Now also contains Skagerrak and large part of Kattegat
# Documented in script "create-regionlist.R"
# 
# Read function changed to httr::RETRY
# In case of server failure, the request is resent 2 more times, with increasing time interval
# # 
# ======================================================================================







require(sf)
require(tidyverse)
require(httr)

downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"



# read selected geographic layers for downloading
roi <- read_delim(file.path(dataDir, "regions.csv"), delim = ";")


# read geographic layers for plotting
# Takes long time to read layer below !!!
layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho&outputFormat=application/json"
regions <- sf::st_read(layerurl)
# check by plotting
regions %>% filter(mrgid %in% roi$mrgid) %>%
  ggplot() +
  geom_sf(fill = "blue", color = "white") +
  geom_sf_text(aes(label = mrgid), size = 2, color = "white") +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())
ggsave("data/derived_data/regionsOfInterest.png", width = 3, height =  4, )



#== download data by geographic location and trait =====================================

beginDate<- "1995-01-01"
endDate <- "2020-05-31"

# both capitalized and non-capitalized occur in traits list on download tool.
# not sure if wfs-request is case-sensitive, try both
attributeID1 <- "phytoplankton"
attributeID2 <- "Phytoplankton"

# Full occurrence (selected columns)
for(ii in 1:length(roi$mrgid)){
  mrgid <- roi$mrgid[ii]
  print(paste("downloading data for", roi$marregion[ii]))
  downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Cspecificepithet%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  # downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%5C%2C%27", attributeID3, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv")
  filename = paste0("region", roi$mrgid[ii], ".csv")
  # data <- read_csv(downloadURL) 
  data <- RETRY("GET", url = downloadURL, times = 3) %>%   # max retry attempts
  content(., "text") %>%
  read_csv(guess_max = 100000)
  write_delim(data, file.path(downloadDir, "byTrait", filename), delim = ";")
}


# Extra data that fall outside marine regions
# Sylt data sets (one per year)

syltdatasetids <- c(5449, 5486:5511)
for(ii in 1:length(syltdatasetids)){
  datasetid = syltdatasetids[ii]
  print(paste("downloadingdata for", "Sylt dataset ", datasetid))
  downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3Adatasetid+IN+%28", datasetid, "%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27Phytoplankton%27%5C%2C%27phytoplankton%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Cspecificepithet%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  # downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%5C%2C%27", attributeID3, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv")
  filename = paste0("Sylt", "25231", ".csv")
  data <- RETRY("GET", url = downloadURL, times = 3) %>%   # max retry attempts
    content(., "text") %>%
    read_csv(guess_max = 100000)
  write_delim(data, file.path(downloadDir, "byTrait", filename), delim = ";")
}


# combine all downloaded files from one directory

filelist <- list.files("data/raw_data/byTrait") 
allDataTrait <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data/byTrait", x), 
             delim = ";", 
             guess_max = 100000
             # col_types = "ccccccTnnlccccccccccccccc"
             )
  ) %>%
  set_names(sub(".csv", "", filelist)) %>%
  bind_rows(.id = "mrgid") %>%
  mutate(mrgid = sub("region", "", mrgid))

write_delim(allDataTrait, file.path(dataDir, "allDataTrait.csv"), delim = ";")



#=== start from combined and saved data ===========================
#
allDataTrait <- read_delim(file.path(dataDir, "allDataTrait.csv"), delim = ";")

datasetids <- allDataTrait %>% distinct(datasetid) %>% 
  mutate(datasetid = sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', "", datasetid, fixed = T))

allDataTrait %>% distinct(scientificnameaccepted) %>% dim() # 617 species, nu 780
allDataTrait %>% distinct(decimallatitude, decimallongitude) %>% dim() # 26667 localities, nu 28625

#==== retrieve data by dataset ==============
#

# for new regions, run script above first!
# Get dataset names from IMIS web page via web scraping
# function that gets the second node "b" from the website (reverse engineering..)
getDatasetName <- function(datasetid){
  require(textreadr)
  require(rvest)
  url <- paste0("https://www.vliz.be/en/imis?module=dataset&dasid=", datasetid)
  site = read_html(url)
  fnames <- rvest::html_nodes(site, "b")
  html_text(fnames)[2]
}
# get all names and urls from id's
datasetids$name <- sapply(datasetids$datasetid, getDatasetName, simplify = T)
datasetids$url <- paste0("https://www.vliz.be/en/imis?module=dataset&dasid=", datasetids$datasetid)

write_delim(datasetids, file.path(dataDir, "allDatasets.csv"), delim = ";")

#== manual inspection of dataset names =====================================

datasetids <- read_delim(file.path(dataDir, "allDatasets.csv"), delim = ";")
datasetids %>% View

## MANUAL EDITING OF DATASETIDS BY ADDING COLUMN WITH 
## 1 - PRIORITY, DOWNLOAD
## 2 - DOUBT, INSPECT 
## 3 - NOT CONTAINING PHYTOPLANKTON, NO DOWNLOAD

currentversion = "allDatasets_modified_2020-06-22.csv"

datasetids_modified <- read_delim(file.path(dataDir, currentversion), delim = ";")



#=== uncertain datasets inspection ======================

doubtdatasets <- datasetids_modified$datasetid[datasetids_modified$keep == "2"]
getdoubtDatasets <- datasetids %>%
  filter(datasetid %in% doubtdatasets)

beginDate<- "1995-01-01"
endDate <- "2020-05-31"

for(ii in 1:length(roi$mrgid)){
  for(jj in 1:length(getdoubtDatasets$datasetid)){
    datasetid <- getdoubtDatasets$datasetid[jj]
    mrgid <- roi$mrgid[ii]
    print(paste("downloadingdata for", roi$marregion[ii], "and", getdoubtDatasets$datasetid[jj]))
    downloadURL <- paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+datasetid+IN+(", datasetid, ");context%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
    # data <- read_csv(downloadURL, guess_max = 100000, col_types = "ccccccTnnnccccccccccccccc") 
    data <- RETRY("GET", url = downloadURL, times = 3) %>%  # max retry attempts
      content(., "parsed")
    filename = paste0("region", roi$mrgid[ii], "datasetid", datasetid,  ".csv")
    if(nrow(data) != 0){
      write_delim(data, file.path(downloadDir, "byDataset2", filename), delim = ";")
    }
  }
}

filelist <- list.files("data/raw_data/byDataset2")
all2DoubtData <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data/byDataset2", x), 
             delim = ";", 
             col_types = "ccccccTnnnccccccccccccccc"
  )
) %>%
  set_names(filelist) %>%
  bind_rows(.id = "fileID") %>%
  separate(fileID, c("mrgid", "datasetID"), "_") %>%
  mutate(mrgid = sub("[[:alpha:]]+", "", mrgid)) %>%
  mutate(datasetID = sub("[[:alpha:]]+", "", datasetID))
# mutate(mrgid = sub("region", "", mrgid))


doubt_datasetids <- all2DoubtData %>% distinct(datasetid) %>%
  mutate(datasetid = sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', "", datasetid, fixed = T))

write_delim(all2DoubtData, file.path(dataDir, "all2DoubtData.csv"), delim = ";")


doubt_species <- all2DoubtData %>% distinct(scientificnameaccepted, .keep_all = TRUE) %>% select(scientificnameaccepted, phylum, datasetid) #  4966 species
all2DoubtData %>% distinct(decimallatitude, decimallongitude) %>% dim() # 124843 localities

write_delim(doubt_species, file.path(dataDir, "doubt_species.csv"), delim = ";")



# These we are certain of not containing relevant phytoplankton data
notOKdatasets <- datasetids_modified$datasetid[datasetids_modified$keep == "3"]


#== Download relevant datasets per region, no trait selection critera =======================

getDatasets <- datasetids %>%
  filter(!datasetid %in% notOKdatasets & !datasetid %in% doubtdatasets)

beginDate<- "1995-01-01"
endDate <- "2020-05-31"

for(ii in 1:length(roi$mrgid)){
  for(jj in 1:length(getDatasets$datasetid)){
    datasetid <- getDatasets$datasetid[jj]
    mrgid <- roi$mrgid[ii]
    print(paste("downloading data for ", roi$marregion[ii], "and dataset nr: ", datasetid))
    downloadURL <- paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+datasetid+IN+(", datasetid, ");context%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
    filename = paste0("region", roi$mrgid[ii], "_datasetid", datasetid,  ".csv")
    data <- RETRY("GET", url = downloadURL, times = 3) %>%   # max retry attempts
      content(., "text") %>%
      read_csv(guess_max = 100000)
    if(nrow(data) != 0){
      write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ";")
    }
  }
}

#===== extra datasets added ================================================
# Extra: These datasets fall outside the marine regions!!!! Just..
# See https://www.emodnet-biology.eu/portal/index.php?dasid=5449
syltdatasetids <- c(5449, 5486:5511)

extradatasets <- tibble(
  datasetid = syltdatasetids,
  name = sapply(syltdatasetids, getDatasetName, simplify = T),
  url = paste0("https://www.vliz.be/en/imis?module=dataset&dasid=", syltdatasetids)
)

write_delim(extradatasets, file.path(dataDir, "extraDatasets.csv"), delim = ";")

for(jj in 1:length(syltdatasetids)){
  datasetid <- syltdatasetids[jj]
  print(paste("downloading data for dataset nr: ", datasetid))
  # downloadURL <- paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3Adatasetid+IN+%28", datasetid, "%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Cspecificepithet%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3Adatasetid+IN+%28", datasetid, "%29+AND+%28%28observationdate+BETWEEN+%271995-01-01%27+AND+%272020-06-30%27+%29%29%3Bcontextcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Cspecificepithet%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  data <- read_csv(downloadURL, guess_max = 100000) 
  filename = paste0("Sylt25231_", "datasetid", datasetid,  ".csv")
  if(nrow(data) != 0){
    write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ";")
  }
}


#== combine all downloaded data =======================================

filelist <- list.files("data/raw_data/byDataset")
all2Data <- lapply((filelist), function(x) 
  read_delim(file.path("data", "raw_data/byDataset", x), 
             delim = ";", 
             # guess_max = 100000
             col_types = "ccccccTnnnccccccccccccccccc"
  )
) %>%
  set_names((filelist)) %>%
  bind_rows(.id = "fileID") %>%
  separate(fileID, c("mrgid", "datasetID"), "_") %>%
  mutate(mrgid = sub("[[:alpha:]]+", "", mrgid)) %>%
  mutate(datasetID = sub("[[:alpha:]]+", "", datasetID)) %>%
  mutate(datasetID = str_replace(datasetID, ".csv", ""))
# mutate(mrgid = sub("region", "", mrgid))

write_delim(all2Data, file.path(dataDir, "all2Data.csv"), delim = ";")
save(all2Data, file = "all2Data.Rdata")

all2Data %>% distinct(scientificnameaccepted) %>% dim() #  4805, nu 5545
all2Data %>% distinct(decimallatitude, decimallongitude) %>% dim() # 94329, nu 97756

