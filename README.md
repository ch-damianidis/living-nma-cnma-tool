# Living Network Meta-Analysis Quarto Website

[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue.svg)](https://www.r-project.org/)
[![Quarto](https://img.shields.io/badge/Quarto-Website-blue.svg)](https://quarto.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A reproducible Quarto-based research website for "Living Network Meta-Analysis (Living NMA)". This repository adapts and extends an original Shiny prototype into a transparent, reproducible, and publishable static website while preserving selected interactive functionality via client-side R (webR).

This work is based on the MSc thesis "Development of a Shiny Tool for Living Network Meta-Analysis, Demonstrated in Chronic Lymphocytic Leukaemia" (Damianidis, 2026).

[Visit the website](https://ch-damianidis.github.io/living-nma-cnma-tool/)
---

## Overview

The site documents and demonstrates a Living NMA workflow with:

- static Quarto pages describing methodology, data, analysis, inconsistency assessment, ranking, and limitations;
- reusable R functions in `R/` powering the analysis pipeline (NMA/CNMA);
- a small example dataset (`data/cll_pairwise_data.csv`) for demonstration;
- a browser-side interactive node-merging module implemented with `quarto-live` + webR (WebAssembly).

This project is a research prototype and methodological blueprint rather than a production platform.

---

## Main functionality

- Data overview for the example CLL network
- Frequentist Network Meta-Analysis using `netmeta`
- Network plots and summary outputs
- Node-merging logic for treatment components
- Browser-side interactive node merging (quarto-live + webR)
- Additive and additive-plus-interaction CNMA options (where applicable)
- Treatment ranking (P-scores)
- Local inconsistency assessment (node-splitting)
- Global inconsistency assessment (design-by-treatment decomposition)

---

## Project structure

```text
.
├── _quarto.yml
├── index.qmd
├── methodology.qmd
├── data.qmd
├── analysis.qmd
├── node-merging.qmd
├── interactive-node-merging.qmd
├── inconsistency.qmd
├── ranking.qmd
├── limitations.qmd
├── R/                 # Reusable R functions (nma_functions.R, node_merging.R)
├── data/              # Example datasets (cll_pairwise_data.csv)
├── docs/              # Rendered site (output)
├── _extensions/       # Quarto extensions (e.g. quarto-live)
└── original_shiny/    # Original Shiny prototype (for reference)
```
```

How it fits together: Quarto pages call functions from `R/` to produce figures, tables and model outputs. The interactive page runs part of the node-merging workflow entirely in the browser using webR, avoiding the need for a Shiny server for that feature.

---

## Requirements

- R >= 4.0
- Quarto
- A modern web browser (for the interactive page)

Key R packages: `netmeta`, `igraph`, `dplyr`, and the typical Quarto R ecosystem; the interactive page depends on `quarto-live` and webR assets.

---

## Render locally

Install the Quarto Live extension (once):

```bash
quarto add r-wasm/quarto-live
```

Render the full site:

```bash
quarto render
```

Preview locally (useful for testing the interactive page):

```bash
quarto preview
```

The rendered site is produced in `docs/` and is suitable for GitHub Pages (Branch: main, Folder: /docs). Note: opening the interactive HTML directly via a `file://` path may prevent webR assets from loading correctly; use `quarto preview` or deploy to a web server.

---

## Data format

The example uses contrast-level (pairwise) data with these columns:

- `study` (character)
- `treat1` (character)
- `treat2` (character)
- `logHR` (numeric)
- `selogHR` (numeric)

Combination treatments use ` + ` as a separator (e.g. `Drug A + Drug B`). Arm-level data can be converted using `netmeta::pairwise()` where appropriate.

---

## Analysis models

- Simple NMA via `netmeta()`
- Additive CNMA via `netcomb()` (decomposes combinations into components)
- Interaction CNMA via `netcomb()` with a custom C-matrix including 2-way interactions (generated with `combn()` and `createC()`)
- Disconnected networks: fallback to `discomb()` (additive model only)

The R helper functions in `R/nma_functions.R` implement model construction, CNMA handling and ranking extraction.

---

## Node merging (interactive)

The interactive module allows:

1. selecting components to merge
2. entering a new merged node name
3. choosing additive or additive+interaction CNMA
4. running the merged analysis in the browser (webR)

Merging replaces component labels, pools duplicate comparisons within a study using inverse-variance weighting, and prevents self-loops. Single-arm studies produced by merging are detected and reported.

---

## Testing

Add unit tests for critical functions (e.g. `merge_components`, `run_model`) using `testthat`. The R scripts in `R/` include basic input validation for required columns.

---

## Contributing

Contributions welcome. Suggested workflow:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Add tests and documentation
4. Commit and push
5. Open a pull request

---

## Citation

If you use this work in research, please cite:

Damianidis, C. (2026). Development of a Shiny Tool for Living Network Meta-Analysis, Demonstrated in Chronic Lymphocytic Leukaemia. MSc Thesis, Aristotle University of Thessaloniki.

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Contact

Charalampos Damianidis — charalampos.damianidis@gmail.com
