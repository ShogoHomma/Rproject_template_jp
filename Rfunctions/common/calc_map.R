# MAP (maximum a posteriori) 値を返す関数

map_value <- function(z) {
  
  val <- density(z)$x[which.max(density(z)$y)]
  return(val)
  
}