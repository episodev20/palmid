# PlotDistro
#' Plot a value relative to a background distribution from a palmprint 
#'   data.frame.
#' @param pp A palmprint.df row to use for the plot "value"
#' @param pp.bg A multiple palmprint.df  for the plot background "distribution"
#' @param plotValue Which numeric column to use for pp and pp.bg. One of
#'   "score", "pssm_total_score", "pp_length", "v1_length", "v2_length"
#' @param distrocol Color to use for distribution ["skyblue"]
#' @param set.ylab Label for y-axis ["palmDB density"]
#' @return A ggplot2 object
#' @keywords palmid fev
#' @examples
#' PlotDistro( ps, pp.bg, 'score', 'black')
#' PlotDistro( ps, pp.bg, 'pp_length', 'skyblue')
#' @export
PlotDistro <- function(pp, pp.bg, plotValue, distrocol = 'skyblue', set.ylab = 'palmDB density') {
  load.lib('ggplot')
  ## debug
  # pp = ps
  # plotValue = 'score'
  # distrocol = 'skyblue'
  # set.ylab = 'test'
  # set.xlim = c(0,75)
  
  # check that an acceptable plotValue is used
  accepted_plot_value <- c('score', 'pssm_total_score',
                           'pp_length', 'v1_length', 'v2_length')
  
  if ( !(plotValue %in% accepted_plot_value) ) {
    stop("plotValue must be set to an appropriate value.")
  }
  
  
  # specific plot values
  if (plotValue == 'pp_length') {
    set.xlim <- c(50, 200)
  } else if (plotValue == 'score') {
    set.xlim <- c(0,75)
  } else { 
    set.xlim <- c(0,NA)
  }
  
  #palmprint color
  pp.col <- 'darkgoldenrod1'
  
  # Input palmprint value
  pp.value <- pp[, plotValue]
  
  # Background distribution of palmprints
  pp.bg.value <- data.frame( bg = pp.bg[, plotValue] )
  
  # Ditribution Plot
  distPlot <- ggplot() +
    # background distribution
    geom_density(data = pp.bg.value, aes( bg ),
                 color = distrocol, fill = distrocol, alpha = 0.8) +
    geom_vline( xintercept = pp.value, size = 1, color = pp.col) +
    geom_text( data = data.frame(pp.value),
               x = Inf, y = Inf,
               hjust = "inward", vjust = "inward",
               color = pp.col, size = 6, label = pp.value) +
    xlim(set.xlim) +
    theme_bw() +
    xlab(plotValue) + ylab(set.ylab)
  #distPlot
  
  return(distPlot)
}