README

The scripts are divided into several scripts to make it applicable 
to any dataset, location or time. These are the scripts present:

1.  .... (Willem, this is the one you are working on)
    This script loads the phytoplankton data from OBIS using a set marine region

2.  WP4_phy_2_NorthSea_fix.Rmd
    This script is different for each location. Here the dataset is prepared to 
    fit with our standards. Because different datasets have different standards,
    this script will also change if you go to another location.

3.  WP4_phy_3_final_prod.Rmd
    This script uses the data from the previous script to create two final 
    products. One is a phytoplankton datasets up to species level, the other
    a phytoplankton dataset up to genus level. These two datasets are then used
    to create the plots and add the absences (zeroes).

4a. WP4_phy_4a_plotting_phytoplankton + 4b. WP4_phy_4b_plotting_phytoplankton_gen
    These two scripts work with the dataset that was created by 
    WP4_phy_3_final_prod.Rmd. Here we make the figures and maps.
    These two scripts make use of functions that are stored in 
    WP4_phy_functions_needed.Rmd

