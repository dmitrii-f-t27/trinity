#!/usr/bin/env python3
"""
Zenodo v7.0 V15 Scientific Rigor Compliance Checker

Verifies that all bundles have required V15 features:
- Dual confidence intervals (95%, 99%)
- Effect size quantification (Cohen's d)
- Significance level indicators (emoji)
- Calibration metrics (ECE, Brier)
- Bootstrap method specification
"""

import re
from pathlib import Path
from typing import List, Dict, Tuple

def check_file(filepath: Path) -> Tuple[bool, List[str]]:
    """Check a single file for V15 compliance"""
    content = filepath.read_text()
    filename = filepath.name

    # Determine if this is an ML bundle (requires calibration metrics)
    # ML bundles: B001 (HSLM), B002 (FPGA+ML), B004 (Queen Lotus RL)
    # Non-ML bundles: B003 (TRI-27), B005 (VIBEE), B006 (Sacred formats), B007 (VSA library)
    is_ml_bundle = any(f'B{num:03d}' in filename for num in [1, 2, 4])
    is_parent = 'PARENT' in filename

    issues = []

    # Check 1: Dual confidence intervals
    ci_95 = r'95%.?CI|95%.?confidence'
    ci_99 = r'99%.?CI|99%.?confidence'
    if not re.search(ci_95, content, re.IGNORECASE):
        issues.append("Missing 95% CI")
    if not re.search(ci_99, content, re.IGNORECASE):
        issues.append("Missing 99% CI")

    # Check 2: Effect size (Cohen's d)
    cohens_d = r"Cohen['.]d|cohens d|Cohen['.]s d"
    if not re.search(cohens_d, content, re.IGNORECASE):
        issues.append("Missing Cohen's d effect size")

    # Check 3: Significance indicators
    # Check for common significance markers
    has_star = '*' in content and 'p < 0.001' in content
    has_check = 'check mark' in content or 'p < 0.01' in content
    has_triangle = 'p < 0.05' in content
    has_star_emoji = any(emoji in content for emoji in ['very_strict', 'strict', 'moderate', 'lenient'])
    if not (has_star or has_check or has_triangle or has_star_emoji):
        issues.append("Missing significance indicators")

    # Check 4: Calibration metrics (only for ML bundles)
    if is_ml_bundle or is_parent:
        ece = r'ECE|expected calibration'
        brier = r'Brier.?score|brier'
        if not re.search(ece, content, re.IGNORECASE):
            issues.append("Missing ECE calibration metric")
        if not re.search(brier, content, re.IGNORECASE):
            issues.append("Missing Brier Score metric")

        # Check 6: NeurIPS compliance (only for ML bundles)
        neurips = r'NeurIPS|neurips threshold|< 0.12|<0.12'
        if not re.search(neurips, content, re.IGNORECASE):
            issues.append("Missing NeurIPS compliance check")

    # Check 5: Bootstrap method
    bootstrap = r'bootstrap|10,000|10000 resample'
    if not re.search(bootstrap, content, re.IGNORECASE):
        issues.append("Missing bootstrap method specification")

    # Check 7: V15 keywords
    v15_keywords = ['V15', 'scientific rigor', 'Scientific Rigor']
    if not any(kw in content for kw in v15_keywords):
        issues.append("Missing V15 terminology")

    return (len(issues) == 0, issues)

def check_all_bundles() -> None:
    """Check all v7.0 enhanced descriptions"""
    docs_dir = Path('docs/research')
    bundles = ['B001', 'B002', 'B003', 'B004', 'B005', 'B006', 'B007', 'PARENT']

    print("=" * 60)
    print("V15 Scientific Rigor Compliance Check")
    print("=" * 60)
    print()

    all_passed = True
    total_issues = 0

    for bundle in bundles:
        filepath = docs_dir / f'zenodo_{bundle}_enhanced_v7.0.md'

        if not filepath.exists():
            print(f"  {bundle}: FILE NOT FOUND")
            all_passed = False
            continue

        passed, issues = check_file(filepath)

        if passed:
            print(f"  {bundle}: PASS ✅")
        else:
            print(f"  {bundle}: FAIL ❌")
            for issue in issues:
                print(f"    - {issue}")
            all_passed = False
            total_issues += len(issues)

    print()
    print("=" * 60)
    if all_passed:
        print("RESULT: ALL BUNDLES V15 COMPLIANT ✅")
    else:
        print(f"RESULT: {total_issues} ISSUES FOUND ❌")
    print("=" * 60)

def check_metadata_files() -> None:
    """Check all .zenodo.json v7.0 files"""
    docs_dir = Path('docs/research')
    bundles = ['B001', 'B002', 'B003', 'B004', 'B005', 'B006', 'B007', 'PARENT']

    print()
    print("=" * 60)
    print("Metadata Files Check")
    print("=" * 60)
    print()

    all_exist = True

    for bundle in bundles:
        filepath = docs_dir / f'.zenodo.{bundle}_v7.0.json'

        if not filepath.exists():
            print(f"  {bundle}: METADATA FILE NOT FOUND ❌")
            all_exist = False
        else:
            print(f"  {bundle}: ✅")

    print()
    print("=" * 60)
    if all_exist:
        print("RESULT: ALL METADATA FILES EXIST ✅")
    else:
        print("RESULT: SOME METADATA FILES MISSING ❌")
    print("=" * 60)

def check_supplementary_files() -> None:
    """Check supplementary materials exist"""
    print()
    print("=" * 60)
    print("Supplementary Materials Check")
    print("=" * 60)
    print()

    # Check data directory
    data_dir = Path('docs/research/data')
    required_csv = [
        'B001_training.csv', 'B001_calibration.csv',
        'B002_fpga_resources.csv', 'B002_calibration.csv',
        'B003_registers.csv', 'B003_metrics.csv',
        'B004_calibration.csv', 'B004_sample_efficiency.csv',
        'B005_vibee_metrics.csv',
        'B006_formats.csv',
        'B007_simd_benchmarks.csv', 'B007_noise_resilience.csv',
        'PARENT_cross_bundle_summary.csv'
    ]

    missing_csv = []
    for csv_file in required_csv:
        if not (data_dir / csv_file).exists():
            missing_csv.append(csv_file)

    print(f"  CSV files: {len(required_csv) - len(missing_csv)}/{len(required_csv)}")
    if missing_csv:
        print(f"  Missing: {missing_csv}")

    # Check figures directory
    figures_dir = Path('docs/research/figures')
    v15_figures = ['cross_bundle_effect_sizes.png', 'calibration_summary.png']

    missing_figures = []
    for fig in v15_figures:
        if not (figures_dir / fig).exists():
            missing_figures.append(fig)

    print(f"  V15 Figures: {len(v15_figures) - len(missing_figures)}/{len(v15_figures)}")
    if missing_figures:
        print(f"  Missing: {missing_figures}")

    print()
    print("=" * 60)
    if not missing_csv and not missing_figures:
        print("RESULT: ALL SUPPLEMENTARY MATERIALS READY ✅")
    else:
        print("RESULT: SOME SUPPLEMENTARY MATERIALS MISSING ❌")
    print("=" * 60)

def main():
    """Run all checks"""
    check_all_bundles()
    check_metadata_files()
    check_supplementary_files()

    print()
    print("Ready for Zenodo upload? Check checklist above.")
    print()

if __name__ == '__main__':
    main()
