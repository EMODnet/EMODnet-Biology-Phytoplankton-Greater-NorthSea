
require(leaflet)
require(tidyverse)
require(sf)

# Geographic search
# 
# marineregions ids can be used.
# They live in the layer MarineRegions:eez_iho
# intersection eez and iho regions
# 
# View

leaflet() %>% addTiles() %>%
  addWMSTiles(
    baseUrl = "http://geo.vliz.be/geoserver/wms?",
    layers = "MarineRegions:eez_iho",
    options = WMSTileOptions(format = "image/png", transparent = TRUE),
    attribution = "MarineRegions.org"
  )

# have a look in the layer

layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&outputFormat=application/json"
# download layer as spatial sf object
regions <- sf::st_read(layerurl)
st_crs()
coi <- c("Ireland", "United Kingdom", "Norway", "Sweden", "Denmark",
         "Germany", "Netherlands", "Belgium", "France")
roi <- regions %>% sf::st_drop_geometry() %>% 
  filter(country %in% coi) %>% 
  filter(grepl("North Sea", iho_sea) |
           grepl("Celtic", iho_sea) |
           grepl("Channel", iho_sea) |
           grepl("Scotland", iho_sea) |
           (grepl("Atlantic", iho_sea) & grepl("United Kingdom", country)) |
         (grepl("Atlantic", iho_sea) & grepl("Ireland", country))
  ) %>%
  # filter(!grepl("Arctic", marregion)) %>%
  # filter(!grepl("Atlantic", marregion)) %>%
  # filter(!grepl("Barentsz", marregion)) %>%
  # filter(!grepl("Baltic", marregion)) %>%
  # filter(!grepl("Norwegian Sea", marregion) | country == "United Kingdom") %>%
  # filter(!grepl("Greenland", marregion)) %>%
  distinct(mrgid, marregion)

write_delim(roi, "data/regions.csv", delim = ";")

regions %>% filter(mrgid %in% roi$mrgid) %>%
  ggplot() +
  geom_sf() +
  geom_sf_label(aes(label = mrgid))
