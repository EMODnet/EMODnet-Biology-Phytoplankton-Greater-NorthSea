
require(tidyverse)

dataDir <- "data/derived_data"
allData <- read_delim(file.path(dataDir, "allData.csv"), delim = ";")

unique(allData$mrgid)

# download layer as spatial sf object
layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&outputFormat=application/json"
regions <- sf::st_read(layerurl)

regionN <- allData %>%
  group_by(mrgid) %>% summarize(n = n()) %>% ungroup() %>%
  mutate(mrgid = as.numeric(mrgid))

regions %>% right_join(regionN, by = c(mrgid = "mrgid")) %>%
  ggplot() +
  geom_sf(aes(fill = log10(n))) +
  geom_sf_text(aes(label = objectid_1)) +
  scale_fill_distiller(direction = 1)

#=== all2Data ==== dataset based ==========

dataDir <- "data/derived_data"
all2Data <- read_delim(file.path(dataDir, "all2Data.csv"), delim = ";")

unique(all2Data$mrgid)

# download layer as spatial sf object
layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&outputFormat=application/json"
regions <- sf::st_read(layerurl)

regionN <- all2Data %>%
  group_by(mrgid) %>% summarize(n = n()) %>% ungroup() %>%
  mutate(mrgid = as.numeric(mrgid))

regions %>% right_join(regionN, by = c(mrgid = "mrgid")) %>%
  ggplot() +
  geom_sf(aes(fill = log10(n))) +
  geom_sf_text(aes(label = objectid_1)) +
  scale_fill_distiller(direction = 1)
