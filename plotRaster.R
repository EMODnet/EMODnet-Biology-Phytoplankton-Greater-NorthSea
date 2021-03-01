
require(EMODnetBiologyMaps)
require(tidyverse)
dataDir <- "data/derived_data/"

fileList <- list.files("p:/emodnet_biology/dataproducts/phytoplankton/obisdata/csv-files/", full.names = T)

for(ii in c(1:length(fileList))){
  
  Phytoplankton_occurence <- read_delim(fileList[ii],
                                        delim = ",")
  # rasterize data
  require(raster)
  proETRS <- CRS("EPSG:3035")
  proWG <- CRS("EPSG:4326")
  proUTM <- CRS("+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs")
  r<-raster(ext=extent(-16,9,46,66),ncol=75,nrow=140,crs=proWG,vals=0)
  pr3 <- projectExtent(r, proETRS)
  rt <- projectRaster(r, pr3)
  
  for(season in c('winter', 'spring', 'summer', 'autumn')){
    
    seasonalData <- Phytoplankton_occurence %>% filter(season == season)
   
    coordinates(seasonalData)<- ~xUTM+yUTM
    projection(seasonalData)<-proUTM
    seasonalData <- sp::spTransform(seasonalData, proETRS)
    r1<-rasterize(seasonalData,rt,field="occurs",fun=mean)
    
    ec<-emodnet_colors()
    spAphId <- ifelse(is.null(Phytoplankton_occurence$genus), Phytoplankton_occurence$scientificName, Phytoplankton_occurence$genus)
    plot_grid <- emodnet_map_plot(data=r1,title=paste("Phytoplankton_occurence", season),subtitle=paste0('AphiaID ', spAphId),
                                  zoom=TRUE,seaColor=ec$darkgrey,landColor=ec$lightgrey,legend="")
    
    filnam <- file.path("product", "grid_plots", paste(today(), gsub(" ", "-", spAphId), season, ".png", sep = "_"))
    
    emodnet_map_logo(plot_grid,path=filnam,width=120,height=160,dpi=300,units="mm",offset="+0+0")
  }
}


# # Export rasters as tif
# raster::writeRaster(
#   r1, 
#   file.path(
#     rasterDir, paste0(
#       sprintf("%04d",ss), "_",
#       spAphId, "_",
#       gsub(" ", "-", specname),
#       ".tif"
#     )
#   ),
#   overwrite=TRUE
# )
