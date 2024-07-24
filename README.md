# gridPresence

## Transform counts to presence

The gridPresence script transform data counts to presence for a vectorial layer by intersecting both layers. 
If any of the count features that intersect with the presence features are greater than zero, presence feature will change to 1, otherwise it will remain as 0. 

In the script folder it is provided a script ([CountsSimulationAndTransformation](https://github.com/robinilla/gridPresence/blob/main/script/CountsSimulationAndTransformation.R)) which simulates count data and transforms that count data into only presence by using the gridPresence function. For running the script it could be downloaded the EEA 10 x 10 km grid ([available here](https://www.eea.europa.eu/en/datahub/datahubitem-view/3c362237-daa4-45e2-8c16-aaadfb1a003b)), and a 5 x 5 km grid can be generated, as in the example. Nonetheless, any other vector layer can be used instead of the proposed grids.


The below image summarise how the function works. 
![Only presence transformation](https://github.com/robinilla/gridPresence/blob/main/TransformationToOnlyPresence.png)
