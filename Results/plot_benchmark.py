#!/usr/bin/env python3
"""
Benchmark plot generator for Swift testing framework comparison.

Usage:
    python3 plot_benchmark.py <path-to-suite-directory> [--output-dir <dir>]

Example:
    python3 plot_benchmark.py ../xcodebuild/swift-pesel
    python3 plot_benchmark.py ../xcodebuild/bitchat --output-dir ./plots

The directory must contain subdirectories with `iteration-N.json` files,
each having a `testRunDuration` (seconds) and `framework` field.
"""

import argparse
import json
import os
import sys
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
from scipy import stats

matplotlib.rcParams.update(
    {
        "font.family": "serif",
        "font.size": 11,
        "axes.titlesize": 13,
        "axes.labelsize": 12,
        "xtick.labelsize": 10,
        "ytick.labelsize": 10,
        "legend.fontsize": 10,
        "figure.dpi": 150,
        "savefig.dpi": 300,
        "savefig.bbox": "tight",
        "axes.grid": True,
        "grid.alpha": 0.35,
        "grid.linestyle": "--",
    }
)

# Palette: colourblind-friendly (Wong 2011)
PALETTE = ["#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#56B4E9", "#F0E442"]


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------


def load_suite(suite_dir: Path) -> tuple[list[float], str]:
    """Return (sorted durations, framework name) for a single suite directory."""
    files = sorted(
        suite_dir.glob("iteration-*.json"),
        key=lambda p: int(p.stem.split("-")[1]),
    )
    if not files:
        raise ValueError(f"No iteration-*.json files found in {suite_dir}")

    durations: list[float] = []
    framework = "Unknown"
    for f in files:
        with f.open() as fh:
            data = json.load(fh)
        durations.append(float(data["testRunDuration"]))
        framework = data.get("framework", framework)

    return durations, framework


def load_directory(input_dir: Path) -> dict[str, dict]:
    """
    Scan *input_dir* for sub-directories that contain iteration JSON files.
    Returns a dict keyed by suite name:
        {
            "PeselTests": {"durations": [...], "framework": "Swift Testing"},
            "PeselXCTests": {"durations": [...], "framework": "XCTest"},
        }
    """
    suites: dict[str, dict] = {}
    for entry in sorted(input_dir.iterdir()):
        if not entry.is_dir() or entry.name.startswith("."):
            continue
        try:
            durations, framework = load_suite(entry)
        except ValueError:
            continue
        suites[entry.name] = {"durations": durations, "framework": framework}

    if not suites:
        sys.exit(f"[ERROR] No benchmark suites found in {input_dir}")
    return suites


# ---------------------------------------------------------------------------
# Statistics
# ---------------------------------------------------------------------------


def compute_stats(durations: list[float]) -> dict:
    arr = np.array(durations)
    mean = arr.mean()
    median = np.median(arr)
    std = arr.std(ddof=1)          # sample std dev (n-1)
    se = stats.sem(arr)            # standard error of the mean
    ci95 = stats.t.interval(0.95, df=len(arr) - 1, loc=mean, scale=se)
    q1, q3 = np.percentile(arr, [25, 75])
    iqr = q3 - q1

    # Outlier flag: z-score filter |z| > 3 (informational only, not a formal test)
    # Note: with n=100, ~0.27 false positives are expected at this threshold.
    z_scores = np.abs((arr - mean) / std)
    outlier_mask = z_scores > 3.0

    return {
        "n": len(arr),
        "mean": mean,
        "median": median,
        "std": std,
        "se": se,
        "ci95_lo": ci95[0],
        "ci95_hi": ci95[1],
        "min": arr.min(),
        "max": arr.max(),
        "q1": q1,
        "q3": q3,
        "iqr": iqr,
        "outliers": arr[outlier_mask].tolist(),
        "outlier_indices": np.where(outlier_mask)[0].tolist(),
        "cv": std / mean * 100,   # coefficient of variation in %
    }


def print_stats_table(suites: dict[str, dict]) -> None:
    header = f"{'Suite':<22} {'Framework':<16} {'n':>4} {'Mean (s)':>10} {'Median (s)':>11} {'Std Dev':>9} {'CV%':>6} {'Min':>8} {'Max':>8}"
    print("\n" + "=" * len(header))
    print(header)
    print("=" * len(header))
    for name, info in suites.items():
        s = info["stats"]
        print(
            f"{name:<22} {info['framework']:<16} {s['n']:>4} "
            f"{s['mean']:>10.4f} {s['median']:>11.4f} {s['std']:>9.5f} "
            f"{s['cv']:>6.2f} {s['min']:>8.4f} {s['max']:>8.4f}"
        )
        if s["outliers"]:
            idx_str = ", ".join(
                f"iter-{i + 1}={v:.4f}s"
                for i, v in zip(s["outlier_indices"], s["outliers"])
            )
            print(f"  {'':22}  ^ outliers (|z|>3): {idx_str}")
    print("=" * len(header) + "\n")


# ---------------------------------------------------------------------------
# Plots
# ---------------------------------------------------------------------------


def _smart_unit(values_s: list[float]) -> tuple[float, str]:
    """Return (scale_factor, unit_label). Chooses ms when all values < 1 s."""
    if max(values_s) < 1.0:
        return 1000.0, "ms"
    return 1.0, "s"


def plot_boxplot(suites: dict[str, dict], output_dir: Path, suite_dir_name: str) -> None:
    """Classic box-and-whisker for comparing suites."""
    names = list(suites.keys())
    all_vals = [s["durations"] for s in suites.values()]

    # Determine unit based on overall range
    flat = [v for sub in all_vals for v in sub]
    scale, unit = _smart_unit(flat)

    fig, ax = plt.subplots(figsize=(max(6, len(names) * 2.2), 5))
    bp = ax.boxplot(
        [np.array(v) * scale for v in all_vals],
        patch_artist=True,
        notch=False,
        widths=0.5,
        medianprops=dict(color="black", linewidth=2),
        whiskerprops=dict(linewidth=1.2),
        capprops=dict(linewidth=1.2),
        flierprops=dict(marker="o", markersize=4, alpha=0.5),
    )
    for patch, color in zip(bp["boxes"], PALETTE):
        patch.set_facecolor(color)
        patch.set_alpha(0.75)

    # Overlay mean markers
    for i, vals in enumerate(all_vals, start=1):
        mean_scaled = np.mean(vals) * scale
        ax.plot(i, mean_scaled, marker="D", color="white", markersize=7, zorder=5)
        ax.plot(i, mean_scaled, marker="D", color=PALETTE[i - 1], markersize=5,
                markeredgecolor="black", markeredgewidth=0.8, zorder=6,
                label=f"{names[i-1]} mean={mean_scaled:.2f}{unit}")

    ax.set_xticks(range(1, len(names) + 1))
    ax.set_xticklabels(names, rotation=15, ha="right")
    ax.set_ylabel(f"Total test run duration ({unit})")
    ax.set_title(f"Test run duration — {suite_dir_name}\n(box: Q1–Q3, whiskers: 1.5×IQR, ◆ mean)")
    ax.legend(loc="upper right", framealpha=0.9)

    out = output_dir / f"{suite_dir_name}_boxplot.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_violin(suites: dict[str, dict], output_dir: Path, suite_dir_name: str) -> None:
    """Violin plot — shows full distribution shape."""
    names = list(suites.keys())
    all_vals = [s["durations"] for s in suites.values()]
    flat = [v for sub in all_vals for v in sub]
    scale, unit = _smart_unit(flat)

    fig, ax = plt.subplots(figsize=(max(6, len(names) * 2.2), 5))
    parts = ax.violinplot(
        [np.array(v) * scale for v in all_vals],
        positions=range(1, len(names) + 1),
        showmedians=True,
        showextrema=True,
    )
    for i, (body, color) in enumerate(zip(parts["bodies"], PALETTE)):
        body.set_facecolor(color)
        body.set_alpha(0.6)
    parts["cmedians"].set_color("black")
    parts["cmedians"].set_linewidth(2)
    parts["cmaxes"].set_linewidth(1.2)
    parts["cmins"].set_linewidth(1.2)
    parts["cbars"].set_linewidth(1.2)

    # Mean markers
    for i, vals in enumerate(all_vals, start=1):
        ax.scatter(i, np.mean(vals) * scale, marker="D", s=40, color="white",
                   edgecolors=PALETTE[i - 1], linewidths=1.5, zorder=5)

    ax.set_xticks(range(1, len(names) + 1))
    ax.set_xticklabels(names, rotation=15, ha="right")
    ax.set_ylabel(f"Total test run duration ({unit})")
    ax.set_title(f"Duration distribution (violin, KDE Scott's bw) — {suite_dir_name}\n(line = median, ◆ = mean)")

    out = output_dir / f"{suite_dir_name}_violin.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_time_series(suites: dict[str, dict], output_dir: Path, suite_dir_name: str) -> None:
    """Run duration per iteration — reveals trends / warm-up effects."""
    flat = [v for s in suites.values() for v in s["durations"]]
    scale, unit = _smart_unit(flat)

    fig, ax = plt.subplots(figsize=(10, 4))
    for (name, info), color in zip(suites.items(), PALETTE):
        arr = np.array(info["durations"]) * scale
        iterations = np.arange(1, len(arr) + 1)
        ax.plot(iterations, arr, alpha=0.55, linewidth=0.8, color=color)
        ax.axhline(arr.mean(), linestyle="--", linewidth=1.2, color=color,
                   label=f"{name} (mean={arr.mean():.2f}{unit})")

    ax.set_xlabel("Iteration")
    ax.set_ylabel(f"Total test run duration ({unit})")
    ax.set_title(f"Run duration per iteration — {suite_dir_name}")
    ax.legend(loc="upper right", framealpha=0.9)
    ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True, nbins=10))

    out = output_dir / f"{suite_dir_name}_timeseries.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_mean_ci(suites: dict[str, dict], output_dir: Path, suite_dir_name: str) -> None:
    """Bar chart of means with 95% confidence intervals and std dev annotations."""
    names = list(suites.keys())
    stats_list = [s["stats"] for s in suites.values()]

    flat = [v for s in suites.values() for v in s["durations"]]
    scale, unit = _smart_unit(flat)

    means = np.array([s["mean"] for s in stats_list]) * scale
    ci_lo = means - np.array([s["ci95_lo"] for s in stats_list]) * scale
    ci_hi = np.array([s["ci95_hi"] for s in stats_list]) * scale - means

    x = np.arange(len(names))
    fig, ax = plt.subplots(figsize=(max(5, len(names) * 1.8), 5))
    bars = ax.bar(x, means, color=PALETTE[: len(names)], alpha=0.75,
                  edgecolor="black", linewidth=0.7)
    ax.errorbar(x, means, yerr=[ci_lo, ci_hi], fmt="none", color="black",
                capsize=5, capthick=1.5, linewidth=1.5, label="95% CI")

    # Annotate with std dev above each CI bar
    for idx, (bar, s) in enumerate(zip(bars, stats_list)):
        std_scaled = s["std"] * scale
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + ci_hi[idx] + (means.max() * 0.02),
            f"σ={std_scaled:.3f}",
            ha="center", va="bottom", fontsize=9,
        )

    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15, ha="right")
    ax.set_ylabel(f"Mean duration ({unit})")
    ax.set_title(f"Mean test run duration ± 95% CI — {suite_dir_name}\n(σ = sample std dev)")
    ax.legend()
    ax.set_ylim(0, means.max() * 1.25)

    out = output_dir / f"{suite_dir_name}_mean_ci.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_histogram(suites: dict[str, dict], output_dir: Path, suite_dir_name: str) -> None:
    """Overlapping histograms with KDE for distribution shape."""
    flat = [v for s in suites.values() for v in s["durations"]]
    scale, unit = _smart_unit(flat)
    n_suites = len(suites)
    cols = min(n_suites, 2)
    rows = (n_suites + cols - 1) // cols

    fig, axes = plt.subplots(rows, cols, figsize=(cols * 5, rows * 3.5), squeeze=False)
    axes_flat = [ax for row in axes for ax in row]

    for ax, (name, info), color in zip(axes_flat, suites.items(), PALETTE):
        arr = np.array(info["durations"]) * scale
        s = info["stats"]
        bins = min(20, max(10, len(arr) // 5))
        ax.hist(arr, bins=bins, color=color, alpha=0.55, edgecolor="white",
                linewidth=0.5, density=True, label="Histogram")

        # KDE overlay — bandwidth selected automatically via Scott's rule
        kde = stats.gaussian_kde(arr)  # bw_method='scott' (default)
        pad = arr.std() * 0.5
        kde_x = np.linspace(arr.min() - pad, arr.max() + pad, 300)
        ax.plot(kde_x, kde(kde_x), color=color, linewidth=2, label="KDE (Scott's bw)")

        # Mean / median lines
        ax.axvline(s["mean"] * scale, color="black", linewidth=1.5, linestyle="--",
                   label=f"Mean={s['mean'] * scale:.3f}")
        ax.axvline(s["median"] * scale, color="grey", linewidth=1.5, linestyle=":",
                   label=f"Median={s['median'] * scale:.3f}")

        ax.set_xlabel(f"Duration ({unit})")
        ax.set_ylabel("Density")
        ax.set_title(f"{name}\n({info['framework']})")
        ax.legend(fontsize=8)

    # Hide unused axes
    for ax in axes_flat[n_suites:]:
        ax.set_visible(False)

    fig.suptitle(f"Duration distribution histograms — {suite_dir_name}", y=1.01)
    fig.tight_layout()
    out = output_dir / f"{suite_dir_name}_histograms.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate benchmark plots for Swift testing framework comparison."
    )
    parser.add_argument(
        "input_dir",
        type=Path,
        help="Directory containing benchmark suite sub-directories with iteration-*.json files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Directory to save plots (default: <input_dir>/plots).",
    )
    args = parser.parse_args()

    input_dir = args.input_dir.resolve()
    if not input_dir.is_dir():
        sys.exit(f"[ERROR] Not a directory: {input_dir}")

    output_dir = (args.output_dir or input_dir / "plots").resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    suite_dir_name = input_dir.name
    print(f"\nLoading benchmarks from: {input_dir}")
    suites = load_directory(input_dir)

    # Attach stats
    for name, info in suites.items():
        info["stats"] = compute_stats(info["durations"])

    print_stats_table(suites)

    print(f"Generating plots → {output_dir}")
    plot_boxplot(suites, output_dir, suite_dir_name)
    plot_violin(suites, output_dir, suite_dir_name)
    plot_time_series(suites, output_dir, suite_dir_name)
    plot_mean_ci(suites, output_dir, suite_dir_name)
    plot_histogram(suites, output_dir, suite_dir_name)

    print("\nDone.")


if __name__ == "__main__":
    main()
