README

The scripts are divided into several scripts to make it applicable 
to any dataset, location or time. These are the scripts present:

1.  a) create-regionlist.R
    This script create the regions in which the phytoplankton is collected and the distribution will be presented.
    b) requestData.R
    This script uses the wfs query to download the data from the vliz geo-server. 

2.  WP4_phy_2_NorthSea_fix.Rmd
    This script is different for each location. Here the dataset is prepared to fit with our standards. Because different datasets have different standards, this script is region-specific.

3.  WP4_phy_3_final_prod.Rmd
    This script uses the data from the previous script to create two final products. One is a phytoplankton datasets up to species level, the other a phytoplankton dataset up to genus level. These two datasets are then used to create the plots and add the absences (zeroes) in WP4_phy_6_create_csv.R

4a. WP4_phy_4a_zeroes_sp + 
4b. WP4_phy_4b_zeroes_gen
    These two scripts work with the datasets that were created by WP4_phy_3_final_prod.Rmd. Here we complete the zeroes (absences of the fill), calculate the effort and make the figures and maps. deprecated 

5.  WP4_phy_5_plot_loop 
    This script uses the file created in WP4_phy_3 (named phy_sp.Rdata and phy_gen.Rdata) and loops these through the rmd WP4_phy_4a and WP4_phy_4b. This creates products for the 100 most common species and genera. deprecated
    
6.  WP4_phy_6_create_csv.R creates csv per species of data completed with zero abundances, which are input in the plotRaster.R script

7. plotRasterR produces raster maps as TIFF and PNG for the 100 most abundant species and the 100 most abundant genera. 



