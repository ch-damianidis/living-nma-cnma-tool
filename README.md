# Living Network Meta-Analysis Quarto Website

[![R](https://img.shields.io/badge/R-%3E%3D4.0-blue.svg)](https://www.r-project.org/)
[![Quarto](https://img.shields.io/badge/Quarto-Website-blue.svg)](https://quarto.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Μια επαναγώγιμη Quarto-based ερευνητική ιστοσελίδα για "Living Network Meta-Analysis (Living NMA)" — μεταφορά και επέκταση της αρχικής Shiny prototype ώστε να δημιουργηθεί ένα δημοσιεύσιμο, τεκμηριωμένο και στατικό documentation/interactive prototype.

---

## Περιεχόμενο (σύντομη περιγραφή)

Αυτό το αποθετήριο παρουσιάζει ένα πλήρες workflow για Living NMA. Συνδυάζει:

- Στατικές Quarto σελίδες (.qmd) για τεκμηρίωση της μεθοδολογίας, δεδομένων, ανάλυσης, και περιορισμών
- Επαναχρησιμοποιήσιμες R συναρτήσεις στο φάκελο `R/` που υλοποιούν την κύρια ανάλυση (NMA/CNMA)
- Μικρό παράδειγμα dataset (`data/cll_pairwise_data.csv`) για demo
- Client-side interactive module για node-merging με `quarto-live` + webR (WebAssembly)

Αυτή η έκδοση στοχεύει σε reproducibility και δημοσιεύσιμη παρουσίαση περισσότερων αποτελεσμάτων από ό,τι η αρχική Shiny app, ενώ διατηρεί επιλεγμένα interactive features στο browser.

---

## Features

- Classical NMA (netmeta)
- Component NMA (CNMA): additive και interaction επιλογές
- Node-merging (browser-side) με validation (αποφυγή self-loops, single-arm detection)
- Inconsistency diagnostics: node-splitting (local), design-by-treatment (global)
- Treatment ranking (P-scores)
- Static site rendering στο `docs/` (έτοιμο για GitHub Pages)

---

## Project structure

```text
.
├── _quarto.yml                # Quarto config (navbar, render -> docs/)
├── index.qmd                  # Home
├── methodology.qmd            # Μεθοδολογία
├── data.qmd                   # Περιγραφή δεδομένων
├── analysis.qmd               # Ανάλυση που χρησιμοποιεί R/ functions
├── node-merging.qmd           # Περιγραφή node-merging λογικής
├── interactive-node-merging.qmd # Διαδραστική σελίδα (quarto-live + webR)
├── inconsistency.qmd
├── ranking.qmd
├── limitations.qmd
├── R/                         # Επαναχρησιμοποιήσιμες R συναρτήσεις
│   ├── nma_functions.R
│   └── node_merging.R
├── data/                      # Παράδειγμα δεδομένων (cll_pairwise_data.csv)
├── docs/                      # Rendered site (output)
├── _extensions/               # Quarto extensions (πχ quarto-live)
└── original_shiny/            # Αρχικός Shiny prototype για αναφορά
```
```

Πώς ταιριάζουν: οι `.qmd` σελίδες καλούν τις R συναρτήσεις για να παράξουν plots, πίνακες και αποτελέσματα. Η interactive σελίδα τρέχει μέρος της λογικής client-side με webR ώστε να επιτρέπει node-merging χωρίς server.

---

## Requirements

- R ≥ 4.0
- Quarto
- Browser σύγχρονος (για interactive page)

Σημαντικά R packages: netmeta, igraph, dplyr, quarto, (webR assets μέσω quarto-live)

---

## Render τοπικά

Εγκατάσταση extension (μία φορά):

```bash
quarto add r-wasm/quarto-live
```

Render ολοκλήρου του site:

```bash
quarto render
```

Preview (για δοκιμή της interactive σελίδας):

```bash
quarto preview
```

Το rendered site παράγεται στο `docs/` και είναι σχεδιασμένο για GitHub Pages (Branch: main, Folder: /docs).

---

## Data format

Το παράδειγμα χρησιμοποιεί contrast-level pairwise δεδομένα με στήλες:

- `study` (character)
- `treat1` (character)
- `treat2` (character)
- `logHR` (numeric)
- `selogHR` (numeric)

Για combination treatments χρησιμοποιείται ` + ` ως διαχωριστής (π.χ. `Drug A + Drug B`).

---

## Analysis models

- Simple NMA: `netmeta()`
- Additive CNMA: `netcomb()` με `sep.trts = " + "`
- Interaction CNMA: custom C-matrix (2-way interactions) μέσω `combn()` + `createC()`
- Disconnected networks: fallback σε `discomb()` (additive only)

---

## Node merging (interactive)

Το interactive module επιτρέπει:

1. Επιλογή components για συγχώνευση
2. Εισαγωγή νέου ονόματος κόμβου
3. Επιλογή additive / additive+interaction CNMA
4. Εκτέλεση της ανάλυσης στο browser (webR)

Η συγχώνευση αντικαθιστά component labels, ενοποιεί συγκρίσεις με inverse-variance pooling, και αποτρέπει self-loops. Single-arm studies μετά τη συγχώνευση επισημαίνονται.

---

## Testing

Προσθήκη unit tests για κρίσιμες συναρτήσεις (`merge_components`, `run_model`) προτείνεται. Τα υπάρχοντα scripts στο `R/` έχουν βασικούς ελέγχους για required columns.

---

## Contributing

Fork → feature branch → PR. Παρακαλώ συμπεριλάβετε tests και ενημερωμένο documentation.

---

## Citation

```
Damianidis, C. (2026). Living Network Meta-Analysis Quarto Website: reproducible workflows and interactive node-merging. MSc Thesis / Technical Report.
```

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## Contact

Charalampos Damianidis — charalampos.damianidis@gmail.com

