# Core analysis functions extracted/adapted from the original Shiny app.

suppressPackageStartupMessages({
  library(dplyr)
  library(igraph)
  library(netmeta)
})

load_pairwise_data <- function(path = "data/cll_pairwise_data.csv") {
  dat <- read.csv(path, stringsAsFactors = FALSE)
  required <- c("study", "treat1", "treat2", "logHR", "selogHR")
  missing <- setdiff(required, names(dat))
  if (length(missing) > 0) {
    stop("Missing required columns: ", paste(missing, collapse = ", "))
  }
  dat |>
    mutate(
      study = as.character(study),
      treat1 = as.character(treat1),
      treat2 = as.character(treat2),
      logHR = as.numeric(logHR),
      selogHR = as.numeric(selogHR)
    )
}

summarise_pairwise_data <- function(dat) {
  treatments <- sort(unique(c(dat$treat1, dat$treat2)))
  g <- igraph::graph_from_data_frame(dat[, c("treat1", "treat2")], directed = FALSE)
  data.frame(
    metric = c("Studies", "Pairwise rows", "Treatments", "Network connected", "Missing cells (%)"),
    value = c(
      length(unique(dat$study)),
      nrow(dat),
      length(treatments),
      as.character(igraph::is.connected(g)),
      round(100 * sum(is.na(dat)) / (nrow(dat) * ncol(dat)), 2)
    )
  )
}

build_nm <- function(data, random = TRUE) {
  netmeta::netmeta(
    TE      = data$logHR,
    seTE    = data$selogHR,
    treat1  = data$treat1,
    treat2  = data$treat2,
    studlab = data$study,
    sm      = "HR",
    random  = random
  )
}

run_cnma_analysis <- function(data, interaction = FALSE, random = TRUE) {
  edges <- data.frame(from = data$treat1, to = data$treat2, stringsAsFactors = FALSE)
  g <- igraph::graph_from_data_frame(edges, directed = FALSE)
  connected <- igraph::is.connected(g)

  if (connected) {
    nm <- build_nm(data, random = random)
    if (interaction) {
      all_trts <- unique(c(data$treat1, data$treat2))
      comps <- sort(unique(trimws(unlist(strsplit(all_trts, "\\s*\\+\\s*")))))
      comb_ia <- combn(comps, 2, FUN = function(x) paste(x, collapse = "+"))
      Cmat_int <- netmeta::createC(nm, comb.ia = comb_ia, sep.trts = " + ")
      return(netmeta::netcomb(nm, C.matrix = Cmat_int))
    }
    return(netmeta::netcomb(nm, sep.trts = " + "))
  }

  if (interaction) {
    warning("Interaction model is not available for disconnected networks. Using additive model instead.")
  }
  dc <- netmeta::discomb(
    TE      = data$logHR,
    seTE    = data$selogHR,
    treat1  = data$treat1,
    treat2  = data$treat2,
    studlab = data$study,
    data    = data,
    sm      = "HR",
    random  = random
  )
  attr(dc, "forced_additive") <- interaction
  dc
}

run_model <- function(data, model_type = c("simple", "additive", "interaction"),
                      effect_model = c("random", "fixed")) {
  model_type <- match.arg(model_type)
  effect_model <- match.arg(effect_model)
  use_random <- effect_model == "random"

  if (model_type == "simple") {
    return(build_nm(data, random = use_random))
  }
  run_cnma_analysis(
    data = data,
    interaction = model_type == "interaction",
    random = use_random
  )
}

extract_ranking <- function(nm, effect_model = c("random", "fixed")) {
  effect_model <- match.arg(effect_model)
  ps <- netmeta::netrank(nm, small.values = "desirable", method = "P-score")
  ranking_vec <- if (effect_model == "random" && !is.null(ps$ranking.random)) {
    ps$ranking.random
  } else if (effect_model == "fixed" && !is.null(ps$ranking.common)) {
    ps$ranking.common
  } else {
    ps$ranking.random %||% ps$ranking.common
  }
  data.frame(
    Treatment = names(ranking_vec),
    P_score = round(as.numeric(ranking_vec), 3),
    row.names = NULL
  ) |>
    arrange(desc(P_score))
}

`%||%` <- function(x, y) if (is.null(x)) y else x
