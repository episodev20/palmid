#' get.sraBio
#'
#' Retrieve the "BioSample" field for a set of SRA `run_id`
#' 
#' @param run_ids character, SRA `run_id`
#' @param con     pq-connection, use SerratusConnect()
#' @param ordinal boolean, return `run_ids` ordered vector [F]
#' @return data.frame, run_id, biosample character vectors
#' @keywords palmid Serratus geo
#' @examples
#' palm.bio   <- get.sraBio(palm.sras, con)
#' 
#' @export
get.sraBio <- function(run_ids, con, ordinal = F) {
  load.lib('sql')
  
  # get biosample field for run_id
  sra.bio <- tbl(con, 'srarun') %>%
    filter(run %in% run_ids) %>%
    select(run, bio_sample) %>%
    as.data.frame()
    colnames(sra.bio) <- c('run_id', 'biosample_id')
    # must be unique
    sra.bio <- sra.bio[ !duplicated(sra.bio$run_id), ]
  
  if (ordinal){
    # Left join on palm_ids to make a unique vector
    ord.bio <- data.frame( run_id = run_ids )
    ord.bio <- merge(ord.bio, sra.bio, all.x = T)
    ord.bio <- ord.bio[ match(run_ids, ord.bio$run_id), ]
    
    return(ord.bio$biosample_id)
  } else {
    unq.bio <- unique(sra.bio$biosample_id)
    return(unq.bio)
  }
}
