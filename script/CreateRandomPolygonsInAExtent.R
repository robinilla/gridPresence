## Institution: Institute for Game and Wildife Research
## Author: Sonia Illanas
## Date: 08/02/2024
## R version 4.3.3
## sf version: 1.0-16
## tidyverse version: 2.0.0
## dismo version: 1.3-16
## deldir version 2.0-4
## terra version 1.8-15


# devtools::install_version("sf", version = "1.0-16")
# devtools::install_version("tidyverse", version = "2.0.0")
# devtools::install_version("terra", version = "1.8-15")
# devtools::install_version("dismo", version = "1.3-16")
# devtools::install_version("deldir", version = "2.0-4")

library(sf)
library(dismo)
library(deldir)
library(terra)
library(tidyverse)
rm(list=ls())

# CREATE A RANDOM POLYGON LAYER INSIDE SPAIN

# 1. Read 5 x 5 km grid: downloaded from the EEA grid and masked with Spain
grid5km<-st_read("data_example.gpkg", "grid5km")

# 2. Create hunting estates (irregular polygons): from the extent of the grid 
sarea <- rast(nrows = 100, ncols = 100, ext(grid5km))

sarea<-raster(sarea)                    # convert SpatRaster object to a raster

pp <- randomPoints(sarea,               # introduce the raster: it must be a raster
                                        # class object. It does NOT work with SpatRaster class.
                   2000)                # introduce number of irregular polygons

cotos <- crop(voronoi(pp), sarea) %>%   # create a Spatial Polygon Data Frame
            st_as_sf()  %>%             # convert it to a sf object
            st_set_crs(st_crs(grid5km)) # set its coordinate system to the same
                                        # that the EEA grid has

# 3. Select only those hunting estates that are inside of the grid
cotos.inside<-st_intersection(cotos, grid5km) %>% group_by(id) %>% 
                      summarize(contar=1) %>% ungroup()

# 4. Create a hunting bag for each hunting estate and hunting season
hunting.seasons<-3 
cotos.hs<-list()

for (i in 1:hunting.seasons) {
  # Create a hunting bag as a random poisson process with an expected 
  # lambda of mean 50 and standard deviation of 10
  lambda<-rnorm(1, mean=50, sd=10)
  cotos.inside<-cotos.inside %>% 
                  mutate(HB=rpois(cotos.inside %>% nrow(), lambda), 
                         id=row_number())
  
  cotos0<-cotos.inside %>% 
    sample_frac(.25, replace = FALSE) %>% # select the 25% to change their 
    mutate(HB=0)                          # hunting bags to 0, to simulate unknown 
                                          # or not unreported information 
  
  cotoshb<-cotos.inside[!(cotos.inside$id %in% 
                            cotos0$id),]  # select the hunting estates that have
                                          # not been selected above to change
                                          # their hunting bags
  cotosf<-rbind(cotos0, cotoshb)          # join both layers
  
  cotos.hs[[i]]<-cotosf %>% mutate(hs=paste("spYear", i, sep=""))
}

polygon.layer<- 
              do.call(rbind, cotos.hs) %>% # transform the structure of the
                                           # information created from a list 
                                           # after the loop to a sf object 
                                           # which contains all hunting seasons 
                  spread(hs, HB) %>%       # transform it from long to wide 
                  dplyr::select(id, spYear1, spYear2,spYear3) # select fields you want to save

st_write(polygon.layer,                    # object layer you want to save
         dsn="./data_example.gpkg",        # name of the Geopackage to export the file
         layer="polygon.layer"             # name of the layer you want to save. 
                                           # Be aware it should have a different 
                                           # name of any other layer/s the 
                                           # Geopackage contains, in case 
                                           # you do not want to overwrite it.
         )