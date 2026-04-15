# Benchmark Plot Generator

Generates thesis-quality plots from benchmark result JSON files.

## Requirements

```bash
pip3 install matplotlib scipy numpy
```

## Usage

```bash
python3 plot_benchmark.py <path-to-suite-directory> [--output-dir <dir>]
```

Point it at any directory that contains benchmark suite sub-directories (each holding `iteration-*.json` files):

```bash
python3 plot_benchmark.py m2-results/xcodebuild/swift-pesel
python3 plot_benchmark.py m2-results/xcodebuild/bitchat --output-dir ./plots
```

Plots are saved as PDF inside `<input-dir>/plots/` by default.

## Output

| File | Description |
|---|---|
| `*_boxplot.pdf` | Q1–Q3 box, 1.5×IQR whiskers, mean diamond |
| `*_violin.pdf` | Full distribution shape |
| `*_timeseries.pdf` | Duration per iteration — reveals warm-up or drift |
| `*_mean_ci.pdf` | Mean ± 95% CI bar chart with σ annotation |
| `*_histograms.pdf` | Per-suite histogram + KDE with mean/median lines |

Statistics printed to stdout: mean, median, std dev (sample), 95% CI, min, max, CV%, and outlier flags (|z| > 3).
