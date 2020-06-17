# EMODnet Biology phytoplankton of the Greater North Sea

The project aims to produce comprehensive data product of the occurence and absence of (phyto)plankton species. As a basis, data from EMODnet Biology are used. The selection of relevant datasets is optimized in order to find all planktonic species, and exclude all species that are not planktonic. The occurences from EMODnet Biology were complemenented with absence data assuming fixed species lists within each dataset and year. The products are presented as maps of the distribution of the 100 most common species of (phyto)plankton in the Greater North Sea. 

This product then is also used for interpolated maps, using the DIVA software. 



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

Raw data can be downloaded from EMODnet Biology using the following WFS request:

```
{{data_wfs_request}}
```

## Analysis

...

## Citation

Please cite this product as:
*{{citation}}*