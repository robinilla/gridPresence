# gridPresence

## Transform counts to presence

The gridPresence script transform data counts to presence for a vectorial layer by intersecting both layers. 
If any of the count features that intersect with the presence features are greater than zero, presence feature will change to 1, otherwise it will remain as 0. 

In the script folder it is provided a script ([CountsSimulationAndTransformation](https://github.com/robinilla/gridPresence/blob/main/script/CountsSimulationAndTransformation.R)) which simulates count data and transforms that count data into only presence by using the gridPresence function. For running the script it could be downloaded the EEA 10 x 10 km grid ([available here](https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b)), and a 5 x 5 km grid can be generated, as in the example. Nonetheless, any other vector layer can be used instead of the proposed grids.


The below image summarises how the function works. 
![Only presence transformation](https://github.com/robinilla/gridPresence/blob/main/TransformationToOnlyPresence.png)



## R script file

The R script example file is prepared for transforming three years counts to 5 x 5 km grid (line 20), as well as 10 x 10 km grid. The transformation of the 5 x 5 km grid to the 10 x 10 km grid can be found at line 23. The function used for transforming hunting yields data to presence-only (gridPresence) is also provided (lines 41-88). An example of how to run the function for more than a year and for both grid resolutions is given as well (lines 94-100). Both results are given and plotted (lines 104-123). The R script file has been written in R 4.3.3 computing language and utilized the packages tidyverse 2.0.024 and sf 1.0-1625.  



## References 
- R Core Team. R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria (2022).
- Wickham, H. et al. Welcome to the Tidyverse. J Open Source Softw 4, 1686 (2019).
- Pebesma, E. Simple Features for R: Standardized Support for Spatial Vector Data. R J 10, 439–446 (2018).
