# EMODnet Biology phytoplankton of the Greater North Sea

## Introduction

The project aims to produce comprehensive data product of the occurence and absence of (phyto)plankton species. As a basis, data from EMODnet Biology are used. The selection of relevant datasets is optimized in order to find all planktonic species, and exclude all species that are not planktonic. The occurences from EMODnet Biology were complemenented with absence data assuming fixed species lists within each dataset and year. The products are presented as maps of the distribution of the 100 most common species of (phyto)plankton in the Greater North Sea. 

This product then is also used for interpolated maps, using the DIVA software. 


## Geographical coverage

The aim is to cover the Greater North Sea. Subareas from the eez-iho layer in marineregions.org were selected as in the map below. Kattegat and Skagerrak were excluded for the moment, but could be added in a later stage. 

![Map of regions](data/derived_data/regionsOfInterest.png)

## Temporal coverage

## Directory structure

```
{{directory_name}}/
├── analysis
├── data/
│   ├── derived_data/
│   └── raw_data/
├── docs/
├── product/
└── scripts/
```

* **analysis** - Markdown or Jupyter notebooks
* **data** - Raw and derived data
* **docs** - Rendered reports
* **product** - Output product files
* **scripts** - Reusable code

## Data

Raw data were downloaded from EMODnet Biology using WFS requests. This was done in two steps. 

1. Per subregion, all observations of species with the trait "phytoplankton" or "Phytoplankton" were extracted. 



```
{{data_wfs_request}}
```

## Analysis

...

## Citation

Please cite this product as:
*{{citation}}*