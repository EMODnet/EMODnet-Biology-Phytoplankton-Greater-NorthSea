# Create background map from Rworldxtra
require(rworldxtra)
require(tidyverse)
data("countriesHigh") 

# Transform the coordinates of the Rworldxtra map to our preferred code (32631)
bgmap <- countriesHigh %>%
  sf::st_as_sf() %>%
  sf::st_transform(32631)

# Complete zeroes function for species:
completeZeros_sp <- function(df, species, year){
  selectedDatasets <- df %>% 
    ungroup() %>%
    dplyr::filter(scientificName ==  species) %>%
    distinct(abbr) %>% unlist() %>% unname()
  df %>%
    dplyr::filter(date_year %in% year) %>%
    dplyr::filter(abbr %in% selectedDatasets) %>%
    group_by(abbr, date_year) %>%
    tidyr::complete(nesting(aphiaID, scientificName),         # these will be completed, with their occurrence
                    nesting(date, xUTM, yUTM, season),   # Combinations of these parameters are to be found
                    fill = list(occurs = 0)) %>% 
    ungroup() %>%
    unite(date_xUTM_yUTM, date, xUTM, yUTM, remove = FALSE) %>%
    filter(scientificName == species) %>%
    ungroup()
}

# Complete zeroes function for genus:
completeZeros_gen <- function(df, gen, year){
  selectedDatasets <- df %>% 
    ungroup() %>%
    dplyr::filter(genus ==  gen) %>%
    distinct(abbr) %>% unlist() %>% unname()
  df %>%
    dplyr::filter(date_year %in% year) %>%
    dplyr::filter(abbr %in% selectedDatasets) %>%
    group_by(abbr, date_year) %>%
    tidyr::complete(nesting(genus),         # these will be completed, with their occurrence
                    nesting(date, xUTM, yUTM, season),   # Combinations of these parameters are to be found
                    fill = list(occurs = 0)) %>% 
    ungroup() %>%
    unite(date_xUTM_yUTM, date, xUTM, yUTM, remove = FALSE) %>%
    filter(genus == gen) 
}

# Function returns a named list containing the grid numbers corresponding to the 
# coordinates of the input, as well as the parameters of the transformation that 
# will be needed for the back-transformation.
co2gr<-function(lon,lat,fdx,fdy){
  xgrid <- floor(lon/fdx)
  ygrid <- floor(lat/fdy)
  mnx <- min(xgrid)
  mny <- min(ygrid)
  xgrid <- xgrid-mnx+1
  ygrid <- ygrid-mny+1
  xgm <- max(xgrid)
  ygm <- max(ygrid)
  middleXgrid <- (xgrid + mnx - 1)*fdx + (fdx/2)  # Hier bereken ik het middelpunt, deze formule komt uit gr2co (zie hieronder)
  middleYgrid <- (ygrid + mny - 1)*fdy + (fdy/2)
  gridnr <- (ygrid-1)*xgm+xgrid
  return(data.frame(gridnr, middleXgrid, middleYgrid))
}

# Create data for time series plot including effort
time_effort <- function(df) {
  df %>% ungroup() %>%
    group_by(abbr, date_year, season) %>%
    summarize(effort_per_season = n(), positives = sum(occurs == 1)) %>%
    mutate(rel_abun = positives/effort_per_season) %>% ungroup() %>%
    mutate(season = factor(season, levels = rev(c("autumn", "summer", "spring", "winter")))) 
}


# Create dataset for effort plot
effort_function <- function(df, tax_level){
  df %>% ungroup() %>%
    group_by(gridnr, middleXgrid, middleYgrid) %>%  # alle bewerkingen per grid cell en aphiaID
    summarise(effort = n_distinct(date_xUTM_yUTM),
              effort_n = n(),
              pres_abse = mean(occurs)) %>%
    ungroup()
}

effort_season <- function(df){
  df %>% ungroup() %>%
    group_by(gridnr, season, middleXgrid, middleYgrid) %>%  # alle bewerkingen per grid cell en aphiaID
    summarise(effort = n_distinct(date_xUTM_yUTM),
              effort_n = n(),
              pres_abse = mean(occurs)) %>%
    ungroup() %>%
    mutate(season = factor(season, levels = rev(c("autumn", "summer", "spring", "winter")))) 
}


# Plot 1: plot the occurrence per season / per year for each species including the effort
plot_ts_eff <- function(df, sp_gen, begin, end) {
  ggplot(df, aes(date_year, season)) +
    geom_point(aes(size = effort_per_season, color = rel_abun)) +
    scale_shape_manual(values = c(21)) +
    scale_size("Effort per season", range = c(0.25,3.5), 
               breaks = c(0,1,10,50,100,200), labels = c(0,1,10,50,100,200), limits = c(0,200)) +
    scale_colour_continuous("Relative abundance", type = "viridis") +
    scale_x_continuous(limits = c(begin, end)) +
    facet_grid(abbr ~ .) +
    theme(strip.text.y = element_text(angle = 0),
          legend.position = "bottom") +
    labs(subtitle = sp_gen, x = "Year", y = "Season")
}


# Plot 1.5: plot the occurrence over season for each species including the effort
plot_season_eff <- function(df, sp_gen, begin, end) {

  ggplot(df, aes(season, rel_abun)) +
    geom_boxplot() +
    scale_size("Effort per season", range = c(0.25,3.5), 
               breaks = c(0,1,10,50,100,200), labels = c(0,1,10,50,100,200), limits = c(0,200)) +
    theme(strip.text.y = element_text(angle = 0),
          legend.position = "bottom") +
    labs(subtitle = sp_gen, x = "Season", y = "relative abun")
}


# Plot 2a: plot the presence/absence map using ggplot, geom_raster and sf
plot_mean_abun <- function(df, pres_abse, LON, LAT, speciesName, binx, biny){
  ggplot(df, aes(x = LON, y = LAT)) +
    stat_summary_2d(fun = mean, aes(z = pres_abse), binwidth = c(binx,biny)) +
    scale_fill_gradientn("Relative abundance", colours = (viridis::viridis(5)), 
                         breaks = c(0,0.25,0.5,0.75,1), labels = c(0,0.25,0.5,0.75,1), limits = c(0,1)) +
    ggtitle(speciesName) + 
    geom_sf(data = bgmap, aes(x = LON, y = LAT), fill = "darkgrey") +
    theme(panel.background = element_rect(fill = "lightgrey"),
          panel.grid = element_line(color = "black")) +
    labs(x = "Longitude", y = "Latitude") +
    coord_sf(xlim = c(150000,900000), ylim = c(5650000,6250000)) 
}

# Plot 2b: the presence/absence map (points on grid raster) including effort (as alpha)
plot_mean_point <- function(df, pres_abse, Alpha, long, lat, speciesName){
  ggplot(data = df) +
    geom_point(shape = 21, color = "black", aes_string(x = long, y = lat, fill = pres_abse, size = 1.5, alpha = Alpha), show.legend = TRUE) +
    scale_fill_continuous("Relative abundance", type = "viridis", limits = c(0,1)) +
    scale_alpha_continuous("Events/grid", range = c(0,1),
                breaks = c(1,5,10,50,100,500), labels = c(1,5,10,50,100,500), limits = c(1,500)) +
    scale_size(guide = "none") +
    guides(alpha = guide_legend(override.aes = list(size = 6), order = 1)) +
    labs(title = speciesName, x = "Longitude", y = "Latitude") +    
    geom_sf(data = bgmap, fill = "darkgrey")  +
    theme(panel.background = element_rect(fill = "lightgrey"),
          panel.grid = element_line(color = "black")) +
    coord_sf(xlim = c(150000,900000), ylim = c(5650000,6250000)) 
}

# Plot 2c: the presence/absence map (points on grid raster) including effort (as size)
plot_abun_point <- function(df, pres_abse, Size, long, lat, speciesName){
  ggplot(data = df) +
    geom_point(aes_string(x = long, y = lat, colour = pres_abse, size = Size), show.legend = TRUE) +
    scale_colour_continuous("Relative abundance", type = "viridis", limits = c(0,1)) +
    scale_size_continuous("Events/grid", range = c(0.5, 3.5),
                          breaks = c(1,5,10,50,100,500), labels = c(1,5,10,50,100,500), limits = c(1,500)) +
    guides(size = guide_legend(order = 1)) +
    #guides(colour = guide_legend(override.aes = list(breaks = c(0.0,0.25,0.5,0.75,1.0)))) +
    labs(title = speciesName, x = "Longitude", y = "Latitude") + 
    geom_sf(data = bgmap, fill = "darkgrey")  +
    theme(panel.background = element_rect(fill = "lightgrey"),
          panel.grid = element_line(color = "black")) +
    coord_sf(xlim = c(150000,900000), ylim = c(5650000,6250000)) 
}

# Plot 2d: the presence/absence map (points on grid raster) including effort (as size)
plot_abun_point_season <- function(df, pres_abse, Size, long, lat, speciesName){
  ggplot(data = df) +
    geom_point(aes_string(x = long, y = lat, colour = pres_abse, size = Size), show.legend = TRUE) +
    scale_colour_continuous("Relative abundance", type = "viridis", limits = c(0,1)) +
    scale_size_continuous("Events/grid", range = c(0.5, 3.5),
                          breaks = c(1,5,10,50,100,500), labels = c(1,5,10,50,100,500), limits = c(1,500)) +
    labs(title = speciesName, x = "Longitude", y = "Latitude") + 
    facet_wrap(~season, nrow = 2) +
    geom_sf(data = bgmap, fill = "darkgrey")  +
    theme(panel.background = element_rect(fill = "lightgrey"),
          panel.grid = element_line(color = "black", size = 0.1),
          legend.position = "bottom") +
    coord_sf(xlim = c(150000,900000), ylim = c(5650000,6250000))
}
