# get.palmSra
#' 
#' A wrapper of several get* functions to create a palm.sra data.frame
#' 
#' @param pro.df   data.frame, imported diamond pro df. use get.pro()
#' @param con      pq-connection, use SerratusConnect()
#' @return palm.sra  data.frame
#' @keywords palmid sql geo biosample timeline Serratus Tantalus
#' @examples
#' 
#' get.palmSra( pro.df, con )
#'
#' @export
#' 
#' 
get.palmSra <- function(pro.df, con = SerratusConnect()) {
  
  # Baseline rows from pro.df input
  palm.sra <- pro.df[ , c('qseqid', 'sseqid', 'pident', 'evalue') ]
  
  # Retrieve each parent sOTU, keep 1 best match within an sOTU
  palm.sra$sOTU <- get.sOTU(palm.sra$sseqid, con, ordinal = T)
    palm.sra <- palm.sra[order(palm.sra$pident, decreasing = T), ]
    palm.sra <- palm.sra[ !duplicated(palm.sra$sOTU), ]
    
  # For each parent sOTU, retrieve a list of all children palm_id
  palm.sra$child_uid  <- get.sOTU(palm.sra$sOTU, con,
                                  get_childs = T, ordinal = T)
  
  # For each parent OR child palm_id, retrieve matching SRA runs
  sra.df <- get.sra(unlist(palm.sra$child_uid), con, ret_df = T)
  
  # For each returned SRA-contig, merge-order to palm.sra
  # spagetti code incoming...
  list.contains <- function(child.list, palm_id){
    list.match <- (palm_id %in% child.list)
    return(list.match)
  }
  
  id.in.list <- function(palm_id, child.list){
    id.match <- which(unlist(lapply(palm.sra$child_uid, list.contains, palm_id)))
    return(id.match)
  }
  
  merge.order <- sapply( sra.df$palm_id, id.in.list, palm.sra$child_uid)
  palm.sra <- cbind( palm.sra[merge.order, ], sra.df)
  
  palm.sra <- palm.sra[ , c('run_id', 'palm_id', 'coverage',
                            'sOTU', 'qseqid', 'pident', 'evalue',
                            'q_sequence')]
  
  colnames(palm.sra) <- c('run_id', 'palm_id', 'coverage',
                          'sOTU', 'qseqid', 'pident', 'evalue',
                          'sra_sequence')
  
  palm.sra <- palm.sra[ order(palm.sra$evalue, decreasing = F), ]
  palm.sra <- palm.sra[ order(palm.sra$pident, decreasing = T), ]
  
  # Add BioSample, Geo data to palm.sra
  palm.sra$biosample_id <- get.sraBio(palm.sra$run_id, con, T)
  
  # Add Organism/scientific_name of sra run
  palm.sra$scientific_name <- get.sraOrgn(palm.sra$run_id, con, T)
  
  # Add time (release date) to palm.sra
  palm.sra$date <- get.sraDate(palm.sra$run_id, con, T)
  
  # Add geo-data if available to palm.sra
  palm.geo.tmp <- get.sraGeo( run_ids = NULL,
                              biosample_ids = palm.sra$biosample_id, con = con, ordinal =  T)
  
  if (!all(palm.geo.tmp$biosample_id == palm.sra$biosample_id)){
    stop("Error in geo lookup.")
  } else {
    palm.sra$lng <- palm.geo.tmp$lng
    palm.sra$lat <- palm.geo.tmp$lat
  }
  
  return(palm.sra)
}
