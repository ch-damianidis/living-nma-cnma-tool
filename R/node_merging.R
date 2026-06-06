# Node-merging helpers extracted/adapted from app.R.

suppressPackageStartupMessages({
  library(dplyr)
})

extract_components <- function(dat) {
  labs <- unique(c(as.character(dat$treat1), as.character(dat$treat2)))
  sort(unique(trimws(unlist(strsplit(labs, "\\s*\\+\\s*")))))
}

replace_components_in_label <- function(lbl, components, new_name) {
  parts <- trimws(unlist(strsplit(as.character(lbl), "\\s*\\+\\s*")))
  parts[parts %in% components] <- new_name
  parts <- unique(parts)
  paste(parts, collapse = " + ")
}

merge_components <- function(dat, components, new_name, stop_on_self_loop = TRUE) {
  if (length(components) < 2) stop("Select at least two components to merge.")
  if (!nzchar(trimws(new_name))) stop("Provide a non-empty new node name.")

  d <- dat |>
    mutate(
      treat1_new = vapply(treat1, replace_components_in_label, FUN.VALUE = character(1),
                          components = components, new_name = new_name),
      treat2_new = vapply(treat2, replace_components_in_label, FUN.VALUE = character(1),
                          components = components, new_name = new_name)
    )

  df_trts <- bind_rows(
    d |> select(study) |> mutate(trt = d$treat1_new),
    d |> select(study) |> mutate(trt = d$treat2_new)
  )

  single_arm_tbl <- df_trts |>
    group_by(study) |>
    summarise(n_unique_trts = n_distinct(trt), .groups = "drop") |>
    filter(n_unique_trts <= 1)

  if (any(d$treat1_new == d$treat2_new) && isTRUE(stop_on_self_loop)) {
    bad <- d[d$treat1_new == d$treat2_new, c("study", "treat1", "treat2", "treat1_new", "treat2_new")]
    stop("Self-loop created by merging. Affected studies: ", paste(unique(bad$study), collapse = ", "))
  }

  pooled <- d |>
    transmute(
      study,
      t1c = pmin(treat1_new, treat2_new),
      t2c = pmax(treat1_new, treat2_new),
      TEc = ifelse(treat1_new <= treat2_new, logHR, -logHR),
      w = 1 / (selogHR^2)
    ) |>
    group_by(study, t1c, t2c) |>
    summarise(
      logHR = sum(w * TEc) / sum(w),
      selogHR = sqrt(1 / sum(w)),
      .groups = "drop"
    ) |>
    rename(treat1 = t1c, treat2 = t2c)

  attr(pooled, "single_arm_studies") <- single_arm_tbl
  pooled
}
