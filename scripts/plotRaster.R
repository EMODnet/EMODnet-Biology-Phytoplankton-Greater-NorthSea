
require(EMODnetBiologyMaps)
require(tidyverse)
require(lubridate)
require(raster)
require(sp)

productDir <- "product"
csvDir <- file.path(productDir, "csv_files")
pngDir <- file.path(productDir, "grid_plots")
tiffDir <- file.path(productDir, "tiff")

# fileList <- list.files("p:/emodnet_biology/dataproducts/phytoplankton/GreaterNorthSea/product/csv_files/", full.names = T)
# taxonNames <- stringr::str_sub(list.files("p:/emodnet_biology/dataproducts/phytoplankton/GreaterNorthSea/product/csv_files/"), end = -15)
fileList <- list.files(csvDir, full.names = T)
taxonNames <- stringr::str_sub(list.files(csvDir), end = -15)

for(ii in c(1:length(fileList))){
  
  Phytoplankton_occurence <- read_delim(fileList[ii], delim = ",")
  # rasterize data
  proWG <- CRS("EPSG:4326")
  proUTM <- CRS("+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs")
  r1<-raster(ext=extent(-16,9,46,66),ncol=100,nrow=160,crs=proWG,vals=0)
  r2<-raster(ext=extent(-16,9,46,66),ncol=25,nrow=40,crs=proWG,vals=0)

  seasons <- c('winter', 'spring', 'summer', 'autumn')
  
  for(jj in c(1:length(seasons))){
    
    seasonalData <- Phytoplankton_occurence %>% dplyr::filter(season == seasons[jj])
    
    coordinates(seasonalData)<- ~xUTM+yUTM
    projection(seasonalData)<-proUTM # because data were saved in UTM. Could be changed
    seasonalData <- sp::spTransform(seasonalData, proWG)
    sp_r_highres<-rasterize(seasonalData,r1,field="occurrence",fun=mean)
    sp_r_lowres<-rasterize(seasonalData,r2,field="occurrence",fun=mean)
    
    #save tiffs
    
    ec<-emodnet_colors()
    spAphId <- taxonNames[ii]
    
    tifnam <- file.path("product", "tiff", paste(today(), gsub(" ", "-", spAphId), seasons[jj], ".tif", sep = "_"))
    tifnam_lowres <- file.path("product", "tiff", paste(today(), gsub(" ", "-", spAphId), seasons[jj], "_lowres.tif", sep = "_"))
    
    writeRaster(sp_r_highres, tifnam, options=c('TFW=YES'), overwrite = T)
    writeRaster(sp_r_lowres, tifnam_lowres, options=c('TFW=YES'), overwrite = T)
    
    plot_grid <- emodnet_map_plot(data=sp_r_highres,title=paste0(spAphId),subtitle=paste("probability of occurrence in", seasons[jj]),
                                  zoom=FALSE,seaColor=ec$darkgrey,landColor=ec$lightgrey,legend="",
                                  xlim = c(2351321, 4275244), ylim = c(2543530,4985495)) +
      scale_fill_viridis_c(limits = c(0,1))
    
    filnam <- file.path("product", "grid_plots", paste(today(), gsub(" ", "-", spAphId), seasons[jj], "highres.png", sep = "_"))
    
    emodnet_map_logo(plot_grid,path=filnam,width=120,height=160,dpi=300,units="mm",offset="+0+0")
    
    
    plot_grid_lowres <- emodnet_map_plot(data=sp_r_lowres,title=paste0(spAphId),subtitle=paste("probability of occurrence in", seasons[jj]),
                                         zoom=FALSE,seaColor=ec$darkgrey,landColor=ec$lightgrey,legend="",
                                         xlim = c(2351321, 4275244), ylim = c(2543530,4985495)) +
      scale_fill_viridis_c(limits = c(0,1))
    
    filnam_lowres <- file.path("product", "grid_plots", paste(today(), gsub(" ", "-", spAphId), seasons[jj], "_lowres.png", sep = "_"))
    
    emodnet_map_logo(plot_grid_lowres,path=filnam_lowres,width=120,height=160,dpi=300,units="mm",offset="+0+0")
    
  }
}

