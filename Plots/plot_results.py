#!/usr/bin/env python3
"""
Multi-device benchmark analysis for Swift Testing vs XCTest comparison.

For each (scheme, testSuite) combination it generates:
  - Histogram with KDE overlay — one subplot per device, shared x-axis
  - Boxplot with jitter — one box per device (Tukey 1.5 × IQR whiskers)

At the end it generates a single cross-device time-series summary figure:
  rows = schemes, cols = test suites (Swift Testing | XCTest), lines = devices.

Iteration integrity is verified before any plots are produced.

Usage:
    python3 plot_results.py <Results-dir> [--output-dir <dir>]

Example:
    python3 plot_results.py ../Results
    python3 plot_results.py ../Results --output-dir ./plots/multi-device
"""

import argparse
import json
import re
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

    Bin width h = 2 · IQR · n^{-1/3} is robust to non-normality and adapts to
    actual data spread — preferred over arbitrary fixed counts for academic work.
    Falls back to sqrt(n) when IQR = 0 (degenerate distribution).
    """
    iqr = float(np.subtract(*np.percentile(arr, [75, 25])))
    if iqr == 0:
        return max(5, int(np.ceil(np.sqrt(len(arr)))))
    bw = 2.0 * iqr / (len(arr) ** (1.0 / 3.0))
    n_bins = int(np.ceil((arr.max() - arr.min()) / bw))
    return max(5, min(60, n_bins))


def _smart_unit(values_s) -> tuple[float, str]:
    """Choose ms display unit when all values are below 1 second."""
    return (1000.0, "ms") if max(values_s) < 1.0 else (1.0, "s")


def _device_label(device_dir: Path) -> str:
    """
    Derive a short human-readable label.
    Reads Report/hardware.json when available; otherwise parses the directory name.
    """
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
    # Fallback: "Mac16-11__Apple-M4-Pro__24-GB__MCX44D" → "Apple M4 Pro"
    parts = device_dir.name.split("__")
    return parts[1].replace("-", " ") if len(parts) >= 2 else device_dir.name


# ── Data loading ──────────────────────────────────────────────────────────────


def load_all(results_dir: Path) -> tuple[dict, list[str]]:
    """
    Walk Results/<device>/<scheme>/<suite>/iteration-*.json.

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
    Verify that every (scheme, suite, device) triplet:
      • Has the expected number of iterations (median across all series)
      • Contains no non-positive durations

    Prints a full table and a pass/fail summary.
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
    print(f"Expected iterations per series (median across all 32 series): {expected}\n")

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
        print(f"\n{anomalies} anomaly/anomalies found. Review WARN/MISSING rows above.\n")


# ── Statistics ────────────────────────────────────────────────────────────────


def compute_stats(durations: list[float]) -> dict:
    """
    Descriptive statistics with 95% CI (Student's t, n-1 df) and
    D'Agostino–Pearson K² normality test.
    """
    arr = np.array(durations)
    n = len(arr)
    mean = float(arr.mean())
    median = float(np.median(arr))
    std = float(arr.std(ddof=1))   # Bessel-corrected
    se = float(stats.sem(arr))
    ci95 = stats.t.interval(0.95, df=n - 1, loc=mean, scale=se)
    q1, q3 = map(float, np.percentile(arr, [25, 75]))
    iqr = q3 - q1

    # Normality: D'Agostino–Pearson K² (appropriate for n ≥ 20).
    # Guard against zero-variance distributions (e.g. a sub-ms suite whose
    # timer resolution is 1 ms, so every run records the same value).
    # Use a relative tolerance rather than exact equality to handle
    # floating-point representation noise in near-constant series.
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
    """Print a compact descriptive-statistics table for all 32 series."""
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
                norm_str = f"{s['normaltest_p']:.3f}" + ("*" if s["normaltest_p"] < 0.05 else " ")
                print(
                    f"{scheme:<22} {suite:<26} {dev:<36} {info['framework']:<16} "
                    f"{s['n']:>4} {s['mean']:>9.4f} {s['median']:>8.4f} {s['std']:>8.5f} "
                    f"{s['cv']:>6.2f} {s['ci95_lo']:>10.4f} {s['ci95_hi']:>10.4f} {norm_str:>7}"
                )

    print("-" * len(col))
    print("  * K²-p < 0.05: significant departure from normality (D'Agostino–Pearson)\n")


# ── Per-suite plots ───────────────────────────────────────────────────────────


def plot_histograms(
    scheme: str,
    suite: str,
    device_data: dict[str, dict],
    device_order: list[str],
    output_dir: Path,
) -> None:
    """
    Histogram + KDE for each device, arranged in a grid with a shared x-axis.

    Using a shared x-axis enables direct visual comparison of the location and
    spread of each device's distribution.  Bin width follows Freedman–Diaconis.
    KDE uses Scott's rule bandwidth (scipy default).
    """
    present = [d for d in device_order if d in device_data]
    if not present:
        return

    all_dur = [v for d in present for v in device_data[d]["durations"]]
    scale, unit = _smart_unit(all_dur)

    cols = min(len(present), 2)
    rows = (len(present) + cols - 1) // cols
    fig, axes = plt.subplots(
        rows, cols, figsize=(cols * 5.8, rows * 4.0), sharex=True, squeeze=False
    )
    axes_flat = [ax for row in axes for ax in row]

    x_all = np.array(all_dur) * scale
    pad = (x_all.max() - x_all.min()) * 0.07

    for ax, dev, color in zip(axes_flat, present, PALETTE):
        arr = np.array(device_data[dev]["durations"]) * scale
        s = compute_stats(device_data[dev]["durations"])
        bins = _fd_bins(arr)

        ax.hist(
            arr, bins=bins, color=color, alpha=0.50,
            edgecolor="white", linewidth=0.5, density=True,
        )

        # KDE — Scott's rule bandwidth (scipy default for gaussian_kde).
        # Skip KDE for zero-variance series (bw would be ~0 → undefined).
        if arr.std() > 1e-12 * max(abs(arr.mean()), 1.0):
            kde = stats.gaussian_kde(arr)
            kde_x = np.linspace(x_all.min() - pad, x_all.max() + pad, 400)
            ax.plot(kde_x, kde(kde_x), color=color, linewidth=2.0,
                    label="KDE (Scott's rule)")

        ax.axvline(
            s["mean"] * scale, color="black", linewidth=1.5, linestyle="--",
            label=f"Mean {s['mean'] * scale:.3f} {unit}",
        )
        ax.axvline(
            s["median"] * scale, color="dimgrey", linewidth=1.5, linestyle=":",
            label=f"Median {s['median'] * scale:.3f} {unit}",
        )

        norm_annot = f"K²={s['normaltest_stat']:.2f}, p={s['normaltest_p']:.3f}"
        ax.set_title(
            f"{dev}\n({device_data[dev]['framework']})   {norm_annot}",
            fontsize=9,
        )
        ax.set_xlabel(f"Duration ({unit})")
        ax.set_ylabel("Density")
        ax.legend(fontsize=7)

    for ax in axes_flat[len(present) :]:
        ax.set_visible(False)

    fig.suptitle(f"Duration distributions — {scheme} / {suite}", y=1.01, fontsize=12)
    fig.tight_layout()

    fname = output_dir / f"{scheme}_{suite}_histograms.pdf"
    fig.savefig(fname)
    plt.close(fig)
    print(f"  Saved: {fname}")


def plot_boxplots(
    scheme: str,
    suite: str,
    device_data: dict[str, dict],
    device_order: list[str],
    output_dir: Path,
) -> None:
    """
    Side-by-side boxplots (Tukey 1.5 × IQR whiskers) with jittered raw data.

    The jitter layer exposes the full empirical distribution (n = 100 per box).
    Tukey fences are the standard for exploratory boxplots in academic work.
    """
    present = [d for d in device_order if d in device_data]
    if not present:
        return

    all_dur = [v for d in present for v in device_data[d]["durations"]]
    scale, unit = _smart_unit(all_dur)

    data_scaled = [np.array(device_data[d]["durations"]) * scale for d in present]
    colors = PALETTE[: len(present)]

    fig, ax = plt.subplots(figsize=(max(5, len(present) * 2.5), 5))

    bp = ax.boxplot(
        data_scaled,
        patch_artist=True,
        notch=False,
        whis=1.5,
        flierprops=dict(
            marker="o",
            markerfacecolor="none",
            markersize=4,
            linestyle="none",
            markeredgewidth=0.7,
        ),
        medianprops=dict(color="black", linewidth=2.0),
        widths=0.5,
    )
    for patch, color in zip(bp["boxes"], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.65)

    # Jitter overlay — individual run durations
    rng = np.random.default_rng(42)
    for i, (arr, color) in enumerate(zip(data_scaled, colors), start=1):
        x_jitter = rng.uniform(-0.20, 0.20, size=len(arr)) + i
        ax.scatter(x_jitter, arr, color=color, alpha=0.22, s=8,
                   linewidths=0, zorder=3)

    ax.set_xticks(range(1, len(present) + 1))
    ax.set_xticklabels(present, rotation=20, ha="right")
    ax.set_ylabel(f"Test run duration ({unit})")
    ax.set_title(
        f"Test run duration by device — {scheme} / {suite}\n"
        f"(whiskers = 1.5 × IQR; circles = individual runs; n = 100 per device)"
    )
    fig.tight_layout()

    fname = output_dir / f"{scheme}_{suite}_boxplot.pdf"
    fig.savefig(fname)
    plt.close(fig)
    print(f"  Saved: {fname}")


# ── Cross-device time-series summary ─────────────────────────────────────────


def _suite_sort_key(name: str) -> int:
    """Sort Swift Testing suites before XCTest suites."""
    return 1 if "XCTest" in name else 0


def plot_cross_device_timeseries(
    data: dict, device_order: list[str], output_dir: Path
) -> None:
    """
    One figure combining all schemes and test suites.

    Layout: rows = schemes (alphabetical), cols = test suites sorted so that
    the Swift Testing suite always appears before the paired XCTest suite.
    Each subplot shows one line per device, making hardware-generation trends
    and within-suite variability immediately comparable.

    A single legend is placed outside the grid to avoid duplication.
    """
    schemes = sorted(data.keys())

    # Per-scheme suite lists, Swift Testing before XCTest
    suite_lists = {s: sorted(data[s].keys(), key=_suite_sort_key) for s in schemes}
    max_cols = max(len(v) for v in suite_lists.values())

    fig, axes = plt.subplots(
        len(schemes),
        max_cols,
        figsize=(max_cols * 6.5, len(schemes) * 3.4),
        squeeze=False,
    )

    for row_idx, scheme in enumerate(schemes):
        suites = suite_lists[scheme]
        for col_idx in range(max_cols):
            ax = axes[row_idx][col_idx]
            if col_idx >= len(suites):
                ax.set_visible(False)
                continue

            suite = suites[col_idx]
            device_data = data[scheme][suite]
            present = [d for d in device_order if d in device_data]

            all_dur = [v for d in present for v in device_data[d]["durations"]]
            scale, unit = _smart_unit(all_dur)

            for dev, color in zip(present, PALETTE):
                arr = np.array(device_data[dev]["durations"]) * scale
                iters = np.arange(1, len(arr) + 1)
                ax.plot(iters, arr, alpha=0.40, linewidth=0.9, color=color)
                ax.axhline(
                    arr.mean(),
                    linestyle="--",
                    linewidth=1.2,
                    color=color,
                    # Chip name only, e.g. "Apple M4 Pro"
                    label=dev.split(" · ")[0].strip(),
                )

            fw = device_data[present[0]]["framework"] if present else ""
            ax.set_title(f"{scheme}\n{suite}  ({fw})", fontsize=9)
            ax.set_xlabel("Iteration", fontsize=8)
            ax.set_ylabel(f"Duration ({unit})", fontsize=8)
            ax.tick_params(labelsize=7)
            ax.xaxis.set_major_locator(ticker.MaxNLocator(integer=True, nbins=6))

    # Shared legend below the figure
    handles, labels = [], []
    for ax_row in axes:
        for ax in ax_row:
            if ax.get_visible():
                h, l = ax.get_legend_handles_labels()
                for hi, li in zip(h, l):
                    if li not in labels:
                        handles.append(hi)
                        labels.append(li)
                break
        if handles:
            break

    fig.legend(
        handles,
        labels,
        loc="lower center",
        ncol=len(device_order),
        fontsize=9,
        framealpha=0.9,
        bbox_to_anchor=(0.5, -0.02),
    )

    fig.suptitle(
        "Test run duration per iteration — all schemes × all devices\n"
        "(dashed lines = mean; each solid line = one iteration series)",
        y=1.01,
        fontsize=12,
    )
    fig.tight_layout(rect=[0, 0.04, 1, 1])

    fname = output_dir / "cross_device_timeseries.pdf"
    fig.savefig(fname)
    plt.close(fig)
    print(f"\n  Saved: {fname}")


# ── Entry point ───────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Multi-device benchmark analysis: histograms, boxplots, and "
            "cross-device time-series for each (scheme, testSuite) combination."
        )
    )
    parser.add_argument(
        "results_dir",
        type=Path,
        help="Path to the Results/ directory.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Output directory for PDFs (default: <results_dir>/../Plots).",
    )
    args = parser.parse_args()

    results_dir = args.results_dir.resolve()
    if not results_dir.is_dir():
        sys.exit(f"[ERROR] Not a directory: {results_dir}")

    output_dir = (
        args.output_dir or results_dir.parent / "Plots"
    ).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"\nLoading results from: {results_dir}")
    data, device_order = load_all(results_dir)

    print(f"Devices  ({len(device_order)}): {device_order}")
    print(f"Schemes  ({len(data)}): {sorted(data.keys())}")
    total_series = sum(
        len(devices) for suites in data.values() for devices in suites.values()
    )
    print(f"Series total: {total_series}")

    # ── Integrity check ────────────────────────────────────────────────────
    validate_iterations(data, device_order)

    # ── Descriptive statistics ─────────────────────────────────────────────
    print_summary_table(data, device_order)

    # ── Per-(scheme, suite) plots ──────────────────────────────────────────
    print(f"Generating plots → {output_dir}\n")
    for scheme in sorted(data):
        for suite in sorted(data[scheme]):
            device_data = data[scheme][suite]
            plot_histograms(scheme, suite, device_data, device_order, output_dir)
            plot_boxplots(scheme, suite, device_data, device_order, output_dir)

    # ── Cross-device time-series ───────────────────────────────────────────
    plot_cross_device_timeseries(data, device_order, output_dir)

    print("\nDone.")


if __name__ == "__main__":
    main()
