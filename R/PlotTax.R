# PlotTax
#' Plot a taxonomic-classifier based histogram
#' @param pro   data.frame, A diamond-aligned pro file
#' @param html  boolean, include additional parsing for htmlwidget display
#' @return A histogram ggplot2
#' @keywords palmid pro plot
#' @examples
#' proTax <- PlotTax(pro)
#'
#' @export
PlotTax <- function(pro, html = T){
  load.lib('ggplot')

  ranklvl <-  c('phylum',  'family',  'genus',   'species')
  rankcols <- c("#9f62a1", "#00cc07", "#ff9607", "#ff2a24")
  
  # Taxonomic ranges
  tax <- data.frame(
    rank = factor( 
          c('species', 'genus', 'family', 'phylum'),
           levels = ranklvl ),
    llim = c(90,        70,      45,        0),
    ulim = c(101,       90,      70,        45),
    count= c(0, 0, 0, 0) )
  
  # count each taxonomic rank
  for ( i in 1:4 ){
    tax$count[i] <- length(which( pro$pident <  tax$ulim[i]
                                & pro$pident >= tax$llim[i]))
  }
  
  if (html){
    add_label <- geom_label(data = tax, aes(x = NULL, y = 5, label = count))
  } else {
    add_label <- geom_label(data = tax, aes(x = rank, y = 5, label = count))
      
  }
  # Bar plot of ranks
  taxPlot <- ggplot() +
    geom_col(data = tax, aes(x=rank, y=count, fill = rank),
            show.legend = F) +
    scale_fill_manual(values = rankcols) +
    #add_label +
    ggtitle('') + theme_bw()
  
  return(taxPlot)
}
