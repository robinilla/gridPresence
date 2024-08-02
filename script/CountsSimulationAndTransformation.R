library(dismo)
library(terra)
library(sf)
library(ggpubr)

rm(list=ls())
set.seed(1993)

# Hunting estates collected simulation
# As collected hunting yields cannot be shared due to data share agreement conficendialty
# Simulated hunting yields data sets are provided for running gridPresence() function 

# load the grid/s
# Read 5 x 5 km grid: downloaded from the EEA grid and masked with Spain
load(url("https://raw.githubusercontent.com/robinilla/gridPresence/main/script/grid5km.Rdata")) 

# Transform the 5 x 5 km grid to 10 x 10 km (EEA grid code )
# it will take few minutes, be patient, it works
grid10km<-grid5km %>% group_by(CELLCOD) %>% summarise(geometry = sf::st_union(geometry)) %>% ungroup()


# Create hunting estates (irregular polygons ): from the extent of our 10x10 km grid 
sarea <- rast(nrows = 100, ncols = 100, ext(grid10km))
sarea<-raster(sarea)
pp <- randomPoints(sarea, #introduce the layer
                   2000)  #introduce number of irregular polygons to be created
cotos <- crop(voronoi(pp), sarea) %>% st_as_sf()  %>% st_set_crs(st_crs(grid10km)) #transform as sf object with same crs as EEA grid

# From the created hunting estates select only those ones that are inside of the 10 x 10 grid
cotos.inside<-st_intersection(cotos, grid10km) %>% group_by(id) %>% summarize(contar=1) %>% ungroup()

hunting.seasons<-5
cotos.hs<-list()

#Create a hunting bag for each hunting estate and hunting season
for (i in 1:hunting.seasons) {
  # Create a hunting bag as a random poisson process with lambda
  lambda<-rnorm(1, mean=50, sd=10)
  cotos.inside<-cotos.inside %>% mutate(HB=rpois(cotos.inside %>% nrow(), lambda), id=row_number())
  
  # The 25 percent of the hunting estates are selecting for changing their hunting yield to 0: unknown or not reported information of the hunting estate
  cotos0<-cotos.inside %>% sample_frac(.25, replace = FALSE) %>% mutate(HB=0)
  cotoshb<-cotos.inside[!(cotos.inside$id %in% cotos0$id),]
  cotosf<-rbind(cotos0, cotoshb)
  
  cotos.hs[[i]]<-cotosf %>% mutate(hs=paste("HS", i, sep=""))
}

cotos.hs<-spread(do.call(rbind, cotos.hs), hs, HB) %>%  #join all the hunting seasons into a same object and transform it from long to wide format 
  mutate(species="Sus scrofa") # We use wild boar species as example, but hunting bags, or counts data could be for any species

# Plot collected hunting yields for the different hunting seasons
ggarrange(ggplot()+
            geom_sf(data=cotos.hs, aes(fill=HS1))+ 
            scale_fill_distiller()+
            geom_sf(data=cotos.hs %>% filter(HS1==0), color="yellow", fill=NA)+
            theme_bw(),
          ggplot()+
            geom_sf(data=cotos.hs, aes(fill=HS2))+ 
            scale_fill_distiller()+
            geom_sf(data=cotos.hs %>% filter(HS2==0), color="yellow", fill=NA)+
            theme_bw(),
          ggplot()+
            geom_sf(data=cotos.hs, aes(fill=HS3))+ 
            scale_fill_distiller()+
            geom_sf(data=cotos.hs %>% filter(HS3==0), color="yellow", fill=NA)+
            theme_bw(), 
          ggplot()+
            geom_sf(data=cotos.hs, aes(fill=HS4))+ 
            scale_fill_distiller()+
            geom_sf(data=cotos.hs %>% filter(HS4==0), color="yellow", fill=NA)+
            theme_bw(),
          ggplot()+
            geom_sf(data=cotos.hs, aes(fill=HS5))+ 
            scale_fill_distiller()+
            geom_sf(data=cotos.hs %>% filter(HS5==0), color="yellow", fill=NA)+
            theme_bw(),
          nrow=3, ncol=2, common.legend=TRUE)



#load the function for transforming hunting bags data to presence in a grid 
source("https://raw.githubusercontent.com/robinilla/gridPresence/main/script/gridPresence.R")


#Make the grid transformation from different hunting seasons at once
intersection.list10km<-list()
intersection.list5km<-list()
for (i in 1:(cotos.hs %>% dplyr::select(matches("HS")) %>% ncol() -1)){    # take care that the hunting yields from different hunting seasons have some common name in the columns name
  col.name<-(cotos.hs %>% dplyr::select(matches("HS")) %>% colnames())[i]
  print(col.name)                                                          # just to know which hunting season we are running
  layer.sp1<-cotos.hs %>% dplyr::select(id, species, all_of(col.name))
  intersection.list10km[[i]]<-gridPresence(small=layer.sp1, big=grid10km, id=CELLCOD, harvTot=!!sym(col.name))
  intersection.list5km[[i]]<-gridPresence(small=layer.sp1, big=grid5km, id=id2, harvTot=!!sym(col.name))
}

#Plot grid presence: plot example for first hunting season
ggarrange(ggplot()+
            geom_sf(data=intersection.list10km[[1]], aes(fill=as.factor(Presence), alpha=0.25), color="darkgrey")+   # 10 x 10 km grid
            scale_fill_manual(values = c("#d3d3d3", "#6eac5c"))+
            # geom_sf(data=cotos.hs %>% filter(HS1==0), color="darkred", fill="#d3d3d3", alpha=0.3)+
            # geom_sf(data=cotos.hs %>% filter(HS1!=0), color="black", fill="#6eac5c", alpha=0.15)+
            # geom_sf(data=layer.sp1 %>% filter(Presence==1), aes(fill=Presence))+
            ggtitle("10 x 10 km")+
            theme(legend.position = "none")+
            theme_bw(),
          ggplot()+
            geom_sf(data=intersection.list5km[[1]], aes(fill=as.factor(Presence), alpha=0.25), color="darkgrey")+   # 10 x 10 km grid
            scale_fill_manual(values = c("#d3d3d3", "#6eac5c"))+
            # geom_sf(data=cotos.hs %>% filter(HS1==0), color="darkred", fill="#d3d3d3", alpha=0.3)+
            # geom_sf(data=cotos.hs %>% filter(HS1!=0), color="black", fill="#6eac5c", alpha=0.15)+
            # geom_sf(data=layer.sp1 %>% filter(Presence==1), aes(fill=Presence))+
            ggtitle("5 x 5 km")+
            theme(legend.position = "none")+
            theme_bw(), 
          ncol=2, nrow=1, common.legend = T, legend = "none")
