## Institute for Game and Wildlife Research
## data Author: Remain anonymous for per review 
## Date: 08/02/2024

# library(dismo)
# library(terra)
library(sf)
library(tidyverse)
library(ggpubr)
rm(list=ls()) # clears R workspace

# Count data collected simulation
# Collected hunting yields cannot be shared due to data share agreement confidentiality
# Simulated hunting yields data sets are provided for running gridPresence() function

# ---------------------------------------------
# 1) load the provided data example
# ---------------------------------------------
# it contains:
# - a 5 x 5 km grid: downloaded from the EEA grid and masked with Spain
# - a simulated polygon layer with three simulated counts of whatever species
load(url("https://raw.githubusercontent.com/robinilla/gridPresence/main/script/data_example.Rdata")) 

# Transform the 5 x 5 km grid to 10 x 10 km, by the EEA grid code id
grid10km<-grid5km %>% group_by(CELLCOD) %>% summarise(geometry = sf::st_union(geometry)) %>% ungroup()


# -----------------------------------------------
# 2) gridPresence function: it needs 4 parameters
# -----------------------------------------------
# big = a sf object class
# small = a sf object class
# id = unique id column name from the big object class.
# count = column name of count data from the small object class
# Note 1: big and small are objects that must have the same coordinate reference
# system, if not an ERROR will be display
# Note 2: id and count are not objects of your environment. They are column 
# names, and must not be provided between quotes. The function 
# implements quotation of these parameters


# Create the function with the 4 above commented parameters
gridPresence<-function(small, big, id, count){                              
  
  # Check if small parameter is a sf object 
  if(!("sf" %in% class(small))) {                                             
    stop("ERROR: Class of first argument is not sf")
  }
  # Check if big parameter is a sf object
  if(!("sf" %in% class(big))) {                                               
    stop("ERROR: Class of second argument is not sf")
  }
  
  # Check that big and small objects have the same Coordinate Reference System
  if (st_crs(big)!=st_crs(small)) {                                           
    stop ("CRS is different in both layers. Please transform one to have the same")
  } else {
    # Quote the name of count column (from small layer)
    count<-enquo (count)                                                  
    # Quote the name of id column (from big layer)
    id<-enquo (id)
    
    # Make the intersection of all grids with all hunting grounds
    # it returns the same cell grid as many times as a cell intersects with a 
    # polygon, acquiring the cell grid the information of each polygon 
    # feature with whom it intersects
    intersection<- st_join(big, small)
    
    # Group all cell grids with the same id from the above intersection
    intersection<-intersection %>% 
      # Transform count to presence: if count field is NA or 0, it will be 0,
      # and if count field is above 0 it will be 1
      # Note: !! it does not do anything by itself, it tells mutate to replace count 
      # by the quoted content of count
      mutate(Presence=ifelse(is.na(!!count), 0, ifelse(!!count>0, 1, 0))) %>%  
      # transform into a tibble for grouping faster
      as_tibble() %>% 
      # use id for grouping all the cell grids
      group_by(!!id) %>% 
      # sum presence values for each same grid id 
      summarize(Presence=sum(Presence)) %>% 
      # retransform presence sum values to 1 or 0
      mutate(Presence=as.numeric(ifelse(Presence>0, 1, 0)))
    
    # join the big layer with the resulting intersection object for returning
    # the fields of the big layer and the new presence field created
    intersection<-big %>% left_join(intersection, by=quo_name(id))
  }
  return(intersection)
}


# Make the grid transformation from different years and different grids at once
intersection.list10km<-list() #create a 
intersection.list5km<-list()
for (i in 1:(polygon.layer %>% dplyr::select(matches("sp")) %>% ncol() -1)){    # take care that the hunting yields from different hunting seasons have some common name in the columns name
  col.name<-(polygon.layer %>% dplyr::select(matches("sp")) %>% colnames())[i]
  print(col.name)                                                          # just to know which hunting season we are running
  layer.sp1<-polygon.layer %>% dplyr::select(id, all_of(col.name))
  intersection.list10km[[i]]<-gridPresence(small=layer.sp1, big=grid10km, id=CELLCOD, count=!!sym(col.name))
  intersection.list5km[[i]]<-gridPresence(small=layer.sp1, big=grid5km, id=cellcode, count=!!sym(col.name))
}


# Transform list results as a data frame by cbind its columns 
intersection.list5km<-do.call(cbind, intersection.list5km) %>% dplyr::select(cellcode, eoforigin, noforigin, CCAA, matches("Pres")) 
colnames(intersection.list5km) [5:7]<-gsub("sp", "pres", (polygon.layer %>% dplyr::select(matches( "sp")) %>% colnames()))[1:3]

intersection.list10km<-do.call(cbind, intersection.list10km) %>% dplyr::select(CELLCOD, matches("Pres")) 
colnames(intersection.list10km) [2:4]<-gsub("sp", "pres", (polygon.layer %>% dplyr::select(matches( "sp")) %>% colnames()))[1:3]

#Plot grid presence: plot example for first count year
ggarrange(ggplot()+
            geom_sf(data=intersection.list10km, aes(fill=as.factor(presYear1), alpha=0.25), color="darkgrey")+   # 10 x 10 km grid
            scale_fill_manual(values = c("#d3d3d3", "#6eac5c"))+
            ggtitle("10 x 10 km")+
            theme(legend.position = "none")+
            theme_bw(),
          ggplot()+
            geom_sf(data=intersection.list5km, aes(fill=as.factor(presYear1), alpha=0.25), color="darkgrey")+   # 10 x 10 km grid
            scale_fill_manual(values = c("#d3d3d3", "#6eac5c"))+
            ggtitle("5 x 5 km")+
            theme(legend.position = "none")+
            theme_bw(), 
          ncol=2, nrow=1, common.legend = T, legend = "none")



# Plot collected hunting yields for the different hunting seasons
# uncomment lines 137-152 for running
# yellow line polygons represent the value 0, that is, no individuals have been counted
# ggarrange(ggplot()+
#             geom_sf(data=polygon.layer, aes(fill=spYear1))+ 
#             scale_fill_distiller()+
#             geom_sf(data=polygon.layer %>% filter(spYear1==0), color="yellow", fill=NA)+
#             theme_bw(),
#           ggplot()+
#             geom_sf(data=polygon.layer, aes(fill=spYear2))+ 
#             scale_fill_distiller()+
#             geom_sf(data=polygon.layer %>% filter(spYear2==0), color="yellow", fill=NA)+
#             theme_bw(),
#           ggplot()+
#             geom_sf(data=polygon.layer, aes(fill=spYear3))+ 
#             scale_fill_distiller()+
#             geom_sf(data=polygon.layer %>% filter(spYear3==0), color="yellow", fill=NA)+
#             theme_bw(), 
#           nrow=3, ncol=1, common.legend=F)