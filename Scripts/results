#!/usr/bin/env python3
"""Verify thesis evaluation results from raw JSON benchmark data.

The script recalculates the descriptive statistics reported in the thesis
evaluation chapter from the per-iteration JSON files in Results/. It also
prints the derived prose claims used in the chapter, and verifies the LoC/test
counts for swift-pesel and swift-loggable when their source checkouts are
available next to this repository.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import statistics
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


T_CRIT_975_DF_99 = 1.9842169515086827
MACHINE_ORDER = ["M1", "M2 Pro", "M4 Pro", "M5"]
SCHEME_ORDER = ["swift-pesel", "bitchat", "bitchat-refactored", "swift-loggable"]
XCTEST_TEST_PATTERN = r"^\s*func\s+test"
SWIFT_TESTING_TEST_PATTERN = r"^\s*@Test\b"


@dataclass(frozen=True)
class SeriesKey:
    machine: str
    scheme: str
    suite: str


@dataclass(frozen=True)
class SeriesStats:
    n: int
    mean_s: float
    sample_sd_s: float
    ci95_low_s: float
    ci95_high_s: float
    cv_percent: float
    min_s: float
    max_s: float
    median_s: float
    framework: str
    test_case_counts: tuple[int, ...]


def machine_label(device_dir: Path) -> str:
    hardware_path = device_dir / "Report" / "hardware.json"
    hardware = json.loads(hardware_path.read_text())
    return hardware["chip"].replace("Apple ", "")


def iteration_files(suite_dir: Path) -> list[Path]:
    return sorted(
        suite_dir.glob("iteration-*.json"),
        key=lambda path: int(path.stem.split("-")[1]),
    )


def compute_stats(values_s: list[float], framework: str, test_counts: Iterable[int]) -> SeriesStats:
    n = len(values_s)
    if n < 2:
        raise ValueError("At least two iterations are required")

    if n != 100:
        raise ValueError(
            f"Expected n=100 for the thesis t-interval calculation, got n={n}"
        )

    mean_s = statistics.fmean(values_s)
    sample_sd_s = statistics.stdev(values_s)
    standard_error = sample_sd_s / math.sqrt(n)
    ci95_low_s = mean_s - T_CRIT_975_DF_99 * standard_error
    ci95_high_s = mean_s + T_CRIT_975_DF_99 * standard_error

    return SeriesStats(
        n=n,
        mean_s=mean_s,
        sample_sd_s=sample_sd_s,
        ci95_low_s=ci95_low_s,
        ci95_high_s=ci95_high_s,
        cv_percent=sample_sd_s / mean_s * 100,
        min_s=min(values_s),
        max_s=max(values_s),
        median_s=statistics.median(values_s),
        framework=framework,
        test_case_counts=tuple(sorted(set(test_counts))),
    )


def load_results(results_dir: Path) -> dict[SeriesKey, SeriesStats]:
    series: dict[SeriesKey, SeriesStats] = {}

    for device_dir in sorted(path for path in results_dir.iterdir() if path.is_dir()):
        if device_dir.name.startswith("."):
            continue

        machine = machine_label(device_dir)
        for scheme_dir in sorted(path for path in device_dir.iterdir() if path.is_dir()):
            if scheme_dir.name == "Report":
                continue

            for suite_dir in sorted(path for path in scheme_dir.iterdir() if path.is_dir()):
                files = iteration_files(suite_dir)
                if not files:
                    continue

                durations: list[float] = []
                test_counts: list[int] = []
                framework = "Unknown"

                for file in files:
                    payload = json.loads(file.read_text())
                    durations.append(float(payload["testRunDuration"]))
                    test_counts.append(len(payload.get("testCases", [])))
                    framework = payload.get("framework", framework)

                key = SeriesKey(machine=machine, scheme=scheme_dir.name, suite=suite_dir.name)
                series[key] = compute_stats(durations, framework, test_counts)

    return series


def sorted_keys(series: dict[SeriesKey, SeriesStats]) -> list[SeriesKey]:
    def order(key: SeriesKey) -> tuple[int, int, str]:
        machine_index = MACHINE_ORDER.index(key.machine)
        scheme_index = SCHEME_ORDER.index(key.scheme)
        return machine_index, scheme_index, key.suite

    return sorted(series, key=order)


def print_performance_table(series: dict[SeriesKey, SeriesStats]) -> None:
    print("PERFORMANCE STATISTICS FROM RAW JSON")
    print(
        "Machine | Scheme | Suite | Framework | n | Mean | SD | 95% CI | CV% | Min | Max | Test case count"
    )
    for key in sorted_keys(series):
        stats = series[key]
        if key.scheme in {"swift-pesel", "swift-loggable"}:
            scale = 1000.0
            unit = "ms"
        else:
            scale = 1.0
            unit = "s"

        print(
            f"{key.machine} | {key.scheme} | {key.suite} | {stats.framework} | "
            f"{stats.n} | {stats.mean_s * scale:.3f} {unit} | "
            f"{stats.sample_sd_s * scale:.3f} {unit} | "
            f"[{stats.ci95_low_s * scale:.3f}, {stats.ci95_high_s * scale:.3f}] {unit} | "
            f"{stats.cv_percent:.2f} | {stats.min_s * scale:.3f} {unit} | "
            f"{stats.max_s * scale:.3f} {unit} | {list(stats.test_case_counts)}"
        )


def get(series: dict[SeriesKey, SeriesStats], machine: str, scheme: str, suite: str) -> SeriesStats:
    return series[SeriesKey(machine=machine, scheme=scheme, suite=suite)]


def print_derived_claims(series: dict[SeriesKey, SeriesStats]) -> None:
    print("\nDERIVED EVALUATION CLAIMS")

    for machine in MACHINE_ORDER:
        swift_testing = get(series, machine, "swift-pesel", "PeselTests").mean_s
        xctest = get(series, machine, "swift-pesel", "PeselXCTests").mean_s
        print(f"swift-pesel ratio {machine}: {swift_testing / xctest:.3f}x")

    for machine in MACHINE_ORDER:
        pre_fix = get(series, machine, "bitchat", "bitchatTests").mean_s
        original_xctest = get(series, machine, "bitchat", "bitchatXCTests").mean_s
        post_fix = get(series, machine, "bitchat-refactored", "bitchatTests").mean_s
        refactored_xctest = get(series, machine, "bitchat-refactored", "bitchatXCTests").mean_s

        pre_gap_s = pre_fix - original_xctest
        pre_gap_percent = pre_gap_s / original_xctest * 100
        post_faster_percent = (refactored_xctest - post_fix) / refactored_xctest * 100
        xctest_baseline_delta_ms = abs(refactored_xctest - original_xctest) * 1000

        print(
            f"bitchat {machine}: pre-fix gap {pre_gap_s:.3f} s "
            f"(+{pre_gap_percent:.1f}%); post-fix Swift Testing faster by "
            f"{post_faster_percent:.1f}%; refactored XCTest baseline delta "
            f"{xctest_baseline_delta_ms:.1f} ms"
        )

    for machine in MACHINE_ORDER:
        swift_testing = get(series, machine, "swift-loggable", "LoggableMacroTests")
        xctest = get(series, machine, "swift-loggable", "LoggableMacroXCTests")
        absolute_percent = abs(swift_testing.mean_s - xctest.mean_s) / xctest.mean_s * 100
        print(
            f"swift-loggable {machine}: mean difference {absolute_percent:.2f}%; "
            f"CV Swift Testing {swift_testing.cv_percent:.2f}%, "
            f"CV XCTest {xctest.cv_percent:.2f}%"
        )


def non_empty_swift_lines(directory: Path) -> int:
    return sum(
        1
        for file in directory.rglob("*.swift")
        for line in file.read_text().splitlines()
        if line.strip()
    )


def count_matching_lines(directory: Path, pattern: str) -> int:
    regex = re.compile(pattern)
    return sum(
        1
        for file in directory.rglob("*.swift")
        for line in file.read_text().splitlines()
        if regex.search(line)
    )


def count_pesel_arguments(pesel_swift_testing_file: Path) -> tuple[int, int]:
    text = pesel_swift_testing_file.read_text()
    valid_block = text.split('private static let valid = """', 1)[1].split('""".split', 1)[0]
    invalid_block = text.split('private static let invalid = #"""', 1)[1].split('"""#.split', 1)[0]
    valid_count = sum(1 for line in valid_block.splitlines() if line.strip())
    invalid_count = sum(1 for line in invalid_block.splitlines() if line.strip())
    return valid_count, invalid_count


def print_complexity_checks(pesel_tests_dir: Path, loggable_tests_dir: Path) -> None:
    print("\nSOURCE COMPLEXITY CHECKS")

    if pesel_tests_dir.exists():
        pesel_xctest = pesel_tests_dir / "PeselXCTests"
        pesel_swift_testing = pesel_tests_dir / "PeselTests"
        valid_count, invalid_count = count_pesel_arguments(
            pesel_swift_testing / "PeselTests.swift"
        )
        print(
            "swift-pesel XCTest: "
            f"{count_matching_lines(pesel_xctest, XCTEST_TEST_PATTERN)} tests, "
            f"{non_empty_swift_lines(pesel_xctest)} non-empty Swift lines"
        )
        print(
            "swift-pesel Swift Testing: "
            f"{count_matching_lines(pesel_swift_testing, SWIFT_TESTING_TEST_PATTERN)} tests, "
            f"{non_empty_swift_lines(pesel_swift_testing)} non-empty Swift lines, "
            f"{valid_count} valid arguments, {invalid_count} invalid-format arguments"
        )
    else:
        print(f"swift-pesel source checkout not found: {pesel_tests_dir}")

    if loggable_tests_dir.exists():
        loggable_xctest = loggable_tests_dir / "LoggableMacroXCTests"
        loggable_swift_testing = loggable_tests_dir / "LoggableMacroTests"
        print(
            "swift-loggable XCTest: "
            f"{count_matching_lines(loggable_xctest, XCTEST_TEST_PATTERN)} tests, "
            f"{non_empty_swift_lines(loggable_xctest)} non-empty Swift lines"
        )
        print(
            "swift-loggable Swift Testing: "
            f"{count_matching_lines(loggable_swift_testing, SWIFT_TESTING_TEST_PATTERN)} tests, "
            f"{non_empty_swift_lines(loggable_swift_testing)} non-empty Swift lines"
        )
    else:
        print(f"swift-loggable source checkout not found: {loggable_tests_dir}")


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    default_parent = repo_root.parent

    parser = argparse.ArgumentParser(
        description="Recalculate thesis evaluation statistics from raw JSON results."
    )
    parser.add_argument(
        "--results-dir",
        type=Path,
        default=repo_root / "Results",
        help="Path to the Results directory. Defaults to ../Results relative to this script.",
    )
    parser.add_argument(
        "--pesel-tests-dir",
        type=Path,
        default=default_parent / "swift-pesel" / "Tests",
        help="Optional swift-pesel Tests directory for LoC/test-count checks.",
    )
    parser.add_argument(
        "--loggable-tests-dir",
        type=Path,
        default=default_parent / "swift-loggable" / "Tests",
        help="Optional swift-loggable Tests directory for LoC/test-count checks.",
    )
    args = parser.parse_args()

    results_dir = args.results_dir.resolve()
    if not results_dir.is_dir():
        raise SystemExit(f"Results directory not found: {results_dir}")

    series = load_results(results_dir)
    print_performance_table(series)
    print_derived_claims(series)
    print_complexity_checks(
        args.pesel_tests_dir.resolve(),
        args.loggable_tests_dir.resolve(),
    )


if __name__ == "__main__":
    main()
