#!/usr/bin/env python3
"""
Zenodo v7.0 — Pre-Upload Verification Script

This script verifies all components are ready for Zenodo upload.
Run this before attempting upload to ensure everything is in place.
"""

import sys
import subprocess
from pathlib import Path

def check_python() -> bool:
    """Check Python and required packages"""
    print("Checking Python environment...")

    # Check Python version
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 9):
        print(f"  ❌ Python 3.9+ required (found: {version.major}.{version.minor})")
        return False
    print(f"  ✅ Python {version.major}.{version.minor}.{version.micro}")

    # Check requests package
    try:
        import requests
        print(f"  ✅ requests {requests.__version__}")
    except ImportError:
        print("  ❌ requests package not found")
        print("     Install: pip3 install requests")
        return False

    return True

def check_files() -> bool:
    """Check all required files exist"""
    print("\nChecking required files...")

    all_exist = True

    # Enhanced descriptions
    bundles = ['B001', 'B002', 'B003', 'B004', 'B005', 'B006', 'B007', 'PARENT']
    for bundle in bundles:
        desc_file = Path(f'docs/research/zenodo_{bundle}_enhanced_v7.0.md')
        if desc_file.exists():
            print(f"  ✅ {bundle} description")
        else:
            print(f"  ❌ {bundle} description MISSING")
            all_exist = False

    # Metadata files
    for bundle in bundles:
        meta_file = Path(f'docs/research/.zenodo.{bundle}_v7.0.json')
        if meta_file.exists():
            print(f"  ✅ {bundle} metadata")
        else:
            print(f"  ❌ {bundle} metadata MISSING")
            all_exist = False

    # Tools
    tools = ['zenodo_api_upload.py', 'zenodo_v15_checker.py',
            'zenodo_figure_generator.py', 'zenodo_export_benchmarks.py']
    for tool in tools:
        tool_file = Path(f'tools/{tool}')
        if tool_file.exists():
            print(f"  ✅ {tool}")
        else:
            print(f"  ❌ {tool} MISSING")
            all_exist = False

    return all_exist

def check_build() -> bool:
    """Check Zig build passes"""
    print("\nChecking Zig build...")

    result = subprocess.run(['zig', 'build'], capture_output=True, text=True)
    if result.returncode == 0:
        print("  ✅ zig build PASS")
        return True
    else:
        print("  ❌ zig build FAIL")
        return False

def check_v15_compliance() -> bool:
    """Run V15 compliance checker"""
    print("\nRunning V15 compliance checker...")

    result = subprocess.run(
        ['python3', 'tools/zenodo_v15_checker.py'],
        capture_output=True,
        text=True
    )

    # Print output
    print(result.stdout)
    if result.stderr:
        print(result.stderr)

    # Check if all passed
    if "ALL BUNDLES V15 COMPLIANT" in result.stdout:
        print("  ✅ V15 COMPLIANT")
        return True
    else:
        print("  ❌ V15 ISSUES FOUND")
        return False

def check_token() -> bool:
    """Check if ZENODO_TOKEN is set"""
    print("\nChecking Zenodo API token...")

    import os
    token = os.environ.get('ZENODO_TOKEN')
    if token:
        # Don't print the actual token
        print(f"  ✅ ZENODO_TOKEN set (length: {len(token)})")
        print("     Token found! Ready for upload.")
        return True
    else:
        print("  ⚠️  ZENODO_TOKEN not set")
        print("     Get your token at: https://zenodo.org/account/settings/applications/tokens/new")
        print("     Then run: export ZENODO_TOKEN=your_token_here")
        return False

def main():
    print("=" * 60)
    print("Zenodo v7.0 — Pre-Upload Verification")
    print("=" * 60)
    print()

    checks = [
        ("Python Environment", check_python),
        ("Required Files", check_files),
        ("Zig Build", check_build),
        ("V15 Compliance", check_v15_compliance),
        ("API Token", check_token),
    ]

    results = {}
    for name, check_fn in checks:
        try:
            results[name] = check_fn()
        except Exception as e:
            print(f"  ❌ {name}: Error - {e}")
            results[name] = False

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)

    for name, passed in results.items():
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"  {name}: {status}")

    # Final verdict
    all_passed = all(results.values())
    print()
    print("=" * 60)
    if all_passed:
        print("✅ ALL CHECKS PASSED - READY FOR UPLOAD")
        print()
        print("Next steps:")
        print("  1. Ensure ZENODO_TOKEN is set (see above)")
        print("  2. Run: python3 tools/zenodo_api_upload.py --all")
        print()
        return 0
    else:
        print("❌ SOME CHECKS FAILED - FIX ISSUES ABOVE")
        return 1

if __name__ == '__main__':
    sys.exit(main())
