# Living Network Meta-Analysis Quarto Website

This repository contains a reproducible Quarto-based research website for **Living Network Meta-Analysis (Living NMA)**. It was developed as an extension and upgrade of my MSc thesis project, originally implemented as a Shiny prototype under the title:

**Development of a Tool for Living Network Meta-Analysis**

The aim of this version is to transform the original Shiny application into a more transparent, reproducible, and publishable static research website, while preserving selected interactive functionality through browser-side computation.

## Project overview

This project provides a blueprint for presenting and exploring a Living NMA workflow in a static web environment. It combines:

* static Quarto pages for methodology, data structure, analysis, inconsistency assessment, ranking, and limitations;
* reusable R functions for the main analysis pipeline;
* pre-rendered outputs suitable for GitHub Pages;
* an interactive browser-side node-merging module using `quarto-live` and webR/WebAssembly.

The website is intended as a research prototype rather than a full production platform. It demonstrates how a Living NMA workflow can be documented, reproduced, and partially interacted with through a static website.

## Main functionality

The website includes the following components:

* data overview for the example CLL network;
* standard Network Meta-Analysis using `netmeta`;
* network plots and summary outputs;
* node merging logic for treatment components;
* browser-side interactive node merging;
* additive and additive-plus-interaction CNMA options in the interactive layer;
* treatment ranking;
* local inconsistency assessment using node-splitting;
* global inconsistency assessment using design-by-treatment decomposition;
* methodological notes and limitations.

## Interactive node merging

The page `interactive-node-merging.qmd` provides an interactive browser-side module. The user can:

1. select treatment components to merge;
2. provide a new merged component name;
3. choose between an additive and an additive-plus-interaction CNMA option;
4. run the node-merging analysis directly in the browser;
5. inspect the resulting network plot and model summary.

The module includes validation rules to prevent invalid merges, including self-comparisons, non-comparative studies, empty merged names, and networks with too few treatment nodes. If the merged network becomes disconnected, the module displays an `igraph` network representation instead of a standard `netmeta` network plot.

## Important note on first loading time

The interactive module uses `quarto-live`, webR, and WebAssembly to run R code inside the browser. Therefore, the first time the interactive page is opened, the browser may need some time to download and initialize R and the required packages, including `dplyr`, `netmeta`, `meta`, and `igraph`.

The first loading may take a few minutes depending on the user's internet connection and browser cache. This is expected behaviour. Subsequent visits are usually faster because some files may be cached by the browser.

## Static website versus Shiny app

The original Shiny prototype was designed as a more application-like tool with reactive behaviour. This Quarto version follows a different architecture:

* the core analysis is decomposed into reusable R functions;
* Quarto pages call these functions to produce reproducible outputs;
* the rendered website can be hosted as a static site;
* selected interactive features are implemented client-side through webR.

This means that the Quarto website does not require a Shiny server. However, it also means that some production-level features are intentionally not included, such as:

* user accounts;
* persistent version history;
* database-backed Living NMA updates;
* permanent storage of user choices;
* uploaded datasets saved on the server;
* collaborative editing.

For a full production Living NMA platform, a Shiny/server or other backend-based architecture would still be required.

## Repository structure

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
├── R/
├── data/
├── docs/
├── _extensions/
└── original_shiny/
```

## Render locally

To render the full website locally, run:

```bash
quarto render
```

The rendered static website is created in:

```text
docs/
```

To preview the website locally, use:

```bash
quarto preview
```

The live interactive page should be tested through `quarto preview` or after deployment to GitHub Pages. Opening the rendered HTML directly through a `file://` path may cause browser-side JavaScript or OJS components not to work correctly.

## Quarto Live extension

The interactive module depends on the Quarto Live extension. If the extension is not already installed in the project, run:

```bash
quarto add r-wasm/quarto-live
```

Then render either the full website:

```bash
quarto render
```

or only the interactive page:

```bash
quarto render interactive-node-merging.qmd
```

## GitHub Pages deployment

This project is designed to be deployed through GitHub Pages using the rendered `docs/` folder.

Recommended GitHub Pages settings:

```text
Source: Deploy from a branch
Branch: main
Folder: /docs
```

The `.nojekyll` file is included so that GitHub Pages serves the Quarto-generated files correctly.

## Original Shiny prototype

The original Shiny code is preserved in:

```text
original_shiny/
```

This folder is kept for reference and to document the development path from the initial Shiny prototype to the Quarto-based reproducible website.

## Status

This repository should be viewed as a research prototype and methodological blueprint. It demonstrates how a Living Network Meta-Analysis workflow can be presented as a reproducible static research website with selected browser-side interactive functionality.

It is not intended to replace a full server-based Living NMA platform, but it provides a strong foundation for future development.
