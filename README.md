# gridPresence

## Transform counts to presence

The gridPresence script transforms data counts to presence for a vectorial layer by intersecting both layers. 
If any of the count features that intersect with the presence features are greater than zero, presence feature will change to 1, otherwise it will remain as 0. 

In the script folder it is provided a script ([CountsSimulationAndTransformation](https://github.com/robinilla/gridPresence/blob/main/script/CountsSimulationAndTransformation.R)) which transforms simulated count data into presence-only by using the gridPresence function. For running the script it could be downloaded the EEA 10 x 10 km grid ([available here](https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b)), and a 5 x 5 km grid can be generated, as in the example. Nonetheless, any other vector layer can be used instead of the proposed grids.


The below image summarises how the function works. 
![Only presence transformation](https://github.com/robinilla/gridPresence/blob/main/TransformationToOnlyPresence.png)

There is also provided the script that describes the process of the simulation of the data provided in the Geopackage as [polygon.layer](https://github.com/robinilla/gridPresence/blob/main/script/CreateRandomPolygonsInAExtent.R).

## R script files

- The CountSimulationAndTransformation R script example file is prepared for transforming three years counts to 5 x 5 km grid (line 24), as well as 10 x 10 km grid. The transformation of the 5 x 5 km grid to the 10 x 10 km grid can be found at line 28. The function used for transforming hunting yields data to presence-only (gridPresence) is also provided (lines 46-93). An example of how to run the function for more than a year and for both grid resolutions is given as well (lines 97-105). Both results are given and plotted (lines 109-128). The R script file has been written in R 4.3.3 computing language and utilized the packages tidyverse 2.0.0 and sf 1.0-16.

- Due to data confidentiality we could not provide real hunting yields to transform the information to presence we created the CreateRandomPolygonsInAExtent R script which provides the process to simulate count data in a spatial extent. We generated 2000 random polygons and three count surveys (lines 31-46). The count data followed a random Poisson distribution where the lambda parameter follows a random normal distribution (mean=50 and sd=10; lines 55-58). To simulate unkown presences, 25% of the polygons were randomly assigned a 0 value (lines 60-62). Finally, we exported the information as a vectorial layer in a Geopackage (lines 82-89).



## References 
- R Core Team. R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria (2022).
- Wickham, H. et al. Welcome to the Tidyverse. J Open Source Softw 4, 1686 (2019).
- Pebesma, E. Simple Features for R: Standardized Support for Spatial Vector Data. R J 10, 439–446 (2018).
- Hijmans, R. _terra: Spatial Data Analysis._ R package version 1.8-15, https://rspatial.github.io/terra/, [https://rspatial.org/](https://rspatial.org/) (2025).
- Hijmans, R., Phillips, S., Leathwick, J., Elith, J. _dismo: Species Distribution Modeling_. R package version 1.3-16,  [https://CRAN.R-project.org/package=dismo](https://CRAN.R-project.org/package=dismo) (2024).
- Turner, R. _deldir: Delaunay Triangulation and Dirichlet (Voronoi) Tessellation_. R package version 2.0-4, [https://CRAN.R-project.org/package=deldir](https://CRAN.R-project.org/package=deldir) (2024).


## Citation 
Illanas, S., Fernández-López, J., Vicente, J., Ruiz-Rodríguez, C., López-Padilla, S., Sebastián-Pardo, M., Preite, L., Gómez-Molina, A., Acevedo, P., Blanco-Aguiar, J.A. Presence-only data for wild ungulates and red fox in Spain based on hunting yields over a 10-year period. Sci Data 12, 236 (2025). [https://doi.org/10.1038/s41597-025-04574-z](https://doi.org/10.1038/s41597-025-04574-z)
