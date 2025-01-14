# PlotOrgn
#' Plot a wordcloud of the organisms in a palm.sra object or orgn.vec 
#' @param palm.sra  data.frame, created from get.palmSra() [NULL]
#' @param orgn.vec  character, vector of "scientific_name" from sra run table [NULL]
#' @param freq      boolean, scale words by frequency, else by identity [T]
#' @return A ggwordcloud object of the "ntop" frequent terms
#' @keywords palmid pro plot
#' @examples
#' 
#' # Retrive organism identifiers from SRA Run Info Table
#' palm.orgn <- get.sraOrgn(run_ids, con)
#' 
#' # Create wordcloud of organism terms
#' PlotOrgn( palm.orgn )
#'
#' @export
PlotOrgn <- function(palm.sra = NULL , orgn.vec = NULL, freq = T){
  load.lib("ggplot")
  require("ggwordcloud", quietly = T)
  
  if (is.null(palm.sra) & is.null(orgn.vec)){
    stop("One of palm.sra or orgn.vec needs to be provided")
  } else if (!is.null(palm.sra)){
    orgn.df <- data.frame( scientific_name = palm.sra$scientific_name,
                         pident          = palm.sra$pident)
  } else {
    orgn.df <- data.frame( scientific_name = orgn.vec,
                         pident          = NA )
  }
  
  # Maximum number of terms to plot
  if (freq){
    # Transform to a standardized table for consistent plotting
    ntop <- 50
    otitle <- 'Sequencing Library Associated Organisms -- sra frequency'
    orgn.df <- data.frame( standardizeWordcount(orgn.df, ntop) )
  } else {
    # Transform to an identity-standard table for consistency
    ntop <- 50
    otitle <- 'Sequencing Library Associated Organisms -- %id match'
    orgn.df <- identityWordcount(orgn.df, ntop)
  }
  
  orgn.wc <- ggplot() + 
    geom_text_wordcloud(data = orgn.df, aes(label = scientific_name,
                                            size  = Freq,
                                            color = Freq)) +
    ggtitle(label = otitle) +
    scale_color_viridis_c(option = "C") +
    theme_minimal()
  
  return(orgn.wc)
}
