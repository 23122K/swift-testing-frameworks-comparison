#!/usr/bin/env python3
"""
Multi-device benchmark analysis for Swift Testing vs XCTest comparison.

Generates, for each (device, scheme, testSuite) triplet:
  - Histogram with KDE overlay
  - Boxplot with jitter

Generates, for each (scheme, testSuite) pair:
  - Time-series plot comparing all devices (one line per device)

Usage:
    python3 plot_results.py <Results-dir> [--output-dir <dir>]

Example:
    python3 plot_results.py ../Results
    python3 plot_results.py ../Results --output-dir ./plots
"""

import argparse
import json
import sys
from pathlib import Path

import matplotlib
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np
from scipy import stats

# ── rcParams ──────────────────────────────────────────────────────────────────
matplotlib.rcParams.update(
    {
        "font.family": "serif",
        "font.size": 11,
        "axes.titlesize": 12,
        "axes.labelsize": 11,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "legend.fontsize": 9,
        "figure.dpi": 150,
        "savefig.dpi": 300,
        "savefig.bbox": "tight",
        "axes.grid": True,
        "grid.alpha": 0.30,
        "grid.linestyle": "--",
    }
)

# Colourblind-safe palette (Wong 2011)
PALETTE = ["#0072B2", "#D55E00", "#009E73", "#CC79A7", "#E69F00", "#56B4E9", "#F0E442"]


# ── Helpers ───────────────────────────────────────────────────────────────────


def _fd_bins(arr: np.ndarray) -> int:
    """
    Freedman–Diaconis bin-count estimator.

    Bin width h = 2 · IQR · n^{-1/3} adapts to actual data spread and is
    robust to non-normality — preferred over fixed counts for academic work.
    Falls back to sqrt(n) when IQR = 0 (degenerate distribution).
    """
    iqr = float(np.subtract(*np.percentile(arr, [75, 25])))
    if iqr == 0:
        return max(5, int(np.ceil(np.sqrt(len(arr)))))
    bw = 2.0 * iqr / (len(arr) ** (1.0 / 3.0))
    n_bins = int(np.ceil((arr.max() - arr.min()) / bw))
    return max(5, min(60, n_bins))


def _smart_unit(values_s) -> tuple[float, str]:
    """Use ms display unit when all values are below 1 second."""
    return (1000.0, "ms") if max(values_s) < 1.0 else (1.0, "s")


def _device_label(device_dir: Path) -> str:
    """Short human-readable label from Report/hardware.json, or directory name."""
    hw_file = device_dir / "Report" / "hardware.json"
    if hw_file.exists():
        try:
            hw = json.loads(hw_file.read_text())
            chip = hw.get("chip", "")
            model = hw.get("modelName", "")
            mem = hw.get("memory", "")
            parts = [p for p in [chip, model, f"({mem})" if mem else ""] if p]
            if parts:
                return " · ".join(parts)
        except Exception:
            pass
    parts = device_dir.name.split("__")
    return parts[1].replace("-", " ") if len(parts) >= 2 else device_dir.name


def _device_short(label: str) -> str:
    """Filesystem-safe short chip name, e.g. 'Apple M4 Pro' → 'M4Pro'."""
    chip = label.split(" · ")[0]          # "Apple M4 Pro"
    return chip.replace("Apple ", "").replace(" ", "")


# ── Data loading ──────────────────────────────────────────────────────────────


def load_all(results_dir: Path) -> tuple[dict, list[str]]:
    """
    Returns
    -------
    data : dict[scheme][suite][device_label] = {"durations": list[float], "framework": str}
    device_order : list[str]  — stable ordering for consistent colour assignment
    """
    data: dict[str, dict[str, dict[str, dict]]] = {}
    device_order: list[str] = []

    for dev_dir in sorted(results_dir.iterdir()):
        if not dev_dir.is_dir() or dev_dir.name.startswith("."):
            continue

        label = _device_label(dev_dir)
        device_order.append(label)

        for scheme_dir in sorted(dev_dir.iterdir()):
            if not scheme_dir.is_dir() or scheme_dir.name == "Report":
                continue
            scheme = scheme_dir.name

            for suite_dir in sorted(scheme_dir.iterdir()):
                if not suite_dir.is_dir():
                    continue

                files = sorted(
                    suite_dir.glob("iteration-*.json"),
                    key=lambda p: int(p.stem.split("-")[1]),
                )
                if not files:
                    continue

                durations: list[float] = []
                framework = "Unknown"
                for f in files:
                    obj = json.loads(f.read_text())
                    durations.append(float(obj["testRunDuration"]))
                    framework = obj.get("framework", framework)

                data.setdefault(scheme, {}).setdefault(suite_dir.name, {})[label] = {
                    "durations": durations,
                    "framework": framework,
                }

    return data, device_order


# ── Iteration integrity check ─────────────────────────────────────────────────


def validate_iterations(data: dict, device_order: list[str]) -> None:
    """
    Verify every (scheme, suite, device) has the expected iteration count
    and no non-positive durations.
    """
    all_counts = [
        len(info["durations"])
        for suites in data.values()
        for devices in suites.values()
        for info in devices.values()
    ]
    expected = int(np.median(all_counts)) if all_counts else 100

    print("\n" + "=" * 90)
    print("ITERATION INTEGRITY CHECK")
    print("=" * 90)
    print(f"Expected iterations per series (median across all series): {expected}\n")

    header = f"{'Scheme':<22} {'Suite':<26} {'Device':<36} {'n':>5}  Status"
    print(header)
    print("-" * len(header))

    anomalies = 0
    for scheme in sorted(data):
        for suite in sorted(data[scheme]):
            for dev in device_order:
                if dev not in data[scheme][suite]:
                    print(f"{scheme:<22} {suite:<26} {dev:<36} {'—':>5}  MISSING")
                    anomalies += 1
                    continue
                info = data[scheme][suite][dev]
                n = len(info["durations"])
                n_non_pos = sum(1 for d in info["durations"] if d <= 0)
                if n != expected or n_non_pos:
                    status = f"WARN: n={n}" + (f", {n_non_pos} non-positive" if n_non_pos else "")
                    anomalies += 1
                else:
                    status = "OK"
                print(f"{scheme:<22} {suite:<26} {dev:<36} {n:>5}  {status}")

    print("-" * len(header))
    if anomalies == 0:
        print(f"\nAll {len(all_counts)} series passed — {expected} iterations each.\n")
    else:
        print(f"\n{anomalies} anomaly/anomalies found.\n")


# ── Statistics ────────────────────────────────────────────────────────────────


def compute_stats(durations: list[float]) -> dict:
    arr = np.array(durations)
    n = len(arr)
    mean = float(arr.mean())
    median = float(np.median(arr))
    std = float(arr.std(ddof=1))
    se = float(stats.sem(arr))
    ci95 = stats.t.interval(0.95, df=n - 1, loc=mean, scale=se)
    q1, q3 = map(float, np.percentile(arr, [25, 75]))
    iqr = q3 - q1

    # D'Agostino–Pearson K² normality test (appropriate for n ≥ 20).
    # Guard for zero-variance series (sub-ms suites with 1-ms resolution).
    if std < 1e-12 * max(abs(mean), 1.0):
        k2_stat, k2_p = float("nan"), float("nan")
    else:
        k2_stat, k2_p = stats.normaltest(arr)

    return {
        "n": n,
        "mean": mean,
        "median": median,
        "std": std,
        "se": se,
        "ci95_lo": float(ci95[0]),
        "ci95_hi": float(ci95[1]),
        "min": float(arr.min()),
        "max": float(arr.max()),
        "q1": q1,
        "q3": q3,
        "iqr": iqr,
        "cv": std / mean * 100,
        "normaltest_stat": float(k2_stat),
        "normaltest_p": float(k2_p),
    }


def print_summary_table(data: dict, device_order: list[str]) -> None:
    col = (
        f"{'Scheme':<22} {'Suite':<26} {'Device':<36} {'Fw':<16} {'n':>4} "
        f"{'Mean(s)':>9} {'Med(s)':>8} {'SD':>8} {'CV%':>6} "
        f"{'95% CI lo':>10} {'95% CI hi':>10} {'K²-p':>7}"
    )
    print("=" * len(col))
    print("DESCRIPTIVE STATISTICS")
    print("=" * len(col))
    print(col)
    print("-" * len(col))

    for scheme in sorted(data):
        for suite in sorted(data[scheme]):
            for dev in device_order:
                if dev not in data[scheme][suite]:
                    continue
                info = data[scheme][suite][dev]
                s = compute_stats(info["durations"])
                norm_str = (
                    f"{s['normaltest_p']:.3f}" + ("*" if s["normaltest_p"] < 0.05 else " ")
                    if not np.isnan(s["normaltest_p"])
                    else "  n/a"
                )
                print(
                    f"{scheme:<22} {suite:<26} {dev:<36} {info['framework']:<16} "
                    f"{s['n']:>4} {s['mean']:>9.4f} {s['median']:>8.4f} {s['std']:>8.5f} "
                    f"{s['cv']:>6.2f} {s['ci95_lo']:>10.4f} {s['ci95_hi']:>10.4f} {norm_str:>7}"
                )

    print("-" * len(col))
    print("  * K²-p < 0.05: significant departure from normality (D'Agostino–Pearson)\n")


# ── Per-suite individual plots ────────────────────────────────────────────────


def plot_histogram(
    device: str,
    scheme: str,
    suite: str,
    info: dict,
    output_dir: Path,
    color: str,
) -> None:
    """
    Histogram + KDE for a single (device, scheme, testSuite) series.

    Bin width via Freedman–Diaconis. KDE uses Scott's rule bandwidth.
    Mean and median are annotated as vertical lines.
    """
    durations = info["durations"]
    scale, unit = _smart_unit(durations)
    arr = np.array(durations) * scale
    s = compute_stats(durations)

    fig, ax = plt.subplots(figsize=(7, 4))

    bins = _fd_bins(arr)
    ax.hist(arr, bins=bins, color=color, alpha=0.50, edgecolor="white",
            linewidth=0.5, density=True)

    if arr.std() > 1e-12 * max(abs(arr.mean()), 1.0):
        kde = stats.gaussian_kde(arr)
        pad = (arr.max() - arr.min()) * 0.07 or arr.mean() * 0.05
        kde_x = np.linspace(arr.min() - pad, arr.max() + pad, 400)
        ax.plot(kde_x, kde(kde_x), color=color, linewidth=2.0,
                label="KDE (Scott's rule)")

    ax.axvline(s["mean"] * scale, color="black", linewidth=1.5, linestyle="--",
               label=f"Mean {s['mean'] * scale:.4f} {unit}")
    ax.axvline(s["median"] * scale, color="dimgrey", linewidth=1.5, linestyle=":",
               label=f"Median {s['median'] * scale:.4f} {unit}")

    norm_str = (
        f"K²={s['normaltest_stat']:.2f}, p={s['normaltest_p']:.3f}"
        if not np.isnan(s["normaltest_p"])
        else "K² n/a (zero variance)"
    )
    ax.set_xlabel(f"Duration ({unit})")
    ax.set_ylabel("Density")
    ax.set_title(
        f"{scheme} / {suite}  ·  {device}\n"
        f"({info['framework']}, n={s['n']})   {norm_str}"
    )
    ax.legend(fontsize=8)
    fig.tight_layout()

    short = _device_short(device)
    fname = output_dir / f"{short}_{scheme}_{suite}_histogram.pdf"
    fig.savefig(fname)
    plt.close(fig)
    print(f"  Saved: {fname}")


def plot_boxplot(
    device: str,
    scheme: str,
    suite: str,
    info: dict,
    output_dir: Path,
    color: str,
) -> None:
    """
    Boxplot with jitter for a single (device, scheme, testSuite) series.

    Tukey 1.5 × IQR whiskers. Jitter exposes all 100 individual run durations.
    """
    durations = info["durations"]
    scale, unit = _smart_unit(durations)
    arr = np.array(durations) * scale
    s = compute_stats(durations)

    fig, ax = plt.subplots(figsize=(3.5, 5))

    bp = ax.boxplot(
        [arr],
        patch_artist=True,
        notch=False,
        whis=1.5,
        flierprops=dict(marker="o", markerfacecolor="none", markersize=4,
                        linestyle="none", markeredgewidth=0.7),
        medianprops=dict(color="black", linewidth=2.0),
        widths=0.5,
    )
    bp["boxes"][0].set_facecolor(color)
    bp["boxes"][0].set_alpha(0.65)

    rng = np.random.default_rng(42)
    x_jitter = rng.uniform(-0.18, 0.18, size=len(arr)) + 1
    ax.scatter(x_jitter, arr, color=color, alpha=0.25, s=8, linewidths=0, zorder=3)

    ax.set_xticks([1])
    ax.set_xticklabels([_device_short(device)])
    ax.set_ylabel(f"Duration ({unit})")
    ax.set_title(
        f"{scheme} / {suite}\n"
        f"{device}\n"
        f"({info['framework']}, n={s['n']})\n"
        f"mean={s['mean'] * scale:.4f}  σ={s['std'] * scale:.5f}",
        fontsize=9,
    )
    fig.tight_layout()

    short = _device_short(device)
    fname = output_dir / f"{short}_{scheme}_{suite}_boxplot.pdf"
    fig.savefig(fname)
    plt.close(fig)
    print(f"  Saved: {fname}")


# ── Per-(scheme, suite) cross-device time series ──────────────────────────────


def plot_timeseries(
    scheme: str,
    suite: str,
    device_data: dict[str, dict],
    device_order: list[str],
    output_dir: Path,
) -> None:
    """
    Time-series for one (scheme, testSuite): one line per device.

    Reveals warm-up effects, run-to-run variability, and hardware-generation
    differences for the same test workload.
    """
    present = [d for d in device_order if d in device_data]
    if not present:
        return

    all_dur = [v for d in present for v in device_data[d]["durations"]]
    scale, unit = _smart_unit(all_dur)

    fig, ax = plt.subplots(figsize=(10, 4))

    for dev, color in zip(present, PALETTE):
        arr = np.array(device_data[dev]["durations"]) * scale
        iters = np.arange(1, len(arr) + 1)
        short = _device_short(dev)
        ax.plot(iters, arr, alpha=0.45, linewidth=0.9, color=color)
        ax.axhline(arr.mean(), linestyle="--", linewidth=1.2, color=color,
                   label=f"{short}  μ={arr.mean():.3f} {unit}")

    fw = device_data[present[0]]["framework"]
    ax.set_xlabel("Iteration")
    ax.set_ylabel(f"Duration ({unit})")
    ax.set_title(
        f"Run duration per iteration — {scheme} / {suite}  ({fw})\n"
        f"(dashed lines = mean; solid lines = individual iterations)"
    )
    ax.legend(loc="upper right", framealpha=0.9)
    ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True, nbins=10))
    fig.tight_layout()

    fname = output_dir / f"{scheme}_{suite}_timeseries.pdf"
    fig.savefig(fname)
    plt.close(fig)
    print(f"  Saved: {fname}")


# ── Entry point ───────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Per-suite histograms and boxplots, plus cross-device time series."
        )
    )
    parser.add_argument("results_dir", type=Path,
                        help="Path to the Results/ directory.")
    parser.add_argument("--output-dir", type=Path, default=None,
                        help="Output directory for PDFs (default: <results_dir>/../Plots).")
    args = parser.parse_args()

    results_dir = args.results_dir.resolve()
    if not results_dir.is_dir():
        sys.exit(f"[ERROR] Not a directory: {results_dir}")

    output_dir = (args.output_dir or results_dir.parent / "Plots").resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"\nLoading results from: {results_dir}")
    data, device_order = load_all(results_dir)

    print(f"Devices  ({len(device_order)}): {device_order}")
    print(f"Schemes  ({len(data)}): {sorted(data.keys())}")
    total = sum(len(devices) for suites in data.values() for devices in suites.values())
    print(f"Series total: {total}")

    validate_iterations(data, device_order)
    print_summary_table(data, device_order)

    print(f"Generating plots → {output_dir}\n")

    # ── Per-(device, scheme, suite): histogram + boxplot ───────────────────
    for scheme in sorted(data):
        for suite in sorted(data[scheme]):
            for dev, color in zip(device_order, PALETTE):
                if dev not in data[scheme][suite]:
                    continue
                info = data[scheme][suite][dev]
                plot_histogram(dev, scheme, suite, info, output_dir, color)
                plot_boxplot(dev, scheme, suite, info, output_dir, color)

    # ── Per-(scheme, suite): cross-device time series ─────────────────────
    print()
    for scheme in sorted(data):
        for suite in sorted(data[scheme]):
            plot_timeseries(scheme, suite, data[scheme][suite], device_order, output_dir)

    print("\nDone.")


if __name__ == "__main__":
    main()
