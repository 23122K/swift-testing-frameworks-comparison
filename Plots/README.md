# Benchmark Plot Scripts

This directory contains two Python scripts for visualising benchmark results from the Swift Testing vs XCTest comparison study. Plots are **not committed** to the repository — they are generated on demand from the data in `Results/`.

## Requirements

```bash
pip3 install matplotlib scipy numpy
```

## Scripts

### `plot_results.py` — multi-device analysis (primary script)

Generates all plots needed for the academic analysis. Run this whenever `Results/` data changes or you need fresh figures.

```bash
python3 Plots/plot_results.py Results
# output → Plots/*.pdf  (default)

python3 Plots/plot_results.py Results --output-dir /some/other/dir
```

**What it generates:**

| File pattern | Count | Description |
|---|---|---|
| `{Device}_{scheme}_{suite}_histogram.pdf` | 32 | Distribution histogram + KDE for one (device, scheme, testSuite). Bin width via Freedman–Diaconis; KDE via Scott's rule. Mean and median annotated. |
| `{Device}_{scheme}_{suite}_boxplot.pdf` | 32 | Boxplot (Tukey 1.5×IQR whiskers) with jittered raw data for one (device, scheme, testSuite). |
| `{scheme}_{suite}_timeseries.pdf` | 8 | Run duration per iteration for one (scheme, testSuite), with one line per device (M1 / M2 Pro / M4 Pro / M5). Reveals warm-up effects and cross-device performance differences. |

**Devices:** Apple M1 · MacBook Pro, Apple M2 Pro · MacBook Pro, Apple M4 Pro · Mac mini, Apple M5 · MacBook Pro

**Schemes × suites:** bitchat, bitchat-refactored, swift-loggable, swift-pesel — each with a Swift Testing suite (`*Tests`) and an XCTest suite (`*XCTests`)

**Statistics printed to stdout** before generating plots:
- Iteration integrity check (expected n=100 per series, flags any anomalies)
- Descriptive table: mean, median, sample std dev, CV%, 95% CI (Student's t, n−1 df), D'Agostino–Pearson K² normality test p-value
- Plot display unit per scheme. Every plot for the same scheme uses the same duration unit across Swift Testing and XCTest suites.

---

### `plot_benchmark.py` — single-scheme analysis

Analyses one scheme directory (e.g. `Results/<device>/swift-pesel`) in isolation. Useful for spot-checking a single device or suite without running the full multi-device analysis.

```bash
python3 Plots/plot_benchmark.py Results/Mac17-2__Apple-M5__16-GB__MDE44ZE/swift-pesel
python3 Plots/plot_benchmark.py Results/Mac16-11__Apple-M4-Pro__24-GB__MCX44D/bitchat --output-dir ./plots
```

**What it generates** (inside `<input-dir>/plots/` by default):

| File | Description |
|---|---|
| `{suite}_histogram.pdf` | Histogram + KDE for one suite |
| `{suite}_mean_ci.pdf` | Mean ± 95% CI bar chart with σ annotation |
| `{suite}_timeseries.pdf` | Duration per iteration |
| `{scheme}_histograms.pdf` | Combined histogram grid for all suites in the scheme |
| `{scheme}_mean_ci.pdf` | Combined mean CI bar chart |
| `{scheme}_timeseries.pdf` | Combined timeseries for all suites |

**Statistics printed to stdout:**
- Mean, median, sample std dev, CV%, min, max
- D'Agostino–Pearson K² normality test
- Pairwise Mann–Whitney U test + Welch's t-test between Swift Testing and XCTest suite pairs, with rank-biserial r and Cohen's d effect sizes
- Plot display unit for the scheme directory. Individual and combined plots use that same unit for every suite.

## When to regenerate plots

Regenerate with `plot_results.py` when:
- New benchmark results are added to `Results/`
- A new device directory is added
- You need figures for a paper draft or presentation

Regenerate with `plot_benchmark.py` when:
- Spot-checking results for a single device/scheme
- Comparing Swift Testing vs XCTest for one specific package

## Statistical notes

- **95% CI**: computed using Student's t-distribution with n−1 degrees of freedom (exact, no CLT approximation needed)
- **Bin width**: Freedman–Diaconis rule (`h = 2·IQR·n^{-1/3}`) — robust to non-normality, adapts to data spread
- **Normality test**: D'Agostino–Pearson K² omnibus test — appropriate for n=100; p < 0.05 indicates significant departure from normality
- **Outlier detection**: Tukey extreme fence `[Q1 − 3·IQR, Q3 + 3·IQR]` — IQR-based, robust when outliers are present
- **Pairwise tests**: Mann–Whitney U preferred when normality is rejected; Welch's t included for completeness
- **Palette**: Wong (2011) colourblind-safe 7-colour palette
