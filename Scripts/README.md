# Study Scripts

This directory contains scripts used to verify and visualise the benchmark
results for the Swift Testing vs XCTest comparison study. The raw benchmark data
lives in `Results/`. Generated plots are not committed and should be recreated
on demand.

## Requirements

The `results` script only uses the Python standard library.

The plotting scripts require:

```bash
pip3 install matplotlib scipy numpy
```

## `results`

Recalculates the thesis evaluation numbers from the raw per-iteration JSON
files:

- mean total test-run duration
- sample standard deviation (`ddof = 1`)
- 95% Student's t-interval for `n = 100`
- coefficient of variation
- `swift-pesel`, `bitchat`, and `swift-loggable` prose-level derived claims
- source LoC and test-function counts for `swift-pesel` and `swift-loggable`, when those sibling source repositories are available

Run from the repository root:

```bash
python3 Scripts/results
```

The default paths assume this local layout:

```text
23122K/
  swift-testing-frameworks-comparison/
  swift-pesel/
  swift-loggable/
```

Custom paths can be supplied when needed:

```bash
python3 Scripts/results \
  --results-dir /path/to/Results \
  --pesel-tests-dir /path/to/swift-pesel/Tests \
  --loggable-tests-dir /path/to/swift-loggable/Tests
```

The `bitchat` source LoC values cannot be reconstructed from the raw JSON alone;
the JSON verifies the exported test-case count and performance data for that
project.

## `plot_results.py`

Primary multi-device plotting script. It generates all plots used for the
academic analysis whenever `Results/` changes or fresh figures are needed.

```bash
python3 Scripts/plot_results.py Results
python3 Scripts/plot_results.py Results --output-dir /some/other/dir
```

By default, output is written to `Plots/*.pdf`.

Generated files:

| File pattern | Count | Description |
|---|---:|---|
| `{Device}_{scheme}_{suite}_histogram.pdf` | 32 | Distribution histogram and KDE for one device, scheme, and suite. Bin width uses Freedman-Diaconis; KDE uses Scott's rule. Mean and median are annotated. |
| `{Device}_{scheme}_{suite}_boxplot.pdf` | 32 | Boxplot with Tukey 1.5 IQR whiskers and jittered raw data. |
| `{scheme}_{suite}_timeseries.pdf` | 8 | Run duration per iteration for one scheme and suite, with one line per device. |

Devices: Apple M1 MacBook Pro, Apple M2 Pro MacBook Pro, Apple M4 Pro Mac mini,
and Apple M5 MacBook Pro.

Schemes: `bitchat`, `bitchat-refactored`, `swift-loggable`, and `swift-pesel`,
each with a Swift Testing suite and an XCTest suite.

Before generating plots, the script prints:

- iteration integrity check, expecting `n = 100` per series
- descriptive table with mean, median, sample standard deviation, CV, 95% CI, and D'Agostino-Pearson K2 normality-test p-value
- plot display unit per scheme

## `plot_benchmark.py`

Single-scheme plotting script. Use it to inspect one device and scheme, for
example `Results/<device>/swift-pesel`, without regenerating the full multi-device
plot set.

```bash
python3 Scripts/plot_benchmark.py Results/Mac17-2__Apple-M5__16-GB__MDE44ZE/swift-pesel
python3 Scripts/plot_benchmark.py Results/Mac16-11__Apple-M4-Pro__24-GB__MCX44D/bitchat --output-dir ./plots
```

By default, output is written to `<input-dir>/plots/`.

Generated files:

| File | Description |
|---|---|
| `{suite}_histogram.pdf` | Histogram and KDE for one suite. |
| `{suite}_mean_ci.pdf` | Mean plus 95% CI bar chart with sigma annotation. |
| `{suite}_timeseries.pdf` | Duration per iteration. |
| `{scheme}_histograms.pdf` | Combined histogram grid for all suites in the scheme. |
| `{scheme}_mean_ci.pdf` | Combined mean CI bar chart. |
| `{scheme}_timeseries.pdf` | Combined time series for all suites. |

The script prints mean, median, sample standard deviation, CV, min, max,
D'Agostino-Pearson K2 normality test, pairwise Mann-Whitney U and Welch t-tests,
rank-biserial `r`, Cohen's `d`, and the plot display unit.

## Statistical Notes

- 95% CI uses Student's t-distribution with `n - 1` degrees of freedom.
- Histogram bin width uses the Freedman-Diaconis rule.
- Normality testing uses D'Agostino-Pearson K2.
- Boxplot outlier detection uses Tukey fences.
- Pairwise tests include Mann-Whitney U and Welch's t-test.
- Plot colours use the Wong 2011 colourblind-safe palette.
