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


def plot_time_series_combined(suites: dict[str, dict], output_dir: Path, scheme: str) -> None:
    """All suites on one axes — combined time series."""
    flat = [v for s in suites.values() for v in s["durations"]]
    scale, unit = _smart_unit(flat)

    fig, ax = plt.subplots(figsize=(10, 4))
    for (name, info), color in zip(suites.items(), PALETTE):
        arr = np.array(info["durations"]) * scale
        ax.plot(np.arange(1, len(arr) + 1), arr, alpha=0.55, linewidth=0.8, color=color)
        ax.axhline(arr.mean(), linestyle="--", linewidth=1.2, color=color,
                   label=f"{name} (mean={arr.mean():.2f}{unit})")

    ax.set_xlabel("Iteration")
    ax.set_ylabel(f"Total test run duration ({unit})")
    ax.set_title(f"Run duration per iteration — {scheme}")
    ax.legend(loc="upper right", framealpha=0.9)
    ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True, nbins=10))

    out = output_dir / f"{scheme}_timeseries.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_mean_ci_combined(suites: dict[str, dict], output_dir: Path, scheme: str) -> None:
    """All suites as bars with 95% CI — combined mean CI chart."""
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

    for idx, (bar, s) in enumerate(zip(bars, stats_list)):
        ax.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + ci_hi[idx] + (means.max() * 0.02),
            f"σ={s['std'] * scale:.3f}",
            ha="center", va="bottom", fontsize=9,
        )

    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=15, ha="right")
    ax.set_ylabel(f"Mean duration ({unit})")
    ax.set_title(f"Mean test run duration ± 95% CI — {scheme}\n(σ = sample std dev)")
    ax.legend()
    ax.set_ylim(0, means.max() * 1.25)

    out = output_dir / f"{scheme}_mean_ci.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_histogram_combined(suites: dict[str, dict], output_dir: Path, scheme: str) -> None:
    """One subplot per suite in a single figure — combined histogram grid."""
    flat = [v for s in suites.values() for v in s["durations"]]
    scale, unit = _smart_unit(flat)
    n = len(suites)
    cols = min(n, 2)
    rows = (n + cols - 1) // cols

    fig, axes = plt.subplots(rows, cols, figsize=(cols * 5, rows * 3.5), squeeze=False)
    axes_flat = [ax for row in axes for ax in row]

    for ax, (name, info), color in zip(axes_flat, suites.items(), PALETTE):
        arr = np.array(info["durations"]) * scale
        s = info["stats"]
        bins = min(20, max(10, len(arr) // 5))
        ax.hist(arr, bins=bins, color=color, alpha=0.55, edgecolor="white",
                linewidth=0.5, density=True, label="Histogram")

        kde = stats.gaussian_kde(arr)
        pad = arr.std() * 0.5
        kde_x = np.linspace(arr.min() - pad, arr.max() + pad, 300)
        ax.plot(kde_x, kde(kde_x), color=color, linewidth=2, label="KDE (Scott's bw)")

        ax.axvline(s["mean"] * scale, color="black", linewidth=1.5, linestyle="--",
                   label=f"Mean={s['mean'] * scale:.3f}")
        ax.axvline(s["median"] * scale, color="grey", linewidth=1.5, linestyle=":",
                   label=f"Median={s['median'] * scale:.3f}")

        ax.set_xlabel(f"Duration ({unit})")
        ax.set_ylabel("Density")
        ax.set_title(f"{name}\n({info['framework']})")
        ax.legend(fontsize=8)

    for ax in axes_flat[n:]:
        ax.set_visible(False)

    fig.suptitle(f"Duration distributions — {scheme}", y=1.01)
    fig.tight_layout()
    out = output_dir / f"{scheme}_histograms.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_time_series(name: str, info: dict, output_dir: Path, color: str) -> None:
    """Run duration per iteration — reveals trends / warm-up effects."""
    scale, unit = _smart_unit(info["durations"])
    arr = np.array(info["durations"]) * scale

    fig, ax = plt.subplots(figsize=(10, 4))
    ax.plot(np.arange(1, len(arr) + 1), arr, alpha=0.55, linewidth=0.8, color=color)
    ax.axhline(arr.mean(), linestyle="--", linewidth=1.2, color=color,
               label=f"mean={arr.mean():.2f}{unit}")

    ax.set_xlabel("Iteration")
    ax.set_ylabel(f"Total test run duration ({unit})")
    ax.set_title(f"Run duration per iteration — {name} ({info['framework']})")
    ax.legend(loc="upper right", framealpha=0.9)
    ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True, nbins=10))

    out = output_dir / f"{name}_timeseries.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_mean_ci(name: str, info: dict, output_dir: Path, color: str) -> None:
    """Bar chart of mean with 95% CI and std dev annotation."""
    scale, unit = _smart_unit(info["durations"])
    s = info["stats"]

    mean = s["mean"] * scale
    ci_lo = mean - s["ci95_lo"] * scale
    ci_hi = s["ci95_hi"] * scale - mean
    std_scaled = s["std"] * scale

    fig, ax = plt.subplots(figsize=(3, 5))
    bar = ax.bar([0], [mean], color=color, alpha=0.75, edgecolor="black", linewidth=0.7)
    ax.errorbar([0], [mean], yerr=[[ci_lo], [ci_hi]], fmt="none", color="black",
                capsize=5, capthick=1.5, linewidth=1.5, label="95% CI")
    ax.text(
        bar[0].get_x() + bar[0].get_width() / 2,
        mean + ci_hi + (mean * 0.02),
        f"σ={std_scaled:.3f}",
        ha="center", va="bottom", fontsize=9,
    )

    ax.set_xticks([0])
    ax.set_xticklabels([name], rotation=15, ha="right")
    ax.set_ylabel(f"Mean duration ({unit})")
    ax.set_title(f"Mean ± 95% CI\n{name} ({info['framework']})")
    ax.legend()
    ax.set_ylim(0, (mean + ci_hi) * 1.25)

    out = output_dir / f"{name}_mean_ci.pdf"
    fig.savefig(out)
    plt.close(fig)
    print(f"  Saved: {out}")


def plot_histogram(name: str, info: dict, output_dir: Path, color: str) -> None:
    """Histogram with KDE for distribution shape."""
    scale, unit = _smart_unit(info["durations"])
    arr = np.array(info["durations"]) * scale
    s = info["stats"]

    fig, ax = plt.subplots(figsize=(6, 4))
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
    ax.set_title(f"{name} ({info['framework']})")
    ax.legend(fontsize=8)
    fig.tight_layout()

    out = output_dir / f"{name}_histograms.pdf"
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
    # Per-suite individual plots
    for (name, info), color in zip(suites.items(), PALETTE):
        plot_histogram(name, info, output_dir, color)
        plot_mean_ci(name, info, output_dir, color)
        plot_time_series(name, info, output_dir, color)
    # Combined plots across all suites
    plot_histogram_combined(suites, output_dir, suite_dir_name)
    plot_mean_ci_combined(suites, output_dir, suite_dir_name)
    plot_time_series_combined(suites, output_dir, suite_dir_name)

    print("\nDone.")


if __name__ == "__main__":
    main()
