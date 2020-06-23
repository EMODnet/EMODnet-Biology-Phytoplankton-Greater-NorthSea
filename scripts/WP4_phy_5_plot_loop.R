# R script to call the R-markdown file that creates the pdf

# Load packages
require(knitr)
require(sf)
require(rmarkdown)
require(rworldxtra)
require(tidyverse)

# Working directory
dataDir <- "data/derived_data/"

# #######################################################################################################################
# FOR SPECIES
# Load phy data set from working directory
load(file.path(dataDir, "phy_sp.Rdata"))

orderedSpeciesList <- phy_sp %>% ungroup() %>%
  group_by(scientificnameaccepted) %>%
  summarise(n = n()) %>% arrange(-n) %>% head(100) %>%  unlist() %>% unname()
# plot(log10(orderedSpeciesList$n))
commonSpecies <- phy_sp[phy_sp$scientificnameaccepted %in% orderedSpeciesList,]

# function to render template with adjusted parameters.
render_report = function(targetSpecies, begin, end, gridX, gridY) {
  rmarkdown::render(
    "scripts/WP4_phy_4a_zeroes_sp.Rmd", params = list(
      targetSpecies = targetSpecies,
      begin = begin,
      end = end,
      gridX = gridX,
      gridY = gridY
    ),
    output_file = paste0(targetSpecies, "-", begin, "-", end, ".pdf"),
    output_dir = "product/reports"
  )
}

for (ii in 1:length(unique(commonSpecies$scientificnameaccepted))){ #length(unique(phy$scientificName))
  
  targetSpecies <- unique(commonSpecies$scientificnameaccepted)[ii]    # Species to work with
  begin = 1995                                       # Range of years for plots
  end = 2020                                       
  gridX <- 35000                                     # Size of gridcells (x)
  gridY <- 35000                                     # Size of gridcells (y)
  
  phy_c <- commonSpecies %>%
    filter(year %in% begin:end) %>%
    filter(scientificnameaccepted == targetSpecies) %>%
    dplyr::select(occurrence)
  
  if(length(phy_c$occurrence) > 0){
    
    # What Rmarkdown to use and where to render
   render_report(
      targetSpecies = targetSpecies,
      begin = begin,
      end = end,
      gridX = gridX,
      gridY = gridY
    )
   }  else next()   
  
}

# Clear workspace
rm(phy_c)
rm(phy_sp)

# #######################################################################################################################
# FOR GENERA
# Load phy data set from working directory
load(file.path(dataDir, "phy_gen.Rdata"))

orderedGenusList <- phy_gen %>% ungroup() %>%
  group_by(genus) %>%
  summarise(n = n()) %>% arrange(-n) %>% head(100) %>%  unlist() %>% unname()
# plot(log10(orderedSpeciesList$n))
commonGenus <- phy_gen[phy_gen$genus %in% orderedGenusList,]

# function to render template with adjusted parameters.
render_report_g = function(targetGen, begin, end, gridX, gridY) {
  rmarkdown::render(
    "scripts/WP4_phy_4b_zeroes_gen.Rmd", params = list(
      targetGen = targetGen,
      begin = begin,
      end = end,
      gridX = gridX,
      gridY = gridY
    ),
    output_file = paste0(targetGen, "-", begin, "-", end, ".pdf"),
    output_dir = "product/reports"
  )
}

for (ii in 1:length(unique(commonGenus$genus))){ #length(unique(phy_gen$genus))
  
  targetGen <- unique(commonGenus$genus)[ii]    # Species to work with
  begin = 1995                                       # Range of years for plots
  end = 2020                                       
  gridX <- 35000                                     # Size of gridcells (x)
  gridY <- 35000                                     # Size of gridcells (y)
  
  phy_c_g <- commonGenus %>%
    filter(year %in% begin:end) %>%
    filter(genus == targetGen) %>%
    dplyr::select(occurrence)
  
  if(length(phy_c_g$occurrence) > 0){
    
    # What Rmarkdown to use and where to render
    render_report_g(
      targetGen = targetGen,
      begin = begin,
      end = end,
      gridX = gridX,
      gridY = gridY
    )
  }  else next()   
  
}