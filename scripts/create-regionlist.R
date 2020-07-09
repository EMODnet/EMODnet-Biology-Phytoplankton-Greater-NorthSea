#=======================================================================================
#
# Willem Stolte
# EMODnet Biologie
# 
# Last changes:
# 
# 2000-06-22
# 
# Marine region layer adapted to newest version
# 
# geographical area adapted to EEA greater North Sea and Celtic Seas
# Now also contains Skagerrak and large part of Kattegat
# Documented in script "create-regionlist.R"
#
#=======================================================================================


require(leaflet)
require(tidyverse)
require(sf)

# Geographic search
# 
# marineregions ids can be used.
# They live in the layer MarineRegions:eez_iho
# intersection eez and iho regions
# 
# View  (takes a whee while to load the layer with regions..)

# leaflet() %>% addTiles() %>%
#   addWMSTiles(
#     baseUrl = "http://geo.vliz.be/geoserver/wms?",
#     layers = "MarineRegions:eez_iho",
#     options = WMSTileOptions(format = "image/png", transparent = TRUE),
#     attribution = "MarineRegions.org"
#   )

# to look at the complete layer
# layerurl <- "http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=MarineRegions:eez_iho&outputFormat=application/json"
# # download layer as spatial sf object
# allRegions <- sf::st_read(layerurl)
# st_crs()

# Selection made by hand in QGIS, exported as json
list.files("data/derived_data")
roi <- st_read("data/derived_data/simplified_greater_north_sea-selection_from_eez-iho_v4.geojson")
roi %>% select(mrgid) %>% plot()

roi %>%
  ggplot() +
  geom_sf(fill = "blue", color = "white") +
  geom_sf_text(aes(label = mrgid), size = 2.5)
  # coord_sf(st_bbox(roi)[c(1,3)], st_bbox(roi)[c(2,4)], expand = T)


roi %>% st_drop_geometry() %>%
  write_delim("data/derived_data/regions.csv", delim = ";")

roi %>% st_simplify(dTolerance = 0) %>% st_write("data/derived_data/simplified_greater_north_sea-selection_from_eez-iho_v4.geojson")
