# R script to call the R-markdown file that creates the pdf
packages<-function(x){
  x<-as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}
# Load packages
packages(knitr)
packages(sf)
packages(rmarkdown)
packages(rworldxtra)
packages(tidyverse)
packages(shiny)
packages(rgeos)
select <- dplyr::select

# Working directory
dataDir <- "data/derived_data/"

source("scripts/WP4_phy_functions_needed.R")

# #######################################################################################################################
# FOR SPECIES
# Load phy data set from working directory
load(file.path(dataDir, "phy_sp.Rdata"))

orderedSpeciesList <- phy_sp %>% ungroup() %>%
  group_by(scientificnameaccepted) %>%
  summarise(n = n()) %>% arrange(-n) %>% head(100) %>%  unlist() %>% unname()
# plot(log10(orderedSpeciesList$n))
commonSpecies <- phy_sp[phy_sp$scientificnameaccepted %in% orderedSpeciesList,]

for (ii in 1:length(unique(commonSpecies$scientificnameaccepted))){ #length(unique(phy$scientificName))
  
  targetSpecies <- unique(commonSpecies$scientificnameaccepted)[ii]    # Species to work with
  begin = 1995                                       # Range of years for plots
  end = 2020                                       

  if(length(commonSpecies$occurrence) > 0){
  
    # Create zeroes:
    selectedDatasets <- commonSpecies %>% 
      ungroup() %>%
      dplyr::filter(scientificnameaccepted == targetSpecies) %>%
      distinct(abbr) %>% unlist() %>% unname()
    
    phy_c <- commonSpecies  %>%
      dplyr::filter(year %in% begin:end) %>%
      dplyr::filter(abbr %in% selectedDatasets) %>%
      group_by(abbr, year) %>%
      tidyr::complete(nesting(aphiaid, scientificnameaccepted),         # these will be completed, with their occurrence
                      nesting(date, decimallongitude, decimallatitude, season),   # Combinations of these parameters are to be found
                      fill = list(occurrence = 0)) %>% 
      ungroup() %>%
      unite(date_decimallongitude_decimallatitude, date, decimallongitude, decimallatitude, remove = FALSE) %>%
      filter(scientificnameaccepted == targetSpecies) %>%
      ungroup()
    
    # This df contains duplicates from different datasets that have the same location and time, which seems unlikely
    dup_zero <- phy_c %>% 
      arrange(aphiaid, date, decimallongitude, decimallatitude, occurrence, season) %>%
      select(-datasetID) %>%
      duplicated %>% which
    # Create the df with duplicates
    dbs_zero <- phy_c %>% 
      arrange(aphiaid, date, decimallongitude, decimallatitude, occurrence, season) %>%
      ungroup() %>%
      slice(sort(c(dup_zero, dup_zero-1))) 
    
    # Write this out in a csv. To check for later purposes.
    #duplDir <- "../product/dupl/"
    
    if(length(dbs_zero$occurrence) > 0){
      
      write.csv(dbs_zero, 
                paste0("product/dupl/Dupl_", 
                       targetSpecies, " ", 
                       begin, "-", end, ".csv"), 
                row.names = FALSE)
    }   
    
    # Here we remove the duplicates that have the same location and time in different datasets 
    phy_c <- phy_c %>%
      distinct(aphiaid, scientificnameaccepted, date, decimallongitude, decimallatitude, year, season, occurrence, .keep_all = TRUE) %>%
      select(datasetID, abbr, year, aphiaid, scientificnameaccepted,date, decimallongitude, decimallatitude, season, eventid, mrgid, month, occurrence)
    
    # Create a csv file for Leuven to interpolate
    #csv_Dir <- "product/csv_files/"
    
    write.csv(phy_c, paste0("product/csv_files/", targetSpecies, "-",  begin, "-", end, ".csv"), row.names = FALSE)
    
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

for (ii in 1:length(unique(commonGenus$genus))){ #length(unique(phy_gen$genus))
  
  targetGen <- unique(commonGenus$genus)[ii]    # Species to work with
  begin = 1995                                       # Range of years for plots
  end = 2020                                       

  if(length(commonGenus$occurrence) > 0){
    
    # Complete zeroes function for genus:
    selectedDatasets <- commonGenus %>% 
        ungroup() %>%
        dplyr::filter(genus ==  targetGen) %>%
        distinct(abbr) %>% unlist() %>% unname()
    
    phy_c_g <- commonGenus %>%
        dplyr::filter(year %in% begin:end) %>%
        dplyr::filter(abbr %in% selectedDatasets) %>%
        group_by(abbr, year) %>%
        tidyr::complete(nesting(genus),         # these will be completed, with their occurrence
                        nesting(date, decimallongitude, decimallatitude, season),   # Combinations of these parameters are to be found
                        fill = list(occurrence = 0)) %>% 
        ungroup() %>%
        unite(date_decimallongitude_decimallatitude, date, decimallongitude, decimallatitude, remove = FALSE) %>%
        filter(genus == targetGen) 
    
    
    # This df contains duplicates from different datasets that have the same location and time, which seems unlikely
    dup_zero_g <- phy_c_g %>% 
      arrange(genus, date, decimallongitude, decimallatitude, occurrence, season) %>%
      select(-datasetID) %>%
      duplicated %>% which
    
    # Create the df with duplicates
    dbs_zero_g <- phy_c_g %>% 
      arrange(genus, date, decimallongitude, decimallatitude, occurrence, season) %>%
      ungroup() %>%
      slice(sort(c(dup_zero_g, dup_zero_g-1))) 
    
    # Write this out in a csv. To check for later purposes.
    #duplDir <- "../product/dupl/"
    
    if(length(dbs_zero_g$occurrence) > 0){
      
      write.csv(dbs_zero_g, 
                paste0("product/dupl/Dupl_", 
                       params$targetGen, " ", 
                       params$begin, "-", params$end, ".csv"), 
                row.names = FALSE)
    }   
    
    # Here we remove the duplicates that have the same location and time in different datasets 
    phy_c_g <- phy_c_g %>%
      distinct(genus, date, decimallongitude, decimallatitude, year, season, occurrence, .keep_all = TRUE) %>%
      select(datasetID, abbr, year, aphiaid, scientificnameaccepted,date, decimallongitude, decimallatitude, season, eventid, mrgid, month, occurrence)
    
    write.csv(phy_c_g, paste0("product/csv_files/", targetGen, "-",  begin, "-", end, ".csv"), row.names = FALSE)
    
  }  else next()   
  
}
