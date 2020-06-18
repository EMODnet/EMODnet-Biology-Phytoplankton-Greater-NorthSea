
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

# coi <- c("Ireland", "United Kingdom", "Norway", "Sweden", "Denmark",
#          "Germany", "Netherlands", "Belgium", "France")
# roi <- regions %>% sf::st_drop_geometry() %>% 
#   filter(country %in% coi) %>% 
#   filter(grepl("North Sea", iho_sea) |
#            grepl("Celtic", iho_sea) |
#            grepl("Channel", iho_sea) |
#            grepl("Scotland", iho_sea) |
#            (grepl("Atlantic", iho_sea) & grepl("United Kingdom", country)) |
#          (grepl("Atlantic", iho_sea) & grepl("Ireland", country))
#   ) %>%
#   distinct(mrgid, marregion)
#   
#   # This was a nice try, but not complete. abandonned


# new try: manual selection of areas in QGIS. Saved as separate file

list.files("data/derived_data")
roi <- st_read("data/derived_data/greater_north_sea-selection_from_eez-iho-union-v2.geojson")
roi %>% select(mrgid) %>% plot()

roi %>% st_drop_geometry() %>%
  write_delim("data/derived_data/regions.csv", delim = ";")

regions %>% filter(mrgid %in% roi$mrgid) %>%
  ggplot() +
  geom_sf(fill = "blue") +
  geom_sf(data = regions, fill = "transparent", color = "white") +
  geom_sf_text(aes(label = mrgid), size = 2.5) +
  coord_sf(st_bbox(roi)[c(1,3)], st_bbox(roi)[c(2,4)], expand = T)
