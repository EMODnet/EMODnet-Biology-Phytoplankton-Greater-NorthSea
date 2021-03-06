# EMODnet Biology phytoplankton of the Greater North Sea

## Introduction

The project aims to produce comprehensive data products of the occurrence and absence of (phyto)plankton species. As a basis, data from EMODnet Biology are used. The selection of relevant datasets is optimized in order to find all planktonic species, and exclude all species that are not planktonic. The occurrences from EMODnet Biology were complemented with absence data assuming fixed species lists within each dataset and year. The products are presented as maps of the distribution of the 100 most common species of (phyto)plankton in the Greater North Sea. 

This product then is also used for interpolated maps, using the DIVA software (Barth et al.,  [2014](https://dx.doi.org/10.5194/gmd-7-225-2014), [2020](https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=6588)) 

## Geographical coverage

The aim is to cover the Greater North Sea. Subareas from the layer intersect of the Exclusive Economic Zones and IHO sea areas in [marineregions.org](https://marineregions.org)  (Flanders Marine Institute, 2020) were selected as in the map below. Kattegat and Skagerrak were excluded for the moment, but could be added in a later stage. 

![Map of regions](data/derived_data/regionsOfInterest.png)

The regions were selected by manual procedure in QGIS from the GIS layer "MarineRegions:eez_iho" available via WFS via the EMODnet Biology geoserver. The selection was saved as GeoJSON in the project at "data/derived_data/simplified_greater_north_sea-selection_from_eez-iho_v4.geojson"

## Temporal coverage

All available data from 1995 to current (2020-05-31) were used in this product.

## Directory structure

```
EMODnet-Biology-Phytoplankton-Greater-NorthSea/
    ├── analysis
    ├── data/
    │   ├── derived_data/
    │   └── raw_data/
    ├── docs/
    ├── product/
    └── scripts/
```

* **analysis** - Markdown
* **data** - Raw and derived data
* **docs** - Rendered reports
* **product** - Output product files
* **scripts** - Reusable code

## Data series

Raw data were downloaded from EMODnet Biology using WFS requests. This was done in two steps. 

1. For each subregion, all observations of species with the trait "phytoplankton" or "Phytoplankton" were extracted. 

2. Because of uncertainties in extracting all phytoplankton species (due to absence of traits for example) all data was extracted for every dataset that occurred in step 1. Because datasets could also contain non-phytoplankton, within the datasets phyla were selected that contain phytoplankton species, after which a manual selection was performed to filter out non-phytoplankton species also belonging to these phyla (e.g. macroalgae).

The datasets included were:

| Dataset | EMODnet Biology link |
| ---------------------------- | ------------------------------------------------------------------ |
| Continuous Plankton Recorder (Phytoplankton) | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=785 |
| NODC World Ocean Database 2001: Plankton Data | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=1985 |
| REPHY: Network Monitoring phytoplankton | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=2451 |
| ICES Phytoplankton Community dataset | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=4424 |
| AMOREII: Advanced Modelling and Research on Eutrophication Linking Eutrophication and Biological Resources (AMOREII) | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5977 |
| AMOREIII: Combined Effect of Changing Hydroclimate and Human Activity on Coastal Ecosystem Health (AMOREIII) | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5978 |
| Phytoplankton Monitoring at the ChÃ¢teau du Taureau Station in the Western English Channel, from 2009 to 2011 | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5998 |
| Long-term Monitoring of the Phytoplankton at the SOMLIT-Astan Station in the Western English Channel from 2000 to Present | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5971 |
| LifeWatch observatory data: phytoplankton observations by imaging flow cytometry (FlowCam) in the Belgian Part of the North Sea | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=4688 |
| Biogeographic data from BODC - British Oceanographic Data Centre | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=1172 |
| DASSH: The UK Archive for Marine Species and Habitats Data | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5247 |
| L4 Plankton Monitoring Programme | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=1495 |
| Phytoplankton data for Danish marine monitoring (ODAM) from 1988 - 2016 | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5664 |
| Dutch long term monitoring of phytoplankton in the Dutch Continental Economical Zone of the North Sea | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5758 |
| PANGAEA - Data from various sources | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=2722 |
| PANGAEA - Data from Ocean margin exchange project (OMEX I) | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=2768 |
| Macrobenthos and Phytoplankton monitoring in the Belgian coastal zone in the context of the EU Water Framework Directive (WFD) | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5945 |
| IPMS-PHAEO: Dynamics of coastal eutrophicated ecosystems | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5951 |
| AMORE: Advanced Modelling & Research on Eutrophication & the Structure of Coastal Planktonic Food-webs: Mechanisms & Modelling (AMORE) | https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=5976 |



WFS requests are described in the script "requestData.R"

## Data product

### Addition of zero values

Within each combination of dataset and year, it was assumed that the potentially occurring species did not vary. For example, if a species was found within a dataset in March at a certain location, it was assumed that this species was always searched for. If in the same dataset, but at another location or at another time, this same species was not reported, it was assumed to be absent. This approach allows for variation in e.g. counting strategy or analyzing lab between years, where perhaps certain species were not looked for in a certain period. 

For the 100 most abundant species this analysis was done, after which maps were produced with the probability of occurrence of a certain species according to the fraction of presences divided by the total sampling effort (number of samples taken). The analyses was done an a course grid and a finer grid, for each season (winter, spring, summer, autumn)

## More information

### References

Barth, A., Beckers, J.-M., Troupin, C., Alvera-Azcárate, A., and Vandenbulcke, L.(2014): divand-1.0: *n*-dimensional variational data analysis for ocean observations, Geosci. Model Dev.,  7, 225–241, https://doi.org/10.5194/gmd-7-225-2014.    

Barth, A., Stolte, W., Troupin, C. & van der Heijden, L. (2020). Probability maps for different phytoplankton species in the North Sea. Integrated data products created under the European Marine Observation Data Network (EMODnet) Biology project (EASME/EMFF/2017/1.3.1.2/02/SI2.789013), funded by the by the European Union under Regulation (EU) No 508/2014 of the European Parliament and of the Council of 15 May 2014 on the European Maritime and Fisheries Fund. Available online at https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=6588

Flanders Marine Institute (2020). The intersect of the Exclusive Economic Zones and IHO sea areas, version 4. Available online at https://www.marineregions.org/.https://doi.org/10.14284/402

### Code and methodology

All code is available on github at: https://github.com/EMODnet/EMODnet-Biology-Phytoplankton-Greater-NorthSea

### Citation and download link

Please cite this product as:

Stolte, W. & van der Heijden, L. (2020). Presence/Absence maps  of phytoplankton in the Greater North Sea. Integrated data products  created under the European Marine Observation Data Network (EMODnet)  Biology project (EASME/EMFF/2017/1.3.1.2/02/SI2.789013), funded by the  by the European Union under Regulation (EU) No 508/2014 of the European  Parliament and of the Council of 15 May 2014 on the European Maritime  and Fisheries Fund

Available to download in:

https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=6587

### Authors

[Willem Stolte](https://www.emodnet-biology.eu/data-catalog?module=person&persid=29132) and [Luuk van der Heijden](https://www.emodnet-biology.eu/data-catalog?module=person&persid=39499).