gridPresence<-function(small, big, id, harvTot){
  if (st_crs(big)!=st_crs(small)) {
    stop ("CRS is different in both layers. Please transform one to have the same")
  } else {
    harvTot<-enquo (harvTot)
    id<-enquo (id)
    intersection<- st_join(big, small)
    # print(nrow(intersection))
    intersection<-intersection %>% 
      mutate(Presence=ifelse(is.na(!!harvTot), 0, ifelse(!!harvTot>0, 1, 0))) %>% 
      as_tibble() %>% group_by(!!id) %>% summarize(Presence=sum(Presence)) %>% 
      mutate(Presence=as.numeric(ifelse(Presence>0, 1, 0)))
    intersection<-big %>% left_join(intersection, by=quo_name(id))
    # print(nrow(intersection))
  }
  return(intersection)
}