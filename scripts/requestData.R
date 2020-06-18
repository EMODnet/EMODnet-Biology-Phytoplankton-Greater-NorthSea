require(sf)
require(tidyverse)
downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"

# read geographic layers for plotting
layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&outputFormat=application/json"
regions <- sf::st_read(layerurl)

# read selected geographic layers for downloading
roi <- read_delim("data/derived_data/regions.csv", delim = ";")
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

attributeID1 <- "phytoplankton"
attributeID2 <- "Phytoplankton"
attributeID3 <- NULL


# Full occurrence (selected columns)
for(ii in 1:length(roi$mrgid)){
  mrgid <- roi$mrgid[ii]
  print(paste("downloadingdata for", roi$marregion[ii]))
  downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  # downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27", beginDate, "%27+AND+%27", endDate, "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+%28%27", attributeID1, "%27%5C%2C%27", attributeID2, "%27%5C%2C%27", attributeID3, "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv")
  filename = paste0("region", roi$mrgid[ii], ".csv")
  data <- read_csv(downloadURL) 
  write_delim(data, file.path(downloadDir, "byTrait", filename), delim = ";")
}

filelist <- list.files("data/raw_data/byTrait")
allDataExtra <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data/byTrait", x), 
             delim = ";", 
             col_types = "ccccccTnnlccccccccccccccc")) %>%
  set_names(sub(".csv", "", filelist)) %>%
  bind_rows(.id = "mrgid") %>%
  mutate(mrgid = sub("region", "", mrgid))

write_delim(allDataExtra, file.path(dataDir, "allDataExtra.csv"), delim = ";")


#=== from downloaded data ===========================
#
allDataExtra <- read_delim(file.path(dataDir, "allDataExtra.csv"), delim = ";")

datasetidsoi <- allDataExtra %>% distinct(datasetid) %>% 
  mutate(datasetid = sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', "", datasetid, fixed = T))

# MANUAL ADDITION OF DATASETS
addedDatasets <- tibble(datasetid = c("5449"))

datasetids <- datasetidsoi %>% bind_rows(addedDatasets)

allDataExtra %>% distinct(scientificnameaccepted) %>% dim() # 617 species
allDataExtra %>% distinct(decimallatitude, decimallongitude) %>% dim() # 26667 localities

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

paste(datasetids$datasetid, datasetids$name)

#  ok     [1] "785 Continuous Plankton Recorder (Phytoplankton)"                                                                                           
#  not ok [2] "787 Continuous Plankton Recorder (Zooplankton)"                                                                                             
#  ok     [3] "1985 NODC World Ocean Database 2001: Plankton Data"                                                                                         
#  ok     [4] "1947 Marine Life List of Ireland"                                                                                                           
#  ok     [5] "2451 REPHY: Network Monitoring phytoplankton"                                                                                               
#  ok     [6] "4424 ICES Phytoplankton Community dataset"                                                                                                  
#  not ok [7] "4412 REBENT: Benthic Network"                                                                                                               
#  ok     [8] "5977 AMOREII: Advanced Modelling and Research on Eutrophication Linking Eutrophication and Biological Resources (AMOREII)"                  
#  ok     [9] "5978 AMOREIII: Combined Effect of Changing Hydroclimate and Human Activity on Coastal Ecosystem Health (AMOREIII)"                          
#  ok     [10] "5998 Phytoplankton Monitoring at the Château du Taureau Station in the Western English Channel, from 2009 to 2011"                          
#  ok     [11] "5971 Long-term Monitoring of the Phytoplankton at the SOMLIT-Astan Station in the Western English Channel from 2000 to Present"             
#  ok     [12] "4688 LifeWatch observatory data: phytoplankton observations by imaging flow cytometry (FlowCam) in the Belgian Part of the North Sea"       
#  ok     [13] "1172 Biogeographic data from BODC - British Oceanographic Data Centre"                                                                      
#  ok     [14] "5247 DASSH: The UK Archive for Marine Species and Habitats Data"                                                                            
#  ok     [15] "1495 L4 Plankton Monitoring Programme"                                                                                                      
#  ok     [16] "2 Algaebase"                                                                                                                                
#  ok     [17] "5664 Phytoplankton data for Danish marine monitoring (ODAM) from 1988 - 2016"                                                               
#  ok     [18] "5758 Dutch long term monitoring of phytoplankton in the Dutch Continental Economical Zone of the North Sea"                                 
#  not ok [19] "5759 Dutch long term monitoring of macrobenthos in the Dutch Continental Economical Zone of the North Sea"                                  
#  ok     [20] "2722 PANGAEA - Data from various sources"                                                                                                   
#  not ok [21] "4438 IMR Zooplankton North Sea"                                                                                                             
#  ok     [22] "5666 1915-2016  Marine Strategy Framework Directive (MSFD) Collation of invasive non-indigenous species data UK"                            
#  not ok [23] "2756 PANGAEA - Data from the Ocean Drilling Program (ODP)"                                                                                  
#  ok     [24] "2768 PANGAEA - Data from Ocean margin exchange project (OMEX I)"                                                                            
#  ok     [25] "5945 Macrobenthos and Phytoplankton monitoring in the Belgian coastal zone in the context of the EU Water Framework Directive (WFD)"        
#  ok     [26] "5951 IPMS-PHAEO: Dynamics of coastal eutrophicated ecosystems"                                                                              
#  ok     [27] "5976 AMORE: Advanced Modelling & Research on Eutrophication & the Structure of Coastal Planktonic Food-webs: Mechanisms & Modelling (AMORE)"
#  not ok [28] "4687 LifeWatch observatory data: zooplankton observations in the Belgian Part of the North Sea"
#  ok     [29] "5451 Semi-quantitive microplankton analysis (Sylt Roads Time Series) in the Wadden Sea off List, Sylt, North Sea"  
# 
# These we are not certain of
doubtdatasets <- c(1947, 2, 4438, 5666)
# getdoubtDatasets <- datasetids %>%
#   filter(datasetid %in% doubtdatasets)
# 
# beginDate<- "1995-01-01"
# endDate <- "2020-05-31"
# 
# for(ii in 1:length(roi$mrgid)){
#   for(jj in 1:length(getdoubtDatasets$datasetid)){
#     datasetid <- getdoubtDatasets$datasetid[jj]
#     mrgid <- roi$mrgid[ii]
#     print(paste("downloadingdata for", roi$marregion[ii], "and", getdoubtDatasets$datasetid[jj]))
#     downloadURL <- paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, "%5D%29%29+AND+datasetid+IN+(", datasetid, ");context%3A0100;&outputFormat=csv")
#     data <- read_csv(downloadURL) 
#     filename = paste0("region", roi$mrgid[ii], "datasetid", datasetid,  ".csv")
#     if(nrow(data) != 0){
#       write_delim(data, file.path(downloadDir, "byDataset2", filename), delim = ";")
#     }
#   }
# }
# 
# filelist <- list.files("data/raw_data/byDataset2")
# all2DoubtData <- lapply(filelist, function(x) 
#   read_delim(file.path("data", "raw_data/byDataset2", x), 
#              delim = ";", 
#              col_types = "cccTnnlccc")) %>%
#   set_names(sub(".csv", "", filelist)) %>%
#   bind_rows(.id = "mrgid") %>%
#   mutate(mrgid = sub("region", "", mrgid))
# 
# doubt_datasetids <- all2DoubtData %>% distinct(datasetid) %>% 
#   mutate(datasetid = sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', "", datasetid, fixed = T))
# 
# write_delim(all2DoubtData, file.path(dataDir, "all2DoubtData.csv"), delim = ";")
# 
# doubt_species <- all2DoubtData %>% distinct(scientificnameaccepted, .keep_all = TRUE) %>% select(scientificnameaccepted, phylum, datasetid) #  4966 species
# all2DoubtData %>% distinct(decimallatitude, decimallongitude) %>% dim() # 124843 localities
# 
# write_delim(doubt_species, file.path(dataDir, "doubt_species.csv"), delim = ";")

# These we are certain of not containing phytoplankton
notOKdatasets <- c(787, 4412, 5759, 2756, 4687)

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
    data <- read_csv(downloadURL, guess_max = 100000) 
    filename = paste0("region", roi$mrgid[ii], "_datasetid", datasetid,  ".csv")
    if(nrow(data) != 0){
      write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ";")
    }
  }
}

# Extra: These datasets fall outside the marine regions!!!! Just..
# See https://www.emodnet-biology.eu/portal/index.php?dasid=5449
syltdatasetids <- c(5449, 5486:5511) 

for(jj in 1:length(syltdatasetids)){
  datasetid <- syltdatasetids[jj]
  print(paste("downloading data for dataset nr: ", datasetid))
  downloadURL <- paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&viewParams=where%3Adatasetid+IN+%28", datasetid, "%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  data <- read_csv(downloadURL, guess_max = 100000) 
  filename = paste0("Sylt25231_", "datasetid", datasetid,  ".csv")
  if(nrow(data) != 0){
    write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ";")
  }
}



filelist <- list.files("data/raw_data/byDataset")
all2Data <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data/byDataset", x), 
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

write_delim(all2Data, file.path(dataDir, "all2Data.csv"), delim = ";")

all2Data %>% distinct(scientificnameaccepted) %>% dim() #  4805
all2Data %>% distinct(decimallatitude, decimallongitude) %>% dim() # 94329

