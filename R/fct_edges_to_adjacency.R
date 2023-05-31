#' get_adjacency
#'
#' @description A fct that build an adjacency matrix from a list of edges or an igraph object
#'
#' @param edges Can be a table which is a list pair of nodes (nodes ids are one the two first columns) a numerical third column can be associated will be the connections values.
#'  Or an igraph object
#' @param type network type can be `'bipartite'` or `'unipartite'`
#' @param directed whether or not connections are directed (`T`) or symetrical (`F`) (default is set to `TRUE`)
#'
#'
#' @return an adjacency/incidence matrix (data.frame) representing the network
#'
#' @examples
#' # For unipartite network
#' data_uni <- FungusTreeNetwork$tree_tree
#'
#' # If your network is symmetric :
#' my_mat <- get_adjacency(data_uni$edges,
#'   type = data_uni$type,
#'   directed = FALSE
#' )
#' # If your network is directed :
#' my_mat <- get_adjacency(data_uni$edges,
#'   type = data_uni$type,
#'   directed = TRUE
#' )
#'
#' # For bipartite network
#' data_bi <- FungusTreeNetwork$fungus_tree
#'
#' my_mat <- get_adjacency(data_bi$edges, type = data_bi$type)
#'
#' # In any case you can also use 2 columns data.frames if your network is binary.
#' binary_net <- FungusTreeNetwork$fungus_tree$edges[,-3]
#'
#' my_mat <- get_adjacency(binary_net, type = data_bi$type)
#'
#' # For igraph object the usage is the same
#'
#' require("igraphdata")
#' data("karate",package = "igraphdata")
#' class(karate)
#'
#' get_adjacency(karate)
#'
#' @export
get_adjacency <- function(edges, type = c("unipartite", "bipartite"), directed = F){
  UseMethod("get_adjacency",edges)
}


#' get_adjacency.default
#'
#' @description A fct that build an adjacency matrix from a list of edges
#'
#' @param edges Can be a table which is a list pair of nodes (nodes ids are one the two first columns) a numerical third column can be associated will be the connections values.
#' @param type network type can be `'bipartite'` or `'unipartite'`
#' @param directed whether or not connections are directed (`T`) or symetrical (`F`) (default is set to `TRUE`)
#'
#'
#' @return an adjacency/incidence matrix (data.frame) representing the network
#'
#' @examples
#' # For unipartite network
#' data_uni <- FungusTreeNetwork$tree_tree
#'
#' # If your network is symmetric :
#' my_mat <- get_adjacency(data_uni$edges,
#'   type = data_uni$type,
#'   directed = FALSE
#' )
#' # If your network is directed :
#' my_mat <- get_adjacency(data_uni$edges,
#'   type = data_uni$type,
#'   directed = TRUE
#' )
#'
#' # For bipartite network
#' data_bi <- FungusTreeNetwork$fungus_tree
#'
#' my_mat <- get_adjacency(data_bi$edges, type = data_bi$type)
#'
#' # In any case you can also use 2 columns data.frames if your network is binary.
#' binary_net <- FungusTreeNetwork$fungus_tree$edges[,-3]
#'
#' my_mat <- get_adjacency(binary_net, type = data_bi$type)
#'
#'
#' @export
get_adjacency.default <- function(edges, type = c("unipartite", "bipartite"), directed = F){
  return(edges_to_adjacency(edges,type,directed))
}


#' get_adjacency.igraph
#'
#' @description An igraph object
#'
#' @param edges Can be a table which is a list pair of nodes (nodes ids are one the two first columns) a numerical third column can be associated will be the connections values.
#'  Or an igraph object
#' @param type network type can be `'bipartite'` or `'unipartite'`
#' @param directed whether or not connections are directed (`T`) or symetrical (`F`) (default is set to `TRUE`)
#'
#'
#' @return an adjacency/incidence matrix (data.frame) representing the network
#'
#' @examples
#'
#' # For igraph object the usage is the same
#'
#' require("igraphdata")
#' data("karate",package = "igraphdata")
#' class(karate)
#'
#' get_adjacency(karate)
#'
#' @export
get_adjacency.igraph <- function(edges, type = c("unipartite", "bipartite"), directed = F){
  edges <- igraph::get.edgelist(edges)
  return(edges_to_adjacency(edges,type,directed))
}


#' edges_to_adjacency
#'
#' @description A fct that build an adjacency matrix from a list of edges
#'
#' @param edges Can be a table which is a list pair of nodes (nodes ids are one the two first columns) a numerical third column can be associated will be the connections values.
#' @param type network type can be `'bipartite'` or `'unipartite'`
#' @param directed whether or not connections are directed (`T`) or symetrical (`F`) (default is set to `TRUE`)
#'
#'
#' @return an adjacency/incidence matrix (data.frame) representing the network
#'
#' @noRd
edges_to_adjacency <- function(edges, type = c("unipartite", "bipartite"), directed = F) {
  edges <- as.data.frame(edges)
  ## Rename columns of the pair of node list by 'from', 'to' and 'value' (if needed)
  if (dim(edges)[2] == 2) {
    names(edges) <- c("from", "to")
  } else if (dim(edges)[2] == 3) {
    names(edges) <- c("from", "to", "value")
  } else {
    warning("edges should be a table of 2 or 3 columns")
    return(edges)
  }

  ## According to the type of network while define differently the nodes names
  if (type[1] == "unipartite") {
    # Unipartite case the nodes are the same for cols and rows
    name_row <- name_col <- sort(unique(c(edges$from, edges$to)))
  } else if (type[1] == "bipartite") {
    # bipartite differnt names for from/rows and to:cols
    name_row <- sort(unique(edges$from))
    name_col <- sort(unique(edges$to))
  } else {
    stop("type should be 'bipartite' or 'unipartite'")
  }

  # Empty named matrix
  mat <- matrix(0, length(name_row), length(name_col))
  rownames(mat) <- name_row
  colnames(mat) <- name_col
  # Changing from and to colums with positions into the matrix
  edges <- as.matrix(dplyr::mutate(edges,
                                     from = match(from, name_row),
                                     to = match(to, name_col)
  ))
  # Set values in right positions
  mat[edges[, 1:2]] <- ifelse(rep(dim(edges)[2] == 2, dim(edges)[1]),
                                1, edges[, 3]
  )
  # Specific case of unipartite network with symmetrical connections,
  # just doing the same but reversing to and from columns
  if (type[1] == "unipartite" & !directed) {
    mat[edges[, 2:1]] <- ifelse(rep(dim(edges)[2] == 2, dim(edges)[1]),
                                  1, edges[, 3]
    )
  }
  return(as.data.frame(mat))
}